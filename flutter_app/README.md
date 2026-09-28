# OnionSure Flutter Application

Production-ready Flutter application for OnionSure AI-powered onion batch grading, heap analysis, offline sync, and APMC certificate verification.

## Getting Started

### 1. Requirements
- Flutter SDK >= 3.16.0
- Dart SDK >= 3.2.0
- Android Studio / VS Code with Flutter extension

### 2. Install Dependencies
```bash
cd flutter_app
flutter pub get
```

### 3. Run the App
```bash
flutter run
```

### 4. Connect to FastAPI Backend
By default, the app is pre-configured to point to:
- **Android Emulator**: `http://10.0.2.2:8000`
- **Physical Device / Local Network**: Update the backend IP in **Settings** inside the app.

The app uses `POST /api/analyze-heap` for multipart heap image upload and inference.
