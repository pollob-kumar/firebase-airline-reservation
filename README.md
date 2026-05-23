# Firebase Airline Reservation System

A Flutter + Firebase airline reservation app with separate admin and user experiences, flight management, and a booking lifecycle with notifications.

## Overview
This project provides a role-based airline reservation flow. Users can search flights, manage balance, and book tickets, while admins manage flights, review bookings, and track income. Data is stored in Cloud Firestore and authentication uses Firebase Auth.

## Core Features
- Email/password authentication with role-based routing (admin and user). Admin registration requires `AppConstants.adminCode` (default: `235857`).
- Admin: add flights, view bookings, confirm or cancel bookings, income reports, user account management, notifications, and settings.
- User: search and browse flights, book tickets, add and check balance, view booking history, request cancellations, notifications, frequent flyer, and support.

## Tech Stack
- Flutter (Material 3 UI)
- Firebase Auth
- Cloud Firestore

## Project Structure
- `lib/main.dart`: App entry, Firebase initialization, theme
- `lib/auth/`: Login and registration flow
- `lib/models/`: Firestore data models
- `lib/services/`: Firestore and UI constants
- `lib/screens/admin/`: Admin dashboard and tools
- `lib/screens/user/`: User dashboard and tools
- `lib/firebase_options.dart`: FlutterFire generated config

## Setup
1. Install Flutter SDK.
2. Create a Firebase project and run `flutterfire configure` to generate `lib/firebase_options.dart`.
3. Review and deploy `firestore.rules` to your Firebase project.
4. Install dependencies:
   ```
   flutter pub get
   ```

## Run
```
flutter run
```

## Tests
```
flutter analyze
flutter test
```

## Build
- APK (release):
  ```
  flutter build apk --release
  ```
  Output: `build\app\outputs\flutter-apk\app-release.apk`
- Web (release):
  ```
  flutter build web --release
  ```

## Documentation
- `DOCUMENTATION.md` (overview, features, structure, API)
- `SRS.md`, `SDD.md`, `DIRECTORY.md`
