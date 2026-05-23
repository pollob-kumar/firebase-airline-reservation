class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'user' or 'admin'
  final double balance;
  final DateTime createdAt;
  final String status; // 'active' or 'disabled'
  final String? disabledReason;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.balance = 0.0,
    required this.createdAt,
    this.status = 'active',
    this.disabledReason,
  });

  // Firestore theke data niye ashar jonno
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'user',
      balance: (map['balance'] ?? 0.0).toDouble(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'active',
      disabledReason: map['disabledReason'],
    );
  }

  // Firestore e data pathano jonno
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'balance': balance,
      'createdAt': createdAt,
      'status': status,
      'disabledReason': disabledReason,
    };
  }

  bool get isDisabled => status.toLowerCase() == 'disabled';
}
