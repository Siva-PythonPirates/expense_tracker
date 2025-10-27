from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from django.db.models import Sum, Count, Q
from django.utils import timezone
from datetime import timedelta, datetime
from decimal import Decimal
from .models import Expense, Budget
from .serializers import (
    ExpenseSerializer, BudgetSerializer, 
    ReceiptUploadSerializer, ExpenseAnalyticsSerializer
)
from .gemini_service import GeminiReceiptExtractor
import logging
import os
import tempfile

logger = logging.getLogger(__name__)


class ExpenseViewSet(viewsets.ModelViewSet):
    queryset = Expense.objects.all()
    serializer_class = ExpenseSerializer
    parser_classes = [JSONParser, MultiPartParser, FormParser]
    
    def perform_create(self, serializer):
        """Save expense"""
        expense = serializer.save()
    
    def perform_update(self, serializer):
        """Update expense"""
        expense = serializer.save()
    
    def perform_destroy(self, instance):
        """Delete expense"""
        instance.delete()
    
    @action(detail=False, methods=['post'], parser_classes=[MultiPartParser, FormParser])
    def scan_receipt(self, request):
        """
        Scan receipt image and extract data using Gemini API
        """
        logger.info("[scan_receipt] content_type=%s keys=%s files=%s",
                    request.content_type, list(request.data.keys()), list(request.FILES.keys()))

        serializer = ReceiptUploadSerializer(data=request.data)
        
        if not serializer.is_valid():
            logger.warning("[scan_receipt] invalid serializer: %s", serializer.errors)
            return Response({'error': 'Invalid image file', 'details': serializer.errors},
                            status=status.HTTP_400_BAD_REQUEST)
        
        receipt_image = serializer.validated_data['receipt_image']
        temp_path = None
        try:
            # Ensure we have a file path on disk (some uploads are in-memory)
            suffix = os.path.splitext(getattr(receipt_image, 'name', 'receipt'))[1] or '.jpg'
            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp:
                for chunk in receipt_image.chunks():
                    tmp.write(chunk)
                temp_path = tmp.name
            logger.info("[scan_receipt] saved temp image: %s (size=%s)", temp_path, os.path.getsize(temp_path))
        except Exception as e:
            logger.exception("[scan_receipt] failed to persist temp image: %s", e)
            return Response({'error': f'Failed to read uploaded image: {e}'},
                            status=status.HTTP_400_BAD_REQUEST)
        
        # Extract data using Gemini
        extractor = GeminiReceiptExtractor()
        result = extractor.extract_receipt_data(temp_path or receipt_image)
        logger.info("[scan_receipt] extractor success=%s", result.get('success'))
        
        if not result['success']:
            logger.error("[scan_receipt] extraction failed: %s", result.get('error'))
            # Cleanup temp file
            if temp_path and os.path.exists(temp_path):
                try:
                    os.remove(temp_path)
                except Exception:
                    pass
            return Response({'error': result.get('error', 'Failed to extract receipt data')},
                            status=status.HTTP_502_BAD_GATEWAY)
        
        extracted_data = result['data']
        
        # Create expense with extracted data
        try:
            # Parse date
            date = timezone.now()
            if extracted_data.get('date'):
                try:
                    date = datetime.strptime(extracted_data['date'], '%Y-%m-%d')
                except ValueError:
                    pass
            
            # Safe decimal conversions
            def to_decimal(val, default='0.00'):
                try:
                    return Decimal(str(val))
                except Exception:
                    return Decimal(default)

            amount_dec = to_decimal(extracted_data.get('amount', 0))
            tax_dec = to_decimal(extracted_data.get('tax', 0))
            tip_dec = to_decimal(extracted_data.get('tip', 0))

            # Optional username passing (header or query)
            username = request.headers.get('X-Username') or request.query_params.get('username')

            expense = Expense.objects.create(
                merchant_name=extracted_data.get('merchant_name'),
                amount=amount_dec,
                currency=extracted_data.get('currency', 'USD'),
                category=extracted_data.get('category', 'other'),
                payment_method=extracted_data.get('payment_method', 'other'),
                date=date,
                description=extracted_data.get('description'),
                items=extracted_data.get('items'),
                tax=tax_dec,
                tip=tip_dec,
                receipt_image=receipt_image,
                username=username
            )
            
            return Response(
                {
                    'message': 'Receipt scanned successfully',
                    'expense': ExpenseSerializer(expense).data,
                    'extracted_data': extracted_data,
                    'raw_text': result.get('raw_text')
                },
                status=status.HTTP_201_CREATED
            )
            
        except Exception as e:
            logger.exception("[scan_receipt] failed to create expense: %s", e)
            return Response({'error': f'Failed to create expense: {str(e)}'},
                            status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        finally:
            # Cleanup temp file
            if temp_path and os.path.exists(temp_path):
                try:
                    os.remove(temp_path)
                except Exception:
                    pass
    
    @action(detail=False, methods=['get'])
    def analytics(self, request):
        """
        Get expense analytics and statistics
        """
        # Get query parameters
        period = request.query_params.get('period', 'month')  # day, week, month, year, all
        
        # Calculate date range
        now = timezone.now()
        if period == 'day':
            start_date = now - timedelta(days=1)
        elif period == 'week':
            start_date = now - timedelta(weeks=1)
        elif period == 'month':
            start_date = now - timedelta(days=30)
        elif period == 'year':
            start_date = now - timedelta(days=365)
        else:
            start_date = None
        
        # Filter expenses
        if start_date:
            expenses = Expense.objects.filter(date__gte=start_date)
        else:
            expenses = Expense.objects.all()
        
        # Total spent
        total_spent = expenses.aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
        
        # Category breakdown
        category_breakdown = {}
        for category, label in Expense.CATEGORY_CHOICES:
            amount = expenses.filter(category=category).aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
            category_breakdown[category] = {
                'label': label,
                'amount': float(amount),
                'count': expenses.filter(category=category).count()
            }
        
        # Monthly trend (last 12 months)
        monthly_trend = []
        for i in range(12):
            month_start = now - timedelta(days=30 * i)
            month_end = now - timedelta(days=30 * (i - 1)) if i > 0 else now
            month_expenses = Expense.objects.filter(
                date__gte=month_start,
                date__lt=month_end
            )
            month_total = month_expenses.aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
            monthly_trend.insert(0, {
                'month': month_start.strftime('%b %Y'),
                'amount': float(month_total),
                'count': month_expenses.count()
            })
        
        # Top merchants
        top_merchants = []
        merchants = expenses.values('merchant_name').annotate(
            total=Sum('amount'),
            count=Count('id')
        ).order_by('-total')[:10]
        
        for merchant in merchants:
            if merchant['merchant_name']:
                top_merchants.append({
                    'name': merchant['merchant_name'],
                    'amount': float(merchant['total']),
                    'count': merchant['count']
                })
        
        # Payment method breakdown
        payment_breakdown = {}
        for method, label in Expense.PAYMENT_METHOD_CHOICES:
            amount = expenses.filter(payment_method=method).aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
            payment_breakdown[method] = {
                'label': label,
                'amount': float(amount),
                'count': expenses.filter(payment_method=method).count()
            }
        
        analytics_data = {
            'total_spent': float(total_spent),
            'expense_count': expenses.count(),
            'category_breakdown': category_breakdown,
            'monthly_trend': monthly_trend,
            'top_merchants': top_merchants,
            'payment_breakdown': payment_breakdown,
            'period': period
        }
        
        return Response(analytics_data)
    
    @action(detail=False, methods=['get'])
    def summary(self, request):
        """
        Get quick summary statistics
        """
        now = timezone.now()
        
        # Today
        today_expenses = Expense.objects.filter(date__date=now.date())
        today_total = today_expenses.aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
        
        # This week
        week_start = now - timedelta(days=now.weekday())
        week_expenses = Expense.objects.filter(date__gte=week_start)
        week_total = week_expenses.aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
        
        # This month
        month_start = now.replace(day=1)
        month_expenses = Expense.objects.filter(date__gte=month_start)
        month_total = month_expenses.aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
        
        # All time
        all_total = Expense.objects.aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
        
        return Response({
            'today': {
                'total': float(today_total),
                'count': today_expenses.count()
            },
            'week': {
                'total': float(week_total),
                'count': week_expenses.count()
            },
            'month': {
                'total': float(month_total),
                'count': month_expenses.count()
            },
            'all_time': {
                'total': float(all_total),
                'count': Expense.objects.count()
            }
        })


class BudgetViewSet(viewsets.ModelViewSet):
    queryset = Budget.objects.all()
    serializer_class = BudgetSerializer
    
    @action(detail=False, methods=['get'])
    def status(self, request):
        """
        Get budget status for all categories
        """
        budgets = Budget.objects.all()
        budget_status = []
        
        now = timezone.now()
        
        for budget in budgets:
            # Calculate date range based on period
            if budget.period == 'daily':
                start_date = now - timedelta(days=1)
            elif budget.period == 'weekly':
                start_date = now - timedelta(weeks=1)
            elif budget.period == 'monthly':
                start_date = now - timedelta(days=30)
            elif budget.period == 'yearly':
                start_date = now - timedelta(days=365)
            else:
                start_date = now - timedelta(days=30)
            
            # Get expenses for this category in the period
            spent = Expense.objects.filter(
                category=budget.category,
                date__gte=start_date
            ).aggregate(total=Sum('amount'))['total'] or Decimal('0.00')
            
            remaining = budget.amount - spent
            percentage = (spent / budget.amount * 100) if budget.amount > 0 else 0
            
            budget_status.append({
                'id': budget.id,
                'category': budget.category,
                'budget': float(budget.amount),
                'spent': float(spent),
                'remaining': float(remaining),
                'percentage': float(percentage),
                'period': budget.period,
                'is_exceeded': spent > budget.amount
            })
        
        return Response(budget_status)
