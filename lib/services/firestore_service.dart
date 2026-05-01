import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/flight_model.dart';
import '../models/booking_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // User Operations
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  Future<void> updateUserProfile({
    required String uid,
    required String name,
  }) async {
    await _db.collection('users').doc(uid).update({'name': name});
  }

  Future<void> disableUser({
    required String uid,
    required String reason,
  }) async {
    await _db.collection('users').doc(uid).update({
      'status': 'disabled',
      'disabledReason': reason,
      'disabledAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> enableUser(String uid) async {
    await _db.collection('users').doc(uid).update({
      'status': 'active',
      'disabledReason': null,
      'disabledAt': null,
    });
  }

  Stream<List<UserModel>> getUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateBalance(String uid, double newBalance) async {
    await _db.collection('users').doc(uid).update({'balance': newBalance});
  }

  // Flight Operations
  Future<void> addFlight(FlightModel flight) async {
    await _db.collection('flights').add(flight.toMap());
  }

  Stream<List<FlightModel>> getFlights() {
    return _db
        .collection('flights')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FlightModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<FlightModel>> getAvailableFlights() {
    return _db
        .collection('flights')
        .where('availableSeats', isGreaterThan: 0)
        .orderBy('availableSeats', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FlightModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> deleteFlight(String flightId) async {
    await _db.collection('flights').doc(flightId).delete();
  }

  Future<void> updateFlightSeats(String flightId, int newAvailableSeats) async {
    await _db.collection('flights').doc(flightId).update({
      'availableSeats': newAvailableSeats,
    });
  }

  // Booking Operations
  Future<void> bookFlight({
    required String userId,
    required String flightId,
  }) async {
    final userRef = _db.collection('users').doc(userId);
    final flightRef = _db.collection('flights').doc(flightId);
    final bookingRef = _db.collection('bookings').doc();
    final notificationRef = _db.collection('notifications').doc();

    await _db.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw Exception('User not found');
      }

      final flightSnapshot = await transaction.get(flightRef);
      if (!flightSnapshot.exists) {
        throw Exception('Flight not found');
      }

      final userData = userSnapshot.data()!;
      final flightData = flightSnapshot.data()!;

      final balance = (userData['balance'] ?? 0).toDouble();
      final price = (flightData['price'] ?? 0).toDouble();
      final availableSeats = (flightData['availableSeats'] ?? 0) as num;

      if (balance < price) {
        throw Exception('Insufficient balance');
      }
      if (availableSeats <= 0) {
        throw Exception('No seats available');
      }

      transaction.update(userRef, {'balance': balance - price});
      transaction.update(flightRef, {
        'availableSeats': availableSeats.toInt() - 1,
      });
      transaction.set(bookingRef, {
        'userId': userId,
        'userName': userData['name'] ?? '',
        'userEmail': userData['email'] ?? '',
        'userPhone': userData['phone'] ?? '',
        'flightId': flightId,
        'flightNumber': flightData['flightNumber'] ?? '',
        'from': flightData['from'] ?? '',
        'to': flightData['to'] ?? '',
        'date': flightData['date'] ?? '',
        'time': flightData['time'] ?? '',
        'price': price,
        'bookingDate': DateTime.now(),
        'status': 'pending',
      });

      transaction.set(notificationRef, {
        'title': 'New booking request',
        'message':
            '${userData['name'] ?? 'A user'} requested ${flightData['flightNumber'] ?? 'a flight'}',
        'type': 'booking_request',
        'bookingId': bookingRef.id,
        'targetRole': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    });
  }

  Future<void> confirmBooking(String bookingId) async {
    final bookingRef = _db.collection('bookings').doc(bookingId);
    final adminStatsRef = _db.collection('adminStats').doc('global');
    final notificationRef = _db.collection('notifications').doc();

    await _db.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);
      if (!bookingSnapshot.exists) {
        throw Exception('Booking not found');
      }

      final bookingData = bookingSnapshot.data()!;
      final status = (bookingData['status'] ?? 'pending').toString();
      if (status.toLowerCase() == 'confirmed') {
        return;
      }
      if (status.toLowerCase() == 'cancelled') {
        throw Exception('Cancelled bookings cannot be confirmed');
      }

      final double price = (bookingData['price'] ?? 0).toDouble();
      final String userId = bookingData['userId'] ?? '';
      final String flightNumber = bookingData['flightNumber'] ?? 'your flight';

      transaction.update(bookingRef, {
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(adminStatsRef, {
        'totalIncome': FieldValue.increment(price),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      transaction.set(notificationRef, {
        'title': 'Booking confirmed',
        'message': 'Your ticket for $flightNumber has been confirmed.',
        'type': 'booking_confirmed',
        'bookingId': bookingId,
        'recipientId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    });
  }

  Future<void> cancelBookingByAdmin({
    required String bookingId,
    String? reason,
  }) async {
    final bookingRef = _db.collection('bookings').doc(bookingId);
    final adminStatsRef = _db.collection('adminStats').doc('global');
    final notificationRef = _db.collection('notifications').doc();

    await _db.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);
      if (!bookingSnapshot.exists) {
        throw Exception('Booking not found');
      }

      final bookingData = bookingSnapshot.data()!;
      final status = (bookingData['status'] ?? 'confirmed').toString();
      if (status.toLowerCase() == 'cancelled') {
        return;
      }

      final String userId = bookingData['userId'] ?? '';
      final String flightId = bookingData['flightId'] ?? '';
      final String flightNumber = bookingData['flightNumber'] ?? 'your flight';
      final double price = (bookingData['price'] ?? 0).toDouble();

      final userRef = _db.collection('users').doc(userId);
      final flightRef = _db.collection('flights').doc(flightId);

      final userSnapshot = await transaction.get(userRef);
      final flightSnapshot = await transaction.get(flightRef);
      if (!userSnapshot.exists || !flightSnapshot.exists) {
        throw Exception('Unable to process cancellation');
      }

      final currentBalance = (userSnapshot.data()!['balance'] ?? 0).toDouble();
      final currentSeats = (flightSnapshot.data()!['availableSeats'] ?? 0) as num;

      transaction.update(userRef, {'balance': currentBalance + price});
      transaction.update(flightRef, {
        'availableSeats': currentSeats.toInt() + 1,
      });

      transaction.update(bookingRef, {
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        if (reason != null && reason.trim().isNotEmpty)
          'cancelReason': reason.trim(),
      });

      if (status.toLowerCase() == 'confirmed') {
        transaction.set(adminStatsRef, {
          'totalIncome': FieldValue.increment(-price),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      transaction.set(notificationRef, {
        'title': 'Booking cancelled',
        'message': 'Your booking for $flightNumber has been cancelled.',
        'type': 'booking_cancelled',
        'bookingId': bookingId,
        'recipientId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    });
  }

  Future<void> requestBookingCancellation(String bookingId) async {
    final bookingRef = _db.collection('bookings').doc(bookingId);
    final notificationRef = _db.collection('notifications').doc();

    await _db.runTransaction((transaction) async {
      final bookingSnapshot = await transaction.get(bookingRef);
      if (!bookingSnapshot.exists) {
        throw Exception('Booking not found');
      }

      final bookingData = bookingSnapshot.data()!;
      final status = (bookingData['status'] ?? 'confirmed').toString();
      if (status.toLowerCase() != 'confirmed') {
        throw Exception('Only confirmed bookings can be cancelled');
      }

      final String userName = bookingData['userName'] ?? 'A user';
      final String flightNumber = bookingData['flightNumber'] ?? 'a flight';

      transaction.update(bookingRef, {
        'status': 'cancel_requested',
        'cancelRequestedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(notificationRef, {
        'title': 'Cancellation request',
        'message': '$userName requested cancellation for $flightNumber.',
        'type': 'cancel_request',
        'bookingId': bookingId,
        'targetRole': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
    });
  }

  Future<void> createBooking(BookingModel booking) async {
    await _db.collection('bookings').add(booking.toMap());
  }

  Stream<double?> getTotalIncome() {
    return _db.collection('adminStats').doc('global').snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      final data = doc.data();
      final totalIncome = data?['totalIncome'];
      if (totalIncome is num) {
        return totalIncome.toDouble();
      }
      return null;
    });
  }

  Stream<List<BookingModel>> getAllBookings() {
    return _db
        .collection('bookings')
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList();
          bookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));
          return bookings;
        });
  }

  Stream<BookingModel?> getBookingById(String bookingId) {
    return _db.collection('bookings').doc(bookingId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return BookingModel.fromMap(doc.data()!, doc.id);
    });
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<NotificationModel>> getAdminNotifications() {
    return _db
        .collection('notifications')
        .where('targetRole', isEqualTo: 'admin')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _db
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  Stream<Map<String, dynamic>> getAdminSettings() {
    return _db
        .collection('adminSettings')
        .doc('global')
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  Future<void> updateAdminSettings(Map<String, dynamic> settings) async {
    await _db
        .collection('adminSettings')
        .doc('global')
        .set(settings, SetOptions(merge: true));
  }
}
