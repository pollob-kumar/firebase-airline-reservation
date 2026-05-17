# Software Requirements Specification (SRS)
## Airline Reservation System (Flutter + Firebase)
**Version:** 1.1  
**Date:** 2025

---

## 1. Introduction

### 1.1 Purpose
Flutter + Firebase দিয়ে একটি Airline Reservation System তৈরি করা হবে। System-এ User এবং Admin — দুজনের জন্য আলাদা Login/Registration থাকবে। Admin flight manage করবে এবং total income track করবে। User balance manage করে ticket buy করবে।

### 1.2 Scope
- User Login / Registration
- Admin Login / Registration (Hidden Code "235857" required)
- Admin Dashboard: Flight add/delete, total income check
- User Dashboard: Balance add/check, available flights check, ticket buy

### 1.3 Definitions

| Term | Meaning |
|------|---------|
| User | Normal customer যে flight ticket buy করে |
| Admin | Flight management ও income monitoring এর full access আছে |
| Hidden Code | Admin registration-এ "235857" না দিলে registration হবে না |
| Balance | User-এর in-app virtual currency (demo purpose) |
| Ticket | Purchased flight booking record |

---

## 2. Overall Description

### 2.1 Product Perspective
- **Frontend:** Flutter (Android / iOS / Web)
- **Backend:** Firebase Authentication + Firestore
- **Optional:** Firebase Cloud Functions (secure transaction handling)

### 2.2 User Classes

| Role | Access |
|------|--------|
| User | Registration, Login, Balance Management, Flight View, Ticket Purchase |
| Admin | Registration (with hidden code), Login, Flight Management, Income Report |

### 2.3 Constraints
- Internet connection required
- Firebase project properly configured হতে হবে
- Flutter supported platform (Android / iOS / Web)
- Firebase Authentication used for login system
- Firestore used for all data storage

---

## 3. Functional Requirements

### 3.1 Authentication

| ID | Requirement |
|----|-------------|
| FR-1 | User এবং Admin উভয়ই email + password দিয়ে login করতে পারবে। |
| FR-2 | User registration fields: Name, Phone Number, Email, Password. |
| FR-3 | Admin registration fields: Name, Phone Number, Email, Password, Hidden Code. |
| FR-4 | Hidden Code "235857" না দিলে Admin registration সম্পন্ন হবে না। |
| FR-5 | Email অবশ্যই valid format হতে হবে (e.g., user@example.com)। |
| FR-6 | Password minimum 6 characters হতে হবে। |
| FR-7 | Login-এর সময় role (user/admin) অনুযায়ী আলাদা dashboard-এ redirect হবে। |

### 3.2 Admin Dashboard

| ID | Requirement |
|----|-------------|
| FR-8 | Admin নতুন flight add করতে পারবে। |
| FR-9 | Admin যেকোনো flight delete করতে পারবে। |
| FR-10 | Admin total income দেখতে পারবে — table আকারে, প্রতিটি ticket purchase-এর user details সহ। |
| FR-11 | User কোনো ticket buy করলে সেই amount automatically Admin-এর total income-এ যোগ হবে। |

### 3.3 User Dashboard

| ID | Requirement |
|----|-------------|
| FR-12 | User manually balance add করতে পারবে (demo/simulation purpose)। |
| FR-13 | User নিজের current balance দেখতে পারবে। |
| FR-14 | User available flights-এর list দেখতে পারবে। |
| FR-15 | User ticket buy করতে পারবে — buy করলে price amount balance থেকে deduct হবে। |
| FR-16 | Ticket buy-এর সময় user-এর balance, flight-এর price এর চেয়ে কম হলে purchase block হবে। |
| FR-17 | Ticket buy করলে সেই flight-এর `seatsAvailable` count ১ কমবে। |
| FR-18 | কোনো flight-এর `seatsAvailable = 0` হলে সেই flight-এ ticket buy করা যাবে না। |

---

## 4. Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-1 | Firestore Security Rules দিয়ে data unauthorized access থেকে protect করতে হবে। |
| NFR-2 | Ticket buy operation অবশ্যই atomic transaction (runTransaction) দিয়ে করতে হবে — যাতে balance, seat, ticket একসাথে consistent থাকে। |
| NFR-3 | App response time acceptable হতে হবে (major operations < 3 seconds)। |
| NFR-4 | UI user-friendly এবং mobile-responsive হতে হবে। |
| NFR-5 | Admin Hidden Code client-side hardcode করা নিরাপদ নয় — production-এ Cloud Function বা Firestore server-side verification recommended। |

---

## 5. External Interface Requirements

| Interface | Detail |
|-----------|--------|
| UI | Flutter Screens: Login, Registration, Admin Dashboard, User Dashboard |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Optional | Firebase Cloud Functions |

---

## 6. Validation Rules

| Field | Rule |
|-------|------|
| Email | Valid email format required |
| Password | Minimum 6 characters |
| Hidden Code | Must be exactly "235857" for Admin registration |
| Balance Add | Must be a positive number |
| Ticket Buy | User balance ≥ flight price AND seatsAvailable ≥ 1 |

---

## 7. Error Handling Requirements

| Scenario | Expected Behavior |
|----------|-------------------|
| Wrong login credentials | Error message দেখাবে |
| Wrong hidden code | "Invalid Admin Code" message দেখাবে |
| Insufficient balance | "Insufficient Balance" message দেখাবে |
| No seats available | "Flight Full" message দেখাবে |
| Network error | User-friendly error message দেখাবে |

---

## 8. Assumptions
- User balance addition is simulated (no real payment gateway in v1.0).
- Firebase project is pre-configured.
- App targets Android/iOS/Web platforms.
- Internet connection is always required.

---

## 9. Future Enhancements
- Seat selection feature
- Real payment gateway integration (SSLCommerz / Stripe)
- Email ticket confirmation
- Flight search and filter
- Booking history for users
