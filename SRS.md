# Software Requirements Specification (SRS)
## Airline Reservation System (Flutter + Firebase)
**Version:** 1.2  
**Date:** 2026

---

## 1. Introduction

### 1.1 Purpose
This document defines the requirements for a Flutter + Firebase airline reservation system. The system supports distinct user and admin roles with separate authentication flows and dashboards. Users search and book flights using a virtual balance, while admins manage flights, bookings, and income reporting.

### 1.2 Scope
- User login and registration
- Admin login and registration (requires a hidden admin code)
- Flight management (add, delete, seat inventory)
- Booking lifecycle (request, confirm, cancel)
- Income reporting and notifications
- User balance management

### 1.3 Definitions
| Term | Meaning |
|------|---------|
| User | Customer who searches and books flights |
| Admin | Staff role that manages flights and bookings |
| Hidden Code | Admin registration code required to create admin accounts |
| Balance | Virtual wallet used for booking |
| Booking | Reservation record created when a user books a flight |

---

## 2. Overall Description

### 2.1 Product Perspective
- **Frontend:** Flutter (Android / iOS / Web)
- **Backend:** Firebase Authentication + Cloud Firestore
- **Optional:** Firebase Cloud Functions (for stronger security in production)

### 2.2 User Classes
| Role | Access |
|------|--------|
| User | Registration, Login, Balance, Flight Search, Booking |
| Admin | Registration (with hidden code), Login, Flight Management, Booking Review, Income Report |

### 2.3 Constraints
- Requires internet connectivity
- Firebase project must be configured
- Supports Flutter target platforms (Android/iOS/Web)
- Firestore is the primary data store

---

## 3. Functional Requirements

### 3.1 Authentication
| ID | Requirement |
|----|-------------|
| FR-1 | Users and admins can sign in using email and password. |
| FR-2 | User registration fields: Name, Phone, Email, Password. |
| FR-3 | Admin registration fields: Name, Phone, Email, Password, Hidden Code. |
| FR-4 | Admin registration must fail if the hidden code is incorrect. |
| FR-5 | Email must be a valid format (e.g., user@example.com). |
| FR-6 | Password minimum length is 6 characters. |
| FR-7 | On login, users are routed to the correct dashboard based on role. |

### 3.2 Admin Dashboard
| ID | Requirement |
|----|-------------|
| FR-8 | Admin can add new flights. |
| FR-9 | Admin can delete flights. |
| FR-10 | Admin can view all bookings and booking status. |
| FR-11 | Admin can confirm or cancel bookings. |
| FR-12 | Total income is calculated from confirmed bookings. |
| FR-13 | Admin can view notifications for bookings and user activity. |
| FR-14 | Admin can view user accounts and disable or enable access. |

### 3.3 User Dashboard
| ID | Requirement |
|----|-------------|
| FR-15 | User can add balance manually (simulation). |
| FR-16 | User can view current balance. |
| FR-17 | User can browse available flights and search by filters. |
| FR-18 | User can book a flight if balance and seats are sufficient. |
| FR-19 | Seat inventory decreases by one when a booking is created. |
| FR-20 | Booking is blocked if no seats are available. |
| FR-21 | Users can view booking history and request cancellation. |
| FR-22 | Users can view notifications related to bookings. |

---

## 4. Non-Functional Requirements
| ID | Requirement |
|----|-------------|
| NFR-1 | Firestore Security Rules must restrict unauthorized access. |
| NFR-2 | Booking operations must use Firestore transactions to keep balance and seats consistent. |
| NFR-3 | Major operations should complete within 3 seconds under normal conditions. |
| NFR-4 | UI must be user-friendly and mobile responsive. |
| NFR-5 | Hidden admin code must be verified server-side for production deployments. |

---

## 5. External Interface Requirements
| Interface | Detail |
|-----------|--------|
| UI | Flutter screens for login, registration, admin dashboard, user dashboard |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |

---

## 6. Validation Rules
| Field | Rule |
|-------|------|
| Email | Valid email format required |
| Password | Minimum 6 characters |
| Hidden Code | Must match the configured admin code |
| Balance Add | Must be a positive number |
| Booking | Balance ≥ price and availableSeats ≥ 1 |

---

## 7. Error Handling Requirements
| Scenario | Expected Behavior |
|----------|-------------------|
| Invalid login credentials | Show a user-friendly error message |
| Wrong hidden code | Show "Invalid Admin Code" |
| Insufficient balance | Show "Insufficient Balance" |
| No seats available | Show "No seats available" |
| Network error | Show a generic retry message |

---

## 8. Assumptions
- Balance is virtual (no payment gateway in v1).
- Firebase project and rules are configured before runtime.
- Internet connectivity is required for all data operations.

---

## 9. Future Enhancements
- Seat selection
- Real payment gateway integration
- Email ticket confirmation
- Advanced flight search and filters
- User booking history export
