# SafeMind

SafeMind is a Flutter mental health support app for university students. It focuses on anonymous sharing, peer support, advisor responses, and moderation.

## Current Architecture

- `lib/main.dart` bootstraps Flutter and Firebase.
- `lib/app.dart` contains the app shell, auth gate, routes, and theme hookup.
- `lib/models/` contains user, post, comment, and report data objects.
- `lib/services/backend_service.dart` provides Firebase-backed logic with a demo fallback when Firebase is not configured yet.
- `lib/screens/` contains the app screens.
- `lib/widgets/` contains shared UI components.

## What Works Now

- Login and anonymous login flow.
- Sign up flow.
- Feed rendering from a live stream source.
- Post creation.
- Post details with comments.
- Support/like counts.
- Best-solution marking.
- Report submission flow.
- Safety/disclaimer screen.

## What You Still Need To Do For Real Firebase

1. Create a Firebase project in the Firebase Console.
2. Register the Android app with your package name.
3. Register the iOS app.
4. Download and add `android/app/google-services.json`.
5. Download and add `ios/Runner/GoogleService-Info.plist`.
6. Run `flutterfire configure` to generate `lib/firebase_options.dart`.
7. Add Firestore rules from `firestore.rules`.
8. Create the Firestore database.

## Useful Commands

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutterfire configure
```

## Project Idea

SafeMind is designed as a portfolio-ready app for peer support and advisor-guided mental health discussions with anonymity and moderation.
