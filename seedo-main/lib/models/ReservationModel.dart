import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/models/user_model.dart';
import 'package:intl/intl.dart'; // Pour formater la date

/// Enum équivalente à ReservationStatus côté Java
enum ReservationStatus { PENDDING, REFUSED, ACCEPTED }

ReservationStatus reservationStatusFromString(String status) {
  return ReservationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status.toUpperCase(),
    orElse: () => ReservationStatus.PENDDING,
  );
}

String reservationStatusToString(ReservationStatus status) {
  return status.toString().split('.').last;
}

class ReservationModel {
  final int id;
  final UserModel user;
  final Publication meal;
  final ReservationStatus status;
  final int createdAt; // timestamp en millisecondes
  final bool isPayed;
  final DateTime? acceptOrRefuseDate;

  ReservationModel({
    required this.id,
    required this.user,
    required this.meal,
    required this.status,
    required this.createdAt,
    required this.isPayed,
    this.acceptOrRefuseDate,
  });

  // Getter qui convertit createdAt en String formatée dd/MM/yyyy
  String get formattedCreatedAt {
    final date = DateTime.fromMillisecondsSinceEpoch(createdAt);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'],
      user: UserModel.fromJson(json['user']),
      meal: Publication.fromJson(json['meal']),
      status: reservationStatusFromString(json['status']),
      createdAt: json['createdAt'],
      isPayed: json['isPayed'] ?? false,
      acceptOrRefuseDate: json['acceptOrRefuseDate'] != null
          ? DateTime.tryParse(json['acceptOrRefuseDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'meal': meal, // adapte selon ton besoin (toJson() ou juste id)
      'status': reservationStatusToString(status),
      'createdAt': createdAt,
      'isPayed': isPayed,
      'acceptOrRefuseDate': acceptOrRefuseDate?.toIso8601String(),
    };
  }

  static List<ReservationModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ReservationModel.fromJson(json)).toList();
  }
}
