# Software Design Document (SDD)
## Airline Reservation System (Flutter + Firebase)
**Version:** 1.1  
**Date:** 2025

---

## 1. Architecture Overview

```
┌─────────────────────────────────────┐
│          Flutter Frontend           │
│  (Login / Registration / Dashboards)│
└────────────────┬────────────────────┘
                 │
       ┌─────────▼──────────┐
       │   Firebase Services │
       ├────────────────────┤
       │ Firebase Auth      │  ← Login / Registration
       │ Cloud Firestore    │  ← All data storage
       │ Cloud Functions    │  ← Secure transaction (optional)
       └────────────────────┘
```

**State Management:** Provider / Riverpod (recommended)  
**Pattern:** MVC or Clean Architecture  

---

## 2. Data Model (Firestore Collections)

### 2.1 `users` Collection
```
users/
  └─ {userId}         (doc id = Firebase Auth UID)
       ├─ name         : String
       ├─ number       : String
       ├─ email        : String
       ├─ role         : String  ("user" | "admin")
       └─ balance      : Number  (only for role="user")
```

### 2.2 `flights` Collection
```
flights/
  └─ {flightId}       (auto-generated doc id)
       ├─ flightName   : String
       ├─ from         : String
       ├─ to           : String
       ├─ date         : String
       ├─ time         : String
       ├─ price        : Number
       └─ seatsAvailable : Number
```

### 2.3 `tickets` Collection
```
tickets/
  └─ {ticketId}       (auto-generated doc id)
       ├─ userId       : String
       ├─ userName     : String
       ├─ userEmail    : String
       ├─ flightId     : String
       ├─ flightName   : String
       ├─ from         : String
       ├─ to           : String
       ├─ price        : Number
       └─ purchaseDate : Timestamp
```
> ⚠️ `userName` and `userEmail` have been denormalized — Admin Dashboard will work without an extra query to show user details in the income table.

### 2.4 `adminStats` Collection *(NEW — Income Tracking)*
```
adminStats/
  └─ global           (single doc)
       ├─ totalIncome  : Number
       └─ lastUpdated  : Timestamp
```
> 💡 প্রতিটি ticket purchase-এ এই document update হবে। সব ticket aggregate না করে একটি field থেকেই total income পাওয়া যাবে — efficient এবং real-time।

### 2.5 `transactions` Collection *(Optional — Audit Log)*
```
transactions/
  └─ {transactionId}
       ├─ userId       : String
       ├─ type         : String  ("add_balance" | "buy_ticket")
       ├─ amount       : Number
       └─ date         : Timestamp
```

---

## 3. Module Design

### 3.1 Authentication Module (`auth_service.dart`)

| Function | Description |
|----------|-------------|
| `loginUser(email, password)` | Firebase Auth sign-in, role check করে dashboard redirect |
| `registerUser(...)` | User registration with role="user" |
| `registerAdmin(...)` | Hidden code "235857" verify করে Admin registration |
| `logout()` | Firebase sign-out |

> ⚠️ **Security Note:** It is unsafe to validate hidden code only on the client side. In production, you should validate it server-side with Firebase Cloud Functions — even if you decompile the APK, the code will not be exposed.

### 3.2 Admin Module

| Function | Description |
|----------|-------------|
| `addFlight(flightData)` | Firestore, new flight document create |
| `deleteFlight(flightId)` | Flight document delete |
| `getIncomeReport()` | `tickets` collection + `adminStats/global` to income data fetch |

### 3.3 User Module

| Function | Description |
|----------|-------------|
| `addBalance(userId, amount)` | User document-এ balance update |
| `getBalance(userId)` | User balance read |
| `getAvailableFlights()` | `flights` collection to seatsAvailable > 0 filter list |
| `buyTicket(userId, flightId)` | Atomic transaction — below details |

---

## 4. Transaction Flow — Buy Ticket (CRITICAL)

The ticket buy operation must be done with **`runTransaction()`** — so that all operations are atomic.

```
Step 1: User balance check 
         └─ balance < flight.price → throw "Insufficient Balance"

Step 2: Flight seatsAvailable check 
         └─ seatsAvailable <= 0 → throw "Flight Full"

Step 3: User balance deduct 
         └─ users/{userId}.balance -= flight.price

Step 4: Flight seat 
         └─ flights/{flightId}.seatsAvailable -= 1

Step 5: Ticket document create 
         └─ tickets/{newId} = { userId, flightId, price, ... }

Step 6: Admin total income update 
         └─ adminStats/global.totalIncome += flight.price

Step 7: Transaction log (optional)
         └─ transactions/{newId} = { userId, type="buy_ticket", amount }
```

> ✅ All steps will succeed together or all will be rolled back — there will be no data inconsistency.

---

## 5. UI Screens

### 5.1 Login Screen
- Email field, Password field
- Login button
- "Go to Registration" link

### 5.2 Registration Screen
- User / Admin toggle selector
- Common fields: Name, Number, Email, Password
- Admin extra field: Hidden Code input (obscured)
- Validation feedback

### 5.3 Admin Dashboard
- **Add Flight Tab:** Flight details form (name, from, to, date, time, price, seats)
- **Flight List Tab:** List with delete button per flight
- **Income Report Tab:** Table with columns — User Name, Email, Flight, Price, Date; Total Income summary at bottom

### 5.4 User Dashboard
- **Balance Section:** Current balance display + Add Balance button
- **Flights Section:** Available flights list (price, seats, route)
- **Buy Ticket:** Flight select → confirm purchase → success/error feedback

---

## 6. Security Design

### 6.1 Firestore Security Rules (Outline)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // User can only read/write own profile
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    // Flights: anyone authenticated can read; only admin can write
    match /flights/{flightId} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }

    // Tickets: authenticated user can create; admin can read all
    match /tickets/{ticketId} {
      allow create: if request.auth != null;
      allow read: if isAdmin() || resource.data.userId == request.auth.uid;
    }

    // Admin stats: only admin can read/write
    match /adminStats/{doc} {
      allow read, write: if isAdmin();
    }

    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### 6.2 Admin Role Security
| Approach | Risk Level | Recommendation |
|----------|-----------|----------------|
| Client-side hidden code only | 🔴 High (APK decompile) | Dev/demo only |
| Firestore role field check | 🟡 Medium | Acceptable for academic project |
| Cloud Function server-side verify | 🟢 Low | Production recommended |

---

## 7. Error Handling

| Error | Handling |
|-------|---------|
| Invalid login credentials | Firebase error → user-friendly message |
| Wrong hidden code | Registration block + error snackbar |
| Insufficient balance | Transaction abort + "Insufficient Balance" dialog |
| Flight full (seats = 0) | Purchase block + "Flight Full" message |
| Network error | Catch exception → retry prompt |
| Concurrent buy (race condition) | `runTransaction()` handles automatically |

---

## 8. State Management

**Recommended: Provider or Riverpod**

| Provider | Responsibility |
|----------|---------------|
| `AuthProvider` | Login state, current user, role |
| `FlightProvider` | Flights list, add/delete operations |
| `UserProvider` | Balance, ticket history |
| `AdminStatsProvider` | Total income, income report data |

---

## 9. pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest
  firebase_auth: ^latest
  cloud_firestore: ^latest
  provider: ^latest          # state management
  # OR riverpod: ^latest
  intl: ^latest              # date formatting
  uuid: ^latest              # ticket ID generation (optional)
```

---

## 10. Future Enhancements
- Seat selection UI
- Real payment gateway (SSLCommerz for Bangladesh)
- Email ticket confirmation (Firebase Email Extension)
- Flight search and filter
- User booking history screen
- Push notifications for flight updates
