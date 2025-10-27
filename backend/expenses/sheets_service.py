import gspread
from google.oauth2.service_account import Credentials
from django.conf import settings
from datetime import datetime
import os


class GoogleSheetsLogger:
    def __init__(self):
        self.sheet = None
        self.worksheet = None
        self._initialize_sheet()
    
    def _initialize_sheet(self):
        """Initialize connection to Google Sheets"""
        try:
            if not settings.GOOGLE_SHEETS_CREDENTIALS_PATH or not os.path.exists(settings.GOOGLE_SHEETS_CREDENTIALS_PATH):
                print("Google Sheets credentials not configured. Logging disabled.")
                return

            scope = [
                'https://spreadsheets.google.com/feeds',
                'https://www.googleapis.com/auth/drive'
            ]
            
            creds = Credentials.from_service_account_file(
                settings.GOOGLE_SHEETS_CREDENTIALS_PATH,
                scopes=scope
            )
            client = gspread.authorize(creds)

            try:
                self.sheet = client.open(settings.GOOGLE_SHEET_NAME)
            except gspread.SpreadsheetNotFound:
                self.sheet = client.create(settings.GOOGLE_SHEET_NAME)
                self.sheet.share('', perm_type='anyone', role='reader')
            
            try:
                self.worksheet = self.sheet.worksheet('Expenses')
            except gspread.WorksheetNotFound:
                self.worksheet = self.sheet.add_worksheet(title='Expenses', rows=1000, cols=15)
                headers = [
                    'ID', 'Date', 'Merchant', 'Amount', 'Currency', 'Category',
                    'Payment Method', 'Tax', 'Tip', 'Description', 'Created At'
                ]
                self.worksheet.append_row(headers)
            
        except Exception as e:
            print(f"Failed to initialize Google Sheets: {e}")
            self.sheet = None
            self.worksheet = None
    
    def log_expense(self, expense):
        """
        Log an expense to Google Sheets
        
        Args:
            expense: Expense model instance
        """
        if not self.worksheet:
            return False
        
        try:
            row = [
                str(expense.id),
                expense.date.strftime('%Y-%m-%d %H:%M:%S') if expense.date else '',
                expense.merchant_name or '',
                str(expense.amount),
                expense.currency,
                expense.category,
                expense.payment_method,
                str(expense.tax),
                str(expense.tip),
                expense.description or '',
                expense.created_at.strftime('%Y-%m-%d %H:%M:%S') if expense.created_at else ''
            ]
            
            self.worksheet.append_row(row)
            return True
            
        except Exception as e:
            print(f"Failed to log expense to Google Sheets: {e}")
            return False
    
    def update_expense(self, expense):
        """
        Update an existing expense in Google Sheets
        
        Args:
            expense: Expense model instance
        """
        if not self.worksheet:
            return False
        
        try:
            # Find the row with matching ID
            cell = self.worksheet.find(str(expense.id))
            if cell:
                row_number = cell.row
                row = [
                    str(expense.id),
                    expense.date.strftime('%Y-%m-%d %H:%M:%S') if expense.date else '',
                    expense.merchant_name or '',
                    str(expense.amount),
                    expense.currency,
                    expense.category,
                    expense.payment_method,
                    str(expense.tax),
                    str(expense.tip),
                    expense.description or '',
                    expense.created_at.strftime('%Y-%m-%d %H:%M:%S') if expense.created_at else ''
                ]
                
                # Update the row
                for col, value in enumerate(row, start=1):
                    self.worksheet.update_cell(row_number, col, value)
                
                return True
            
        except Exception as e:
            print(f"Failed to update expense in Google Sheets: {e}")
            return False
    
    def delete_expense(self, expense_id):
        """
        Delete an expense from Google Sheets
        
        Args:
            expense_id: ID of the expense to delete
        """
        if not self.worksheet:
            return False
        
        try:
            cell = self.worksheet.find(str(expense_id))
            if cell:
                self.worksheet.delete_rows(cell.row)
                return True
            
        except Exception as e:
            print(f"Failed to delete expense from Google Sheets: {e}")
            return False


# Singleton instance
sheets_logger = GoogleSheetsLogger()
