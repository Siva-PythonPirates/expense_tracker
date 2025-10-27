import google.generativeai as genai
from django.conf import settings
import json
import base64
from PIL import Image
import io


class GeminiReceiptExtractor:
    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        # Use newer, faster multimodal model
        self.model = genai.GenerativeModel('gemini-2.5-flash')
    
    def extract_receipt_data(self, image_file):
        try:
            # Load image
            if hasattr(image_file, 'read'):
                # File-like object
                image_data = image_file.read()
                image = Image.open(io.BytesIO(image_data))
            else:
                # String path
                image = Image.open(image_file)
            
            # Create the prompt for receipt extraction
            prompt = """
            Analyze this receipt image and extract the following information in JSON format:
            
            {
                "merchant_name": "Name of the store/merchant",
                "amount": "Total amount as a number (e.g., 45.99)",
                "currency": "Currency code (e.g., USD, EUR)",
                "date": "Date in YYYY-MM-DD format",
                "time": "Time in HH:MM format if available",
                "category": "Best matching category from: food, transport, shopping, entertainment, utilities, healthcare, education, other",
                "payment_method": "Payment method if visible: cash, credit_card, debit_card, upi, other",
                "tax": "Tax amount as a number",
                "tip": "Tip amount as a number if applicable",
                "items": [
                    {
                        "name": "Item name",
                        "quantity": "Quantity",
                        "price": "Price per unit",
                        "total": "Total for this item"
                    }
                ],
                "description": "Any additional notes or details"
            }
            
            If any field is not visible or uncertain, use null for that field.
            Return ONLY valid JSON, no markdown formatting or additional text.
            """
            response = self.model.generate_content([prompt, image])
            
            response_text = response.text.strip()
            
            if response_text.startswith('```json'):
                response_text = response_text[7:]
            if response_text.startswith('```'):
                response_text = response_text[3:]
            if response_text.endswith('```'):
                response_text = response_text[:-3]
            
            response_text = response_text.strip()
            
            extracted_data = json.loads(response_text)
            
            cleaned_data = self._clean_extracted_data(extracted_data)
            
            # Also extract raw text for debugging/visibility
            raw_text_prompt = "Extract all visible text from this receipt image. Return only plain text without any markdown."
            try:
                raw_text_resp = self.model.generate_content([raw_text_prompt, image])
                raw_text = (raw_text_resp.text or '').strip()
            except Exception as _:
                raw_text = None
            
            return {
                'success': True,
                'data': cleaned_data,
                'raw_text': raw_text
            }
            
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'data': None,
                'raw_text': None
            }
    
    def _clean_extracted_data(self, data):
        """Clean and validate extracted data"""
        cleaned = {}
        
        # Clean merchant name
        cleaned['merchant_name'] = data.get('merchant_name', '').strip() or None
        
        # Clean amount
        try:
            amount = data.get('amount')
            if amount is not None:
                cleaned['amount'] = float(str(amount).replace(',', '').replace('$', ''))
            else:
                cleaned['amount'] = 0.0
        except (ValueError, TypeError):
            cleaned['amount'] = 0.0
        
        
        cleaned['currency'] = data.get('currency', 'USD').upper()
        
        
        cleaned['date'] = data.get('date')
        
        
        valid_categories = ['food', 'transport', 'shopping', 'entertainment', 
                           'utilities', 'healthcare', 'education', 'other']
        category = data.get('category', 'other').lower()
        cleaned['category'] = category if category in valid_categories else 'other'
        
        
        valid_methods = ['cash', 'credit_card', 'debit_card', 'upi', 'other']
        payment = data.get('payment_method', 'other').lower()
        cleaned['payment_method'] = payment if payment in valid_methods else 'other'
        
        
        try:
            tax = data.get('tax')
            cleaned['tax'] = float(str(tax).replace(',', '').replace('$', '')) if tax else 0.0
        except (ValueError, TypeError):
            cleaned['tax'] = 0.0
        
        
        try:
            tip = data.get('tip')
            cleaned['tip'] = float(str(tip).replace(',', '').replace('$', '')) if tip else 0.0
        except (ValueError, TypeError):
            cleaned['tip'] = 0.0
        
        
        cleaned['items'] = data.get('items', [])
        
        
        cleaned['description'] = data.get('description', '').strip() or None
        
        return cleaned
