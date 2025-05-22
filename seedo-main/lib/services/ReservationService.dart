// services/reservation_service.dart
import 'package:dio/dio.dart';
import 'package:seddoapp/models/Reservation.dart';
import 'package:seddoapp/utils/constant.dart';

class ReservationService {
  final Dio _dio;

  ReservationService(this._dio);

  // Créer une nouvelle réservation
  Future<Reservation> createReservation({
    required int userId,
    required int publicationId,
  }) async {
    try {
      final response = await _dio.post(
        '${APIConstants.API_BASE_URL}/reservations',
        data: {
          'userId': userId,
          'publicationId': publicationId,
          'status': 'PENDING', // Statut par défaut
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Reservation.fromJson(response.data);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception(
          'Vous avez déjà une réservation pour cette publication',
        );
      }
      print("DioException lors de la création de réservation: ${e.message}");
      throw Exception('Erreur lors de la réservation: ${e.message}');
    } catch (e) {
      print("Exception lors de la création de réservation: $e");
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Récupérer les réservations pour une publication
  Future<List<Reservation>> getReservationsByPublication({
    required int publicationId,
    String? status,
  }) async {
    try {
      String url =
          '${APIConstants.API_BASE_URL}/reservations/publication/$publicationId';

      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Reservation.fromJson(item)).toList();
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
        "DioException lors de la récupération des réservations: ${e.message}",
      );
      throw Exception(
        'Erreur lors du chargement des réservations: ${e.message}',
      );
    } catch (e) {
      print("Exception lors de la récupération des réservations: $e");
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Mettre à jour le statut d'une réservation
  Future<Reservation> updateReservationStatus({
    required int reservationId,
    required String status,
  }) async {
    try {
      final response = await _dio.put(
        '${APIConstants.API_BASE_URL}/reservations/$reservationId',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        return Reservation.fromJson(response.data);
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("DioException lors de la mise à jour du statut: ${e.message}");
      throw Exception('Erreur lors de la mise à jour: ${e.message}');
    } catch (e) {
      print("Exception lors de la mise à jour du statut: $e");
      throw Exception('Erreur inattendue: $e');
    }
  }

  // Récupérer les réservations d'un utilisateur
  Future<List<Reservation>> getUserReservations({
    required int userId,
    String? status,
  }) async {
    try {
      String url = '${APIConstants.API_BASE_URL}/reservations/user/$userId';

      if (status != null && status.isNotEmpty) {
        url += '?status=$status';
      }

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Reservation.fromJson(item)).toList();
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print(
        "DioException lors de la récupération des réservations utilisateur: ${e.message}",
      );
      throw Exception('Erreur lors du chargement: ${e.message}');
    } catch (e) {
      print(
        "Exception lors de la récupération des réservations utilisateur: $e",
      );
      throw Exception('Erreur inattendue: $e');
    }
  }
}
