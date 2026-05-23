# Copilot instructions for this repository

## Build, test, and lint
- Install dependencies: `flutter pub get`
- Lint (CI uses this): `flutter analyze`
- Run all tests: `flutter test`
- Run your app: `flutter run`
- Run a single test: `flutter test test\widget_test.dart`
- Build web (CI uses this): `flutter build web --release`
- Build APK (release workflow): `flutter build apk --release`

## Architecture (big picture)
- `lib/main.dart` initializes Firebase via `firebase_options.dart` and starts the auth flow.
- `lib\auth` contains the login/registration screens plus `AuthService`, which wraps Firebase Auth and loads `UserModel` from Firestore to determine the user role.
- `FirestoreService` is the single data-access layer for the `users`, `flights`, and `bookings` collections; models in `lib\models` map Firestore documents.
- Admin UI (`lib\screens\admin`) manages flights and shows income reporting from bookings.
- User UI (`lib\screens\user`) handles balance top-up, flight browsing, and booking confirmation; booking writes a record and updates balance + available seats.
- Navigation is imperative (`Navigator.push` / `pushReplacement`) rather than named routes.

## Conventions and data rules
- Roles are string literals: `'admin'` and `'user'`. Admin registration requires `AppConstants.adminCode`.
- Reuse `AppConstants` for colors, text styles, and snackbars instead of redefining UI constants.
- Firestore collections are `users`, `flights`, and `bookings`; key fields include `flightNumber`, `totalSeats`, and `availableSeats`.
- Flight `date`/`time` are stored as formatted strings; `createdAt`/`bookingDate` are Firestore timestamps.
- Booking flow checks balance and seat availability, then creates the booking, updates user balance, and decrements `availableSeats`.

## Environment and AI guidance (from GEMINI.md)
- Add dependencies with `flutter pub add <pkg>`; if code generation is introduced, run `dart run build_runner build --delete-conflicting-outputs`.
- For generative AI features, use `firebase_ai` and rely on Firebase initialization via `firebase_options.dart` (no hardcoded API keys).
- Firebase Studio workspace tooling and previews are defined in `.idx\dev.nix`.
