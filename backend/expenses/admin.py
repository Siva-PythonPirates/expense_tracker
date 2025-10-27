from django.contrib import admin
from .models import Expense, Budget


@admin.register(Expense)
class ExpenseAdmin(admin.ModelAdmin):
    list_display = ['merchant_name', 'amount', 'currency', 'category', 'payment_method', 'date', 'created_at']
    list_filter = ['category', 'payment_method', 'currency', 'date']
    search_fields = ['merchant_name', 'description']
    date_hierarchy = 'date'
    ordering = ['-date']


@admin.register(Budget)
class BudgetAdmin(admin.ModelAdmin):
    list_display = ['category', 'amount', 'period', 'created_at']
    list_filter = ['period', 'category']
    ordering = ['category']
