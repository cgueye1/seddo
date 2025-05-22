// models/reservation_model.dart
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/models/user_model.dart';

class Reservation {
  final int id;
  final int userId;
  final int publicationId;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final DateTime createdDate;
  final UserModel? user; // Informations sur l'utilisateur ayant réservé
  final Publication? publication; // Informations sur la publication

  Reservation({
    required this.id,
    required this.userId,
    required this.publicationId,
    required this.status,
    required this.createdDate,
    this.user,
    this.publication,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['userId'],
      publicationId: json['publicationId'],
      status: json['status'],
      createdDate: DateTime.parse(json['createdDate']),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      publication:
          json['publication'] != null
              ? Publication.fromJson(json['publication'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'publicationId': publicationId,
      'status': status,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}
