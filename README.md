# Expense Tracker

Full-stack expense tracking app with AI-powered receipt scanning.

## Tech Stack
- **Backend**: Django + DRF
- **Frontend**: Flutter  
- **AI**: Google Gemini API
- **Database**: SQLite

## Quick Setup

### Backend
```bash
cd backend
pip install -r requirements.txt
python manage.py migrate
# Add GEMINI_API_KEY to .env file
python manage.py runserver
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## API Key
Get your free Gemini API key: https://makersuite.google.com/app/apikey

Add to `backend/.env`:
```
GEMINI_API_KEY=your_key_here
```

## Features
- 📸 AI receipt scanning
- 💰 Expense tracking
- 📊 Analytics dashboard
- 📝 Google Sheets logging (optional)

## Project Structure

```
expense_tracker/
├── backend/                 # Django backend
│   ├── expense_tracker_api/ # Project settings
│   ├── expenses/           # Main app
│   │   ├── models.py       # Database models
│   │   ├── views.py        # API views
│   │   ├── serializers.py  # DRF serializers
│   │   ├── gemini_service.py # Gemini AI integration
│   │   └── sheets_service.py # Google Sheets integration
│   ├── manage.py
│   └── requirements.txt
│
└── frontend/               # Flutter frontend
    ├── lib/
    │   ├── models/         # Data models
    │   ├── services/       # API services
    │   ├── screens/        # UI screens
    │   ├── utils/          # Constants and helpers
    │   └── main.dart
    └── pubspec.yaml
```

## Setup Instructions

### Backend Setup

1. **Navigate to backend directory**:
   ```bash
   cd expense_tracker/backend
   ```

2. **Create virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**:
   - Copy `.env.example` to `.env`
   - Add your Gemini API key:
     ```
     GEMINI_API_KEY=your_gemini_api_key_here
     ```
   - (Optional) Configure Google Sheets:
     ```
     GOOGLE_SHEETS_CREDENTIALS_PATH=path_to_service_account.json
     GOOGLE_SHEET_NAME=ExpenseTrackerLog
     ```

5. **Run migrations**:
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

6. **Create superuser** (optional):
   ```bash
   python manage.py createsuperuser
   ```

7. **Start development server**:
   ```bash
   python manage.py runserver
   ```

   The API will be available at `http://localhost:8000`

### Frontend Setup

1. **Navigate to frontend directory**:
   ```bash
   cd expense_tracker/frontend
   ```

2. **Get Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**:
   - Open `lib/services/api_service.dart`
   - Update `baseUrl` to your backend URL (default: `http://localhost:8000/api`)

4. **Run the app**:
   ```bash
   flutter run
   ```

   For web:
   ```bash
   flutter run -d chrome
   ```

## Getting API Keys

### Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Add it to your `.env` file

### Google Sheets API (Optional)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable Google Sheets API
4. Create a service account
5. Download the JSON credentials file
6. Share your Google Sheet with the service account email
7. Update the path in `.env`

## API Endpoints

### Expenses
- `GET /api/expenses/` - List all expenses
- `POST /api/expenses/` - Create expense
- `GET /api/expenses/{id}/` - Get expense details
- `PUT /api/expenses/{id}/` - Update expense
- `DELETE /api/expenses/{id}/` - Delete expense
- `POST /api/expenses/scan_receipt/` - Scan receipt image
- `GET /api/expenses/analytics/` - Get analytics data
- `GET /api/expenses/summary/` - Get expense summary

### Budgets
- `GET /api/budgets/` - List all budgets
- `POST /api/budgets/` - Create budget
- `GET /api/budgets/status/` - Get budget status

## Usage

1. **Scan a Receipt**:
   - Tap the "Scan Receipt" button
   - Choose camera or gallery
   - The AI will automatically extract merchant name, amount, date, category, etc.
   - Review and save

2. **View Expenses**:
   - Browse all expenses in the list
   - Tap to view details
   - Long press to delete

3. **View Analytics**:
   - Navigate to Analytics tab
   - View spending by category, trends, top merchants
   - Filter by different time periods

## Development

### Backend Development

- Admin panel: `http://localhost:8000/admin`
- API documentation: Available through browsable API
- Run tests: `python manage.py test`

### Frontend Development

- Hot reload is enabled by default
- Run tests: `flutter test`
- Build for production: `flutter build [platform]`

## Troubleshooting

### Backend Issues

- **Database locked**: Stop other Django processes
- **Gemini API errors**: Check your API key and quota
- **Google Sheets not working**: Verify credentials and sharing settings

### Frontend Issues

- **API connection errors**: Ensure backend is running and URL is correct
- **Image picker not working**: Check platform permissions
- **Charts not displaying**: Verify data format from API

## Future Enhancements

- [ ] User authentication
- [ ] Budget alerts
- [ ] Receipt image storage in cloud
- [ ] Export to PDF/CSV
- [ ] Multi-currency support
- [ ] Recurring expenses
- [ ] Mobile notifications

## License

This project is for educational purposes.

## Support

For issues or questions, please create an issue in the repository.
