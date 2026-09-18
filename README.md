# OnionSure

Android-first Flutter demo for SIH26031: AI-powered onion quality assessment and digital grading.

## Run

```powershell
cd onion_quality_app
flutter pub get
flutter run
```

Demo flow: `Create batch -> Batch QR -> Scan QR -> Capture/select image -> Mock analysis -> PDF report -> Report QR -> Verify`.

The upgraded heap flow is available from an inspection: capture or select one heap image, choose `Analyze Onion Heap`, then review segmentation overlays, visible-sample Grade A/B/Reject percentages, defects, and the report. Start the backend from `backend/README.md` and pass its URL with `--dart-define=HEAP_ANALYSIS_API_URL=...`.

## AI configuration

Edit `lib/config/app_config.dart`:

- Set `useMockAi = true` for presentation mode.
- Set `useMockAi = false` to POST multipart images to `aiApiUrl`.
- Change `aiApiUrl` to the reachable FastAPI endpoint.

## Firebase configuration

1. Create a Firebase project and enable Email/Password Authentication, Firestore, and Storage.
2. Install FlutterFire CLI and run `flutterfire configure` from this directory.
3. Initialize Firebase with the generated `firebase_options.dart` before `runApp`.
4. Replace the demo methods in `lib/services/app_services.dart` with Firebase Auth, Firestore, and Storage calls. Intended collections are `users`, `batches`, `inspections`, and `reports`.
5. Deploy `firestore.rules` with the Firebase CLI.

The demo store keeps the app runnable before Firebase credentials are available.

## Build APK

```powershell
flutter build apk --debug
flutter build apk --release
```

Release builds require Android signing configuration for distribution.
