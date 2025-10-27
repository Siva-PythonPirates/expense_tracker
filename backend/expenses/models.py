from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User


class Expense(models.Model):
    CATEGORY_CHOICES = [
        ('food', 'Food & Dining'),
        ('transport', 'Transportation'),
        ('shopping', 'Shopping'),
        ('entertainment', 'Entertainment'),
        ('utilities', 'Utilities'),
        ('healthcare', 'Healthcare'),
        ('education', 'Education'),
        ('other', 'Other'),
    ]
    
    PAYMENT_METHOD_CHOICES = [
        ('cash', 'Cash'),
        ('credit_card', 'Credit Card'),
        ('debit_card', 'Debit Card'),
        ('upi', 'UPI'),
        ('other', 'Other'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='expenses', null=True, blank=True)
    username = models.CharField(max_length=150, db_index=True, null=True, blank=True)  # For username-based filtering
    receipt_image = models.ImageField(upload_to='receipts/', null=True, blank=True)
    merchant_name = models.CharField(max_length=255, blank=True, null=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=10, default='USD')
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default='other')
    payment_method = models.CharField(max_length=50, choices=PAYMENT_METHOD_CHOICES, default='cash')
    date = models.DateTimeField(default=timezone.now)
    description = models.TextField(blank=True, null=True)
    items = models.JSONField(blank=True, null=True)  # Store extracted line items
    tax = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    tip = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-date']
    
    def __str__(self):
        date_str = self.date.strftime('%Y-%m-%d') if self.date else 'No date'
        return f"{self.merchant_name or 'Unknown'} - ${self.amount} on {date_str}"


class Budget(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='budgets', null=True, blank=True)
    username = models.CharField(max_length=150, db_index=True, null=True, blank=True)  # For username-based filtering
    category = models.CharField(max_length=50)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    period = models.CharField(max_length=20, choices=[
        ('daily', 'Daily'),
        ('weekly', 'Weekly'),
        ('monthly', 'Monthly'),
        ('yearly', 'Yearly'),
    ], default='monthly')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ['username', 'category']
    
    def __str__(self):
        return f"{self.username} - {self.category} - ${self.amount} ({self.period})"
