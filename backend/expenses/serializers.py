from rest_framework import serializers
from .models import Expense, Budget


class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        fields = '__all__'
        read_only_fields = ['created_at', 'updated_at']


class BudgetSerializer(serializers.ModelSerializer):
    class Meta:
        model = Budget
        fields = '__all__'
        read_only_fields = ['created_at', 'updated_at']


class ReceiptUploadSerializer(serializers.Serializer):
    receipt_image = serializers.ImageField()
    
    
class ExpenseAnalyticsSerializer(serializers.Serializer):
    total_spent = serializers.DecimalField(max_digits=10, decimal_places=2)
    category_breakdown = serializers.DictField()
    monthly_trend = serializers.ListField()
    top_merchants = serializers.ListField()
