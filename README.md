# Weladti — AI Pregnancy Health Platform

A mobile health platform for pregnant women that predicts preeclampsia risk using a custom-trained ensemble ML model, generates personalized Arabic health reports via Google Gemini AI, and integrates with smart scales to track body composition throughout pregnancy. Built with Flutter for iOS/Android and a FastAPI backend with Docker deployment.

## Why We Built This

Preeclampsia affects 5-8% of pregnancies worldwide and is a leading cause of maternal and infant mortality — yet it often goes undetected until it becomes an emergency. Most pregnancy apps just track due dates and weight. Weladti goes further: it takes the vital signs and body composition data a woman already measures and runs them through clinical risk logic to surface early warnings before symptoms become dangerous, then explains everything in plain Arabic through an AI health assistant named Nour.

## Features

- **Preeclampsia risk prediction** — ensemble model (Random Forest + Gradient Boosting) trained on 8,000 synthetic samples built from WHO and ACOG clinical guidelines, producing a 4-level risk classification (low / moderate / high / critical) with calibrated probabilities
- **Smart scale integration** — connects to body composition scales to automatically pull weight, BMI, body water percentage, visceral fat, and heart rate into health records
- **AI health chatbot (Nour)** — Arabic-language conversational assistant powered by Google Gemini, specialized in pregnancy health with automatic escalation for preeclampsia warning signs
- **Personalized medical reports** — Gemini generates a full Arabic health summary from each analysis, accounting for the user's gestational week, medical history, and risk profile
- **Smart alerts** — rule-based alert engine that flags severe hypertension, proteinuria combined with high blood pressure, abnormal weight gain, fluid retention, and neurological symptom combinations
- **Secondary risk indicators** — separate risk scores for abnormal weight gain, fluid retention, and gestational diabetes, computed alongside the main preeclampsia prediction
- **Doctor panel** — dedicated view for healthcare providers to review patient records and AI analyses
- **10 complete screens** — splash, onboarding, auth, profile setup, dashboard, health input, health history, AI predictions, insights, chatbot, settings
- **Riverpod state management** — reactive state architecture with providers for auth and health data
- **Docker deployment** — single `docker-compose up` command starts the entire backend stack

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter (Dart) | Cross-platform mobile app (iOS / Android / macOS) |
| Riverpod | Reactive state management |
| go_router | Declarative navigation |
| Dio | HTTP client with interceptors |
| fl_chart | Health data visualizations |
| FastAPI (Python) | Async REST API backend |
| SQLAlchemy | ORM with async SQLite |
| scikit-learn | Ensemble ML model (Random Forest + Gradient Boosting) |
| Google Gemini AI | Arabic medical report generation and chatbot |
| Docker + Docker Compose | Containerized backend deployment |
| PyJWT + passlib | Authentication and password hashing |

## Project Structure

```
weladti/
├── backend/
│   ├── app/
│   │   ├── main.py                  # FastAPI app entry point
│   │   ├── config.py                # Settings loaded from .env
│   │   ├── database.py              # Async SQLite engine and session
│   │   ├── api/
│   │   │   ├── auth.py              # Register, login, JWT
│   │   │   ├── health.py            # Health record CRUD
│   │   │   ├── predictions.py       # ML analysis trigger and history
│   │   │   ├── insights.py          # Trend analysis and insights
│   │   │   └── smart_scale.py       # Smart scale data ingestion
│   │   ├── ml/
│   │   │   └── model.py             # Ensemble model training, loading, and inference
│   │   ├── models/                  # SQLAlchemy database models
│   │   ├── schemas/                 # Pydantic request/response schemas
│   │   └── services/
│   │       ├── gemini_service.py    # Gemini AI report generation and chatbot
│   │       ├── auth_service.py      # Password hashing, token creation
│   │       └── smart_scale_service.py
│   ├── seed_demo.py                 # Demo data seeding script
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── lib/
│   │   ├── main.dart                # App entry point
│   │   ├── app.dart                 # Root widget and theme
│   │   ├── core/
│   │   │   ├── constants/           # Colors, text styles, app constants
│   │   │   ├── network/api_client.dart  # Dio HTTP client with auth
│   │   │   ├── router/app_router.dart   # go_router navigation config
│   │   │   └── widgets/             # Reusable UI components
│   │   ├── features/                # 10 feature screens
│   │   └── providers/               # Riverpod state providers
│   ├── assets/
│   │   ├── images/
│   │   └── animations/
│   └── pubspec.yaml
├── docker-compose.yml
├── .env.example
├── run.sh                           # One-command startup (Docker + Flutter)
└── README.md
```

## Installation & Setup

### Quick Start with Docker + Flutter

```bash
# 1. Clone the repository
git clone https://github.com/nihalalarifi/weladti.git
cd weladti

# 2. Set up environment variables
cp .env.example .env
# Edit .env and add your GEMINI_API_KEY

# 3. Start the backend
docker-compose up --build -d

# Backend available at:
#   API:      http://localhost:8000
#   API Docs: http://localhost:8000/docs

# 4. Run the Flutter app
cd frontend
flutter pub get
flutter run
```

Alternatively, run `./run.sh` from the project root for a one-command startup that handles Docker and launches the iOS Simulator automatically.

### Manual Backend (without Docker)

```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp ../.env.example ../.env   # fill in values
uvicorn app.main:app --reload --port 8000
# The ML model trains automatically on first startup (~10 seconds)
```

## Environment Variables

Copy `.env.example` to `.env` and configure:

```
SECRET_KEY=              # Generate: python3 -c "import secrets; print(secrets.token_hex(32))"
DATABASE_URL=            # Default: sqlite:///./weladti.db
GEMINI_API_KEY=          # From https://aistudio.google.com
ACCESS_TOKEN_EXPIRE_MINUTES=43200
ENVIRONMENT=development
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
```

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | /api/v1/auth/register | Create account |
| POST | /api/v1/auth/login | Login and receive JWT |
| GET | /api/v1/health/records | List health records |
| POST | /api/v1/health/records | Add a new health reading |
| POST | /api/v1/predictions/analyze | Run ML risk analysis |
| GET | /api/v1/predictions/history | Prediction history |
| POST | /api/v1/insights/chat | Chat with Nour (AI assistant) |
| GET | /api/v1/insights/trends | Health trend analysis |
| POST | /api/v1/smart-scale/sync | Sync smart scale data |
| GET | /health | Health check |

## Technical Challenge

The hardest part was building a clinically meaningful ML model without access to a real labeled medical dataset.

Real preeclampsia datasets are either private (hospital EMR data) or too small for a reliable ensemble. The solution was generating 8,000 synthetic training samples using published clinical risk formulas from WHO and ACOG guidelines — encoding the actual relationships between blood pressure, proteinuria, gestational age, BMI, and medical history that clinicians use to assess risk. The feature engineering mirrors what an obstetrician considers: a 140/90 reading at week 36 with proteinuria carries different weight than the same reading at week 20 without it.

The model was then calibrated using `CalibratedClassifierCV` so that its probability outputs are reliable enough to drive the smart alert system. Without calibration, a Random Forest's raw class probabilities are often overconfident at the extremes, which would cause dangerous false negatives in the critical risk category.

## License

MIT
