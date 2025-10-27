# 📸 Scan Receipt Setup Guide

## 🔍 Issue Identified

The scan receipt feature isn't working because it requires:
1. ✅ **Gemini 2.0 Flash API** - Already configured in code
2. ❌ **Gemini API Key** - Missing environment variable
3. ✅ **Backend Dependencies** - Already listed in requirements.txt

## 🎯 Current Setup

### Backend Configuration
- **Model**: `gemini-2.0-flash` (configured in `backend/expenses/gemini_service.py`)
- **Endpoint**: `/api/expenses/scan_receipt/` (POST with multipart/form-data)
- **Required Field**: `receipt_image` (image file)

### What the Model Extracts
The Gemini model extracts:
- Merchant name
- Total amount
- Currency (default: USD)
- Date and time
- Category (auto-categorized)
- Payment method
- Tax and tip amounts
- Individual line items
- Additional notes/description

## 🚀 Setup Steps

### Step 1: Get Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Click **"Get API Key"** or **"Create API Key"**
3. Choose your Google Cloud project (or create a new one)
4. Copy the generated API key (starts with `AIza...`)

### Step 2: Create Environment File

Create a `.env` file in the `backend` directory:

```bash
cd backend
```

Create `.env` file with this content:
```env
GEMINI_API_KEY=your_api_key_here
```

**Example:**
```env
GEMINI_API_KEY=AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz1234567
```

### Step 3: Install Backend Dependencies

```bash
# Make sure you're in the backend directory
cd backend

# Install all required packages
pip install -r requirements.txt
```

This will install:
- `google-generativeai==0.3.2` - Gemini API client
- `Pillow==10.2.0` - Image processing
- `python-dotenv==1.0.0` - Environment variable loading
- Django and other dependencies

### Step 4: Run Backend Server

```bash
# Run migrations (if not already done)
python manage.py makemigrations
python manage.py migrate

# Start the server on all interfaces
python manage.py runserver 0.0.0.0:8000
```

## 📱 Using Scan Receipt in App

1. **Configure Backend IP**:
   - Open the app
   - Tap profile icon → "Change Backend IP"
   - Enter your computer's IP address (get it with `ipconfig` command)
   - Save the IP

2. **Scan a Receipt**:
   - Tap the "Scan Receipt" button
   - Choose "Camera" or "Gallery"
   - Take/select a clear photo of a receipt
   - Wait for Gemini to process (usually 2-5 seconds)
   - Review extracted data
   - Edit if needed
   - Save the expense

## 🔧 Troubleshooting

### Error: "Failed to extract receipt data"

**Possible causes:**
1. **Missing API Key**: Check `.env` file exists and has correct key
2. **Invalid API Key**: Verify the key is correct in Google AI Studio
3. **API Quota Exceeded**: Check your usage in Google Cloud Console
4. **Network Issues**: Ensure backend can access internet

**Solution:**
```bash
# Verify .env file exists
ls -la backend/.env

# Check if python-dotenv is installed
pip show python-dotenv

# Restart the server to reload environment variables
python manage.py runserver 0.0.0.0:8000
```

### Error: "Connection refused" or "Network error"

**Causes:**
1. Backend not running
2. Wrong IP address configured in app
3. Firewall blocking port 8000

**Solution:**
```bash
# Check if server is running
netstat -an | findstr 8000

# Get your IP address
ipconfig

# Look for "IPv4 Address" under your active network adapter
# Example: 192.168.1.100 or 10.12.169.107
```

### Image Quality Issues

**Tips for better results:**
- Use good lighting
- Avoid shadows and glare
- Ensure receipt is flat and not crumpled
- Center the receipt in the frame
- Use a clear, recent receipt (faded receipts may not work well)

### Model Not Returning Correct Data

**The Gemini 2.0 Flash model is:**
- Very accurate for standard receipts
- Multi-language capable
- Good at detecting categories
- Can handle various receipt formats

**If extraction is poor:**
1. Try a clearer photo
2. Ensure receipt text is readable
3. Check if receipt is in English (model works best with English)
4. Verify the receipt has standard format (merchant, date, items, total)

## 💰 API Costs

**Gemini 2.0 Flash Pricing (as of now):**
- **Free tier**: 15 requests per minute, 1500 per day
- **Paid tier**: Very affordable for personal use
- Check current pricing: [Google AI Pricing](https://ai.google.dev/pricing)

**For an expense tracker app:**
- Most users scan 5-10 receipts per day
- Well within free tier limits
- No costs for typical personal use

## 🔐 Security Notes

1. **Never commit `.env` file to git**:
   ```bash
   # .gitignore should have:
   .env
   *.env
   ```

2. **Keep API key secure**:
   - Don't share in screenshots
   - Don't commit to version control
   - Rotate key if exposed

3. **Use environment variables**:
   - Already configured in `settings.py`
   - Loaded via `python-dotenv`

## 📊 Expected Response Format

When scan works correctly, backend returns:

```json
{
  "message": "Receipt scanned successfully",
  "expense": {
    "id": 1,
    "merchant_name": "Walmart",
    "amount": "45.99",
    "currency": "USD",
    "category": "shopping",
    "payment_method": "credit_card",
    "date": "2024-01-15",
    "description": "Groceries",
    "items": [
      {
        "name": "Milk",
        "quantity": "1",
        "price": "3.99",
        "total": "3.99"
      }
    ],
    "tax": "3.50",
    "tip": "0.00"
  },
  "extracted_data": { ... }
}
```

## 🎨 Flutter UI Flow

1. User taps "Scan Receipt" → Opens `ScanReceiptScreen`
2. User picks image → `ImagePicker` shows camera/gallery
3. Image selected → Displays preview
4. User taps "Scan" → Calls `ApiService.scanReceipt()`
5. Loading indicator → Shows while Gemini processes
6. Success → Displays extracted data in form
7. User reviews/edits → Can modify any field
8. User saves → Creates expense in database

## ✅ Checklist

Before testing scan receipt:
- [ ] Created `.env` file in backend directory
- [ ] Added `GEMINI_API_KEY=your_key` to `.env`
- [ ] Ran `pip install -r requirements.txt`
- [ ] Ran `python manage.py migrate`
- [ ] Started server with `python manage.py runserver 0.0.0.0:8000`
- [ ] Configured backend IP in Flutter app
- [ ] Tested with a clear receipt photo

## 📞 Support

If you're still having issues:
1. Check backend console for error messages
2. Check Flutter console (in VS Code) for errors
3. Test the endpoint with Postman/curl:

```bash
curl -X POST http://your-ip:8000/api/expenses/scan_receipt/ \
  -F "receipt_image=@/path/to/receipt.jpg"
```

This will show you the exact error from backend.

---

**Summary**: The scan receipt feature uses Google's Gemini 2.0 Flash AI model. You just need to get a free API key from Google AI Studio and add it to a `.env` file in the backend directory. Everything else is already configured! 🎉
