// models/reservation.dart
class Reservation {
  final int id;
  final int userId;
  final int mealId;
  final String status;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.mealId,
    required this.status,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['userId'],
      mealId: json['mealId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mealId': mealId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Reservation copyWith({
    int? id,
    int? userId,
    int? mealId,
    String? status,
    DateTime? createdAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mealId: mealId ?? this.mealId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reservation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Reservation(id: $id, userId: $userId, mealId: $mealId, status: $status, createdAt: $createdAt)';
  }
}
