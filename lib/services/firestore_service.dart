import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/flight_model.dart';
import '../models/booking_model.dart';

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
    final adminStatsRef = _db.collection('adminStats').doc('global');

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
        'status': 'confirmed',
      });

      transaction.set(adminStatsRef, {
        'totalIncome': FieldValue.increment(price),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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
