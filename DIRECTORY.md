# Project Directory Structure
## Airline Reservation System (Flutter + Firebase)
**Version:** 1.1

---

## Full Directory Tree

```
airline_reservation_system/
│
├─ lib/
│  ├─ main.dart                        # App entry point, Firebase init
│  ├─ app.dart                         # MaterialApp + theme setup
│  │
│  ├─ routes/
│  │  └─ app_routes.dart               # Named routes definition
│  │
│  ├─ models/
│  │  ├─ user_model.dart               # UserModel (name, email, role, balance)
│  │  ├─ flight_model.dart             # FlightModel (name, from, to, price, seats)
│  │  └─ ticket_model.dart             # TicketModel (userId, flightId, price, date)
│  │
│  ├─ services/
│  │  ├─ auth_service.dart             # Firebase Auth (login, register, logout)
│  │  ├─ firestore_service.dart        # Firestore CRUD operations
│  │  └─ transaction_service.dart      # runTransaction() for ticket buy
│  │
│  ├─ providers/                       # ★ NEW — State Management (Provider/Riverpod)
│  │  ├─ auth_provider.dart            # Login state, current user, role
│  │  ├─ flight_provider.dart          # Flights list, add/delete
│  │  ├─ user_provider.dart            # Balance, user data
│  │  └─ admin_stats_provider.dart     # Total income, income report
│  │
│  ├─ screens/
│  │  ├─ login_screen.dart             # Email + Password login
│  │  ├─ registration_screen.dart      # User/Admin registration (role toggle)
│  │  │
│  │  ├─ admin_dashboard/
│  │  │  ├─ admin_home.dart            # Admin main shell (bottom nav / tabs)
│  │  │  ├─ add_flight.dart            # Add flight form screen
│  │  │  ├─ admin_flight_list.dart     # Flight list with delete (admin view)
│  │  │  └─ income_report.dart         # Total income table screen
│  │  │
│  │  └─ user_dashboard/
│  │     ├─ user_home.dart             # User main shell (bottom nav / tabs)
│  │     ├─ balance_add.dart           # Add balance screen
│  │     ├─ balance_check.dart         # Show current balance
│  │     ├─ buy_ticket.dart            # Ticket purchase screen
│  │     └─ flight_search.dart         # Available flights list (user view)
│  │
│  ├─ widgets/
│  │  ├─ common/                       # ★ Shared widgets
│  │  │  ├─ flight_card.dart           # Reusable flight card (used in admin + user)
│  │  │  ├─ primary_button.dart        # Reusable styled button
│  │  │  └─ input_field.dart           # Reusable text input field
│  │  │
│  │  ├─ admin/
│  │  │  └─ income_table_row.dart      # Income report table row widget
│  │  │
│  │  └─ user/
│  │     └─ balance_card.dart          # Balance display widget
│  │
│  ├─ utils/
│  │  ├─ constants.dart                # App-wide constants (see note below ⚠️)
│  │  └─ validators.dart               # Form validation functions
│  │
│  └─ firebase_options.dart            # ★ NEW — FlutterFire CLI auto-generated
│
├─ assets/
│  ├─ images/                          # App images (logo, banner, etc.)
│  └─ icons/                           # Custom icons
│
├─ pubspec.yaml                        # Dependencies (firebase_core, cloud_firestore, etc.)
├─ .firebaserc                         # Firebase project config
├─ firestore.rules                     # Firestore Security Rules
└─ README.md                           # Project documentation
```

---

## Key File Responsibilities

### `constants.dart` ⚠️ Security Note
```dart
// constants.dart

class AppConstants {
  // Routes
  static const String loginRoute = '/login';
  static const String adminDashboard = '/admin';
  static const String userDashboard = '/user';

  // Roles
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';

  // ⚠️ WARNING: Hidden code রাখা client-side UNSAFE in production
  // Academic/demo project-এর জন্য acceptable
  // Production-এ Cloud Function দিয়ে server-side verify করো
  static const String adminHiddenCode = '235857';

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String flightsCollection = 'flights';
  static const String ticketsCollection = 'tickets';
  static const String adminStatsDoc = 'adminStats/global';
}
```

### `validators.dart`
```dart
// validators.dart

class Validators {
  static String? email(String? value) {
    if (value == null || !value.contains('@')) return 'Valid email required';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 6) return 'Min 6 characters required';
    return null;
  }

  static String? adminCode(String? value) {
    if (value != AppConstants.adminHiddenCode) return 'Invalid Admin Code';
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || double.tryParse(value) == null || double.parse(value) <= 0)
      return 'Enter a valid positive amount';
    return null;
  }
}
```

---

## Why Two Separate Flight List Screens?

| Screen | Purpose |
|--------|---------|
| `admin_flight_list.dart` | Delete button আছে, admin actions |
| `flight_search.dart` | Buy ticket button আছে, user actions |

> ✅ দুটো screen আলাদা রাখা ভালো কারণ admin এবং user-এর actions এবং UI সম্পূর্ণ আলাদা। শুধু flight card widget (`flight_card.dart`) common/shared রাখা হয়েছে।

---

## pubspec.yaml (Core Dependencies)

```yaml
name: airline_reservation_system
description: Airline Reservation System - Flutter + Firebase

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0

  # State Management
  provider: ^6.1.0
  # or: flutter_riverpod: ^2.5.0

  # Utilities
  intl: ^0.19.0           # Date formatting
  uuid: ^4.4.0            # Unique ID generation

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

---

## Firestore Setup Checklist

- [ ] Firebase project create করো console.firebase.google.com-এ
- [ ] Flutter app add করো (Android/iOS/Web)
- [ ] `flutterfire configure` run করো → `firebase_options.dart` generate হবে
- [ ] Firestore database enable করো (production mode recommended)
- [ ] `firestore.rules` file-এ security rules deploy করো
- [ ] `pubspec.yaml`-এ সব dependencies add করে `flutter pub get` run করো
