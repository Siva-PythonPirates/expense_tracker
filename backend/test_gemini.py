"""
Test Gemini 2.5 Flash with a local image (default: ./a.png)

Usage:
  python test_gemini.py [path_to_image]

This script:
  1) Verifies GEMINI_API_KEY from .env
  2) Loads an image and asks for structured JSON receipt data
  3) Extracts raw visible text as a secondary pass
"""

import os
import sys
import json
from textwrap import shorten
from dotenv import load_dotenv
from PIL import Image
import google.generativeai as genai


def _clean_code_fences(s: str) -> str:
    if not s:
        return s
    s = s.strip()
    if s.startswith('```json'):
        s = s[7:]
    if s.startswith('```'):
        s = s[3:]
    if s.endswith('```'):
        s = s[:-3]
    return s.strip()


def main():
    print("🔍 Gemini 2.5 Flash Receipt Test")
    print("=" * 60)

    # Load environment variables
    load_dotenv()
    api_key = os.getenv('GEMINI_API_KEY', '')
    if not api_key:
        print("❌ GEMINI_API_KEY not found in .env")
        return 1

    # Resolve image path
    img_path = sys.argv[1] if len(sys.argv) > 1 else './a.png'
    if not os.path.exists(img_path):
        print(f"❌ Image not found: {img_path}")
        print("   Place a test image at ./a.png or pass a path as an argument.")
        return 1

    print(f"✅ Using image: {img_path} ({os.path.getsize(img_path)} bytes)")

    # Configure client
    try:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-2.5-flash')
        print("✅ Model 'gemini-2.5-flash' ready")
    except Exception as e:
        print(f"❌ Failed to init model: {e}")
        return 1

    # Load image
    try:
        image = Image.open(img_path)
    except Exception as e:
        print(f"❌ Failed to open image: {e}")
        return 1

    # Structured JSON extraction
    prompt = (
        "Analyze this receipt image and extract the following information in JSON format:\n\n"
        "{\n"
        "  \"merchant_name\": \"Name of the store/merchant\",\n"
        "  \"amount\": \"Total amount as a number (e.g., 45.99)\",\n"
        "  \"currency\": \"Currency code (e.g., USD, EUR)\",\n"
        "  \"date\": \"Date in YYYY-MM-DD format\",\n"
        "  \"time\": \"Time in HH:MM format if available\",\n"
        "  \"category\": \"Best matching category from: food, transport, shopping, entertainment, utilities, healthcare, education, other\",\n"
        "  \"payment_method\": \"Payment method if visible: cash, credit_card, debit_card, upi, other\",\n"
        "  \"tax\": \"Tax amount as a number\",\n"
        "  \"tip\": \"Tip amount as a number if applicable\",\n"
        "  \"items\": [ { \"name\": \"Item name\", \"quantity\": \"Quantity\", \"price\": \"Price per unit\", \"total\": \"Total\" } ],\n"
        "  \"description\": \"Any additional notes or details\"\n"
        "}\n\n"
        "If any field is not visible or uncertain, use null for that field.\n"
        "Return ONLY valid JSON, no markdown formatting or additional text."
    )

    try:
        print("\n⏳ Requesting structured JSON...")
        resp = model.generate_content([prompt, image])
        text = _clean_code_fences((resp.text or '').strip())
        data = json.loads(text)
        print("✅ JSON parsed. Summary:")
        print(f"  merchant_name: {data.get('merchant_name')}")
        print(f"  amount: {data.get('amount')} {data.get('currency')}")
        print(f"  date: {data.get('date')}  payment_method: {data.get('payment_method')}")
        items = data.get('items') or []
        print(f"  items: {len(items)}")
    except Exception as e:
        print(f"❌ Structured extraction failed: {e}")
        print("Raw response:")
        print(shorten((resp.text if 'resp' in locals() else ''), width=600, placeholder='...'))
        return 1

    # Raw text extraction
    raw_prompt = "Extract all visible text from this receipt image. Return only plain text without any markdown."
    try:
        print("\n⏳ Requesting raw text...")
        raw_resp = model.generate_content([raw_prompt, image])
        raw_text = (raw_resp.text or '').strip()
        print("✅ Raw text (first 600 chars):")
        print(shorten(raw_text, width=600, placeholder='...'))
    except Exception as e:
        print(f"❌ Raw text extraction failed: {e}")
        return 1

    print("\n🎉 Test completed successfully.")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())