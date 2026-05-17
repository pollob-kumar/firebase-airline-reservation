class FlightModel {
  final String id;
  final String flightNumber;
  final String from;
  final String to;
  final String date;
  final String time;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final DateTime createdAt;

  FlightModel({
    required this.id,
    required this.flightNumber,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.createdAt,
  });

  factory FlightModel.fromMap(Map<String, dynamic> map, String id) {
    return FlightModel(
      id: id,
      flightNumber: map['flightNumber'] ?? '',
      from: map['from'] ?? '',
      to: map['to'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      totalSeats: map['totalSeats'] ?? 0,
      availableSeats: map['availableSeats'] ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flightNumber': flightNumber,
      'from': from,
      'to': to,
      'date': date,
      'time': time,
      'price': price,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'createdAt': createdAt,
    };
  }
}
