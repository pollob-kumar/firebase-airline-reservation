# Project Directory Structure
## Airline Reservation System (Flutter + Firebase)
**Version:** 1.2

---

## Full Directory Tree
```
firebase-airline-reservation/
│
├─ lib/
│  ├─ main.dart                          # App entry point, Firebase init, theme
│  ├─ firebase_options.dart              # FlutterFire generated config
│  │
│  ├─ auth/
│  │  ├─ account_disabled_page.dart      # Disabled account screen
│  │  ├─ auth_service.dart               # Firebase Auth operations
│  │  ├─ login_page.dart                 # Login UI
│  │  └─ registration_page.dart          # Registration UI
│  │
│  ├─ models/
│  │  ├─ booking_model.dart              # Booking data model
│  │  ├─ flight_model.dart               # Flight data model
│  │  ├─ notification_model.dart         # Notification data model
│  │  └─ user_model.dart                 # User data model
│  │
│  ├─ services/
│  │  ├─ constants.dart                  # App constants, colors, snackbars
│  │  └─ firestore_service.dart          # Firestore CRUD and transactions
│  │
│  └─ screens/
│     ├─ admin/
│     │  ├─ add_flight_page.dart          # Add flight form
│     │  ├─ admin_dashboard.dart          # Admin landing dashboard
│     │  ├─ admin_notifications_page.dart # Admin notifications
│     │  ├─ admin_settings_page.dart      # Admin settings
│     │  ├─ booking_overview_page.dart    # Booking review and actions
│     │  ├─ income_report_page.dart       # Income report
│     │  └─ user_accounts_page.dart       # User management
│     │
│     └─ user/
│        ├─ add_balance_page.dart         # Add balance flow
│        ├─ available_flights_page.dart   # Flight list and booking
│        ├─ booking_confirmation_page.dart# Booking confirmation UI
│        ├─ frequent_flyer_page.dart      # Loyalty UI
│        ├─ support_page.dart             # Support UI
│        ├─ user_dashboard.dart           # User landing dashboard
│        ├─ user_notifications_page.dart  # User notifications
│        └─ user_settings_page.dart       # User settings
│
├─ android/                              # Android platform files
├─ web/                                  # Web platform files
├─ test/                                 # Flutter tests
│
├─ firestore.rules                       # Firestore security rules
├─ firebase.json                         # Firebase config
├─ pubspec.yaml                          # Dependencies
├─ README.md                             # Project overview
├─ DOCUMENTATION.md                      # Detailed project documentation
├─ SRS.md                                # Software requirements
├─ SDD.md                                # Software design document
└─ DIRECTORY.md                          # This file
```

---

## Key File Responsibilities

### `services/constants.dart`
Defines colors, typography, snackbars, and the admin registration code. Centralizes UI constants for consistent styling.

### `services/firestore_service.dart`
Single data-access layer for Firestore. Handles user profiles, flights, bookings, notifications, income tracking, and transactional booking updates.

### `auth/auth_service.dart`
Wraps Firebase Authentication for login, registration, logout, and account updates.

---

## Notes on Screen Separation
Admin and user screens are separated under `lib/screens/admin` and `lib/screens/user` to keep responsibilities and UI flows independent. Shared data logic lives in the services and models layers.
