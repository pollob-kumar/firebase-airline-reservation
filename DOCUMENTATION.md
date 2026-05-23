# Project Documentation

## Project Overview
This Flutter application provides an airline reservation workflow built on Firebase. Users can search for flights, manage their balance, and book tickets. Admins can manage flights, review and confirm or cancel bookings, monitor income, and manage user accounts. Data persistence and real-time updates are handled with Cloud Firestore, and authentication uses Firebase Auth.

## Core Functionalities
### Authentication and Roles
- Email/password sign-in and registration.
- Role-based routing for admin and user experiences.
- Admin registration requires the hidden code from `AppConstants.adminCode` (default `235857`).

### Admin Capabilities
- Flight management: add and delete flights.
- Booking oversight: view all bookings, confirm or cancel bookings.
- Income reporting based on confirmed bookings.
- User account management, including enable/disable status.
- Admin notifications and settings.

### User Capabilities
- Search and browse available flights with filters (origin, destination, date, passengers).
- Book flights with balance and seat availability checks.
- Add balance and check current balance.
- View booking history and upcoming trips.
- Request booking cancellations.
- User notifications, settings, frequent flyer page, and support page.

### System Behavior
- Booking flow uses Firestore transactions to keep balances and seat counts consistent.
- Notifications are generated for both admin and user events (new booking, confirmation, cancellation).
- Booking statuses include `pending`, `confirmed`, `cancel_requested`, and `cancelled`.

## Project Structure
- `lib/main.dart`: App entry point, Firebase initialization, global theme.
- `lib/auth/`: Login and registration screens plus `AuthService`.
- `lib/models/`: Firestore data models (`UserModel`, `FlightModel`, `BookingModel`, `NotificationModel`).
- `lib/services/`: `FirestoreService` (data access layer) and `constants.dart`.
- `lib/screens/admin/`: Admin dashboard, flight management, booking overview, income report, user accounts, notifications, and settings.
- `lib/screens/user/`: User dashboard, available flights, add balance, booking confirmation, notifications, settings, frequent flyer, support.
- `android/`, `web/`, `test/`: Platform and test targets.

## API Documentation
This project does not expose a public HTTP API. The "API" is the internal service layer plus the Firestore schema.

### Firebase Auth (AuthService)
- `login(email, password) -> UserModel?`  
  Signs in with Firebase Auth and loads the user profile from Firestore.
- `register(name, email, phone, password, role) -> UserModel?`  
  Creates a Firebase Auth user, writes a user profile to Firestore, and notifies admins.
- `logout()`  
  Signs out the current user.
- `updateDisplayName(name)`  
  Updates the Firebase Auth display name.
- `updatePassword(currentPassword, newPassword)`  
  Reauthenticates and updates password.

### Firestore Collections and Fields
| Collection | Purpose | Key Fields |
| --- | --- | --- |
| `users` | User profiles and roles | `name`, `email`, `phone`, `role`, `balance`, `createdAt`, `status`, `disabledReason` |
| `flights` | Flight inventory | `flightNumber`, `from`, `to`, `date`, `time`, `price`, `totalSeats`, `availableSeats`, `createdAt` |
| `bookings` | Booking records | `userId`, `userName`, `userEmail`, `userPhone`, `flightId`, `flightNumber`, `from`, `to`, `date`, `time`, `price`, `bookingDate`, `status`, `confirmedAt`, `cancelRequestedAt`, `cancelledAt`, `cancelReason` |
| `notifications` | Admin and user notifications | `title`, `message`, `type`, `bookingId`, `recipientId`, `targetRole`, `createdAt`, `read` |
| `adminStats` | Income tracking | `totalIncome`, `lastUpdated` |
| `adminSettings` | Admin configuration | dynamic settings fields |

Notes:
- `date` and `time` are stored as formatted strings.
- `createdAt` and `bookingDate` are stored as Firestore timestamps (or `DateTime` in the model).
- Roles are string literals: `admin` and `user`.

### FirestoreService Methods
| Method | Description |
| --- | --- |
| `createUser(user)` | Create a user profile document. |
| `createAdminNotification(...)` | Add an admin-targeted notification. |
| `getUser(uid)` | Read a user profile by UID. |
| `updateUserProfile(uid, name)` | Update a user's display name. |
| `disableUser(uid, reason)` | Disable a user account with a reason and timestamp. |
| `enableUser(uid)` | Re-enable a disabled user account. |
| `getUsers()` | Stream all user accounts (sorted by `createdAt`). |
| `updateBalance(uid, newBalance)` | Update a user's balance. |
| `addFlight(flight)` | Add a new flight. |
| `getFlights()` | Stream all flights. |
| `getAvailableFlights()` | Stream flights where `availableSeats > 0`. |
| `deleteFlight(flightId)` | Delete a flight. |
| `updateFlightSeats(flightId, newAvailableSeats)` | Update seat inventory. |
| `bookFlight(userId, flightId)` | Transaction: check balance and seats, create booking, create admin notification. |
| `confirmBooking(bookingId)` | Transaction: mark confirmed, increment income, notify user. |
| `cancelBookingByAdmin(bookingId, reason)` | Transaction: refund balance, restore seat, update income, notify user. |
| `requestBookingCancellation(bookingId)` | Mark booking as cancellation requested and notify admin. |
| `createBooking(booking)` | Create a booking record (non-transactional helper). |
| `getTotalIncome()` | Stream total income from `adminStats/global`. |
| `getAllBookings()` | Stream all bookings (sorted by `bookingDate`). |
| `getUserBookings(userId)` | Stream bookings for a user. |
| `getBookingById(bookingId)` | Stream a single booking. |
| `getUserNotifications(userId)` | Stream notifications addressed to a user. |
| `getAdminNotifications()` | Stream notifications targeting admins. |
| `hasUnreadUserNotifications(userId)` | Stream a boolean for unread user notifications. |
| `hasUnreadAdminNotifications()` | Stream a boolean for unread admin notifications. |
| `markNotificationRead(notificationId)` | Mark a notification as read. |
| `getAdminSettings()` | Stream admin settings document. |
| `updateAdminSettings(settings)` | Update admin settings document. |
