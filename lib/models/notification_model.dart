class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? bookingId;
  final String? recipientId;
  final String? targetRole;
  final DateTime createdAt;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.read,
    this.bookingId,
    this.recipientId,
    this.targetRole,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? '',
      bookingId: map['bookingId'],
      recipientId: map['recipientId'],
      targetRole: map['targetRole'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      read: map['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'bookingId': bookingId,
      'recipientId': recipientId,
      'targetRole': targetRole,
      'createdAt': createdAt,
      'read': read,
    };
  }
}
