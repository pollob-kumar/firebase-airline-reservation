class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String flightId;
  final String flightNumber;
  final String from;
  final String to;
  final String date;
  final String time;
  final double price;
  final DateTime bookingDate;
  final DateTime? confirmedAt;
  final String status;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.flightId,
    required this.flightNumber,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.price,
    required this.bookingDate,
    this.confirmedAt,
    this.status = 'confirmed',
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      flightId: map['flightId'] ?? '',
      flightNumber: map['flightNumber'] ?? '',
      from: map['from'] ?? '',
      to: map['to'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      bookingDate: map['bookingDate']?.toDate() ?? DateTime.now(),
      confirmedAt: map['confirmedAt']?.toDate(),
      status: map['status'] ?? 'confirmed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'flightId': flightId,
      'flightNumber': flightNumber,
      'from': from,
      'to': to,
      'date': date,
      'time': time,
      'price': price,
      'bookingDate': bookingDate,
      if (confirmedAt != null) 'confirmedAt': confirmedAt,
      'status': status,
    };
  }
}
