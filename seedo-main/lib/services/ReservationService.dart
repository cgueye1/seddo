// services/reservation_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_launcher_icons/utils.dart';
import 'package:seddoapp/models/Reservation.dart';
import 'package:seddoapp/services/api_service.dart';

import '../models/ReservationModel.dart';

class ReservationService {
  final ApiService _apiService = ApiService();
  final bool _allowSelfReservationForTesting = true;

  Future<List<ReservationModel>> getReservationsByMeal(
    int mealId,
    String status,
  ) async {


    try {
      final response = await _apiService.dio.get(
        'reservations/meal/$mealId?page=0&size=100&status=$status',
      );


      if (response.statusCode == 200) {
        final data = response.data;

        if (data is List) {
          // La réponse est une liste directe
          return ReservationModel.fromJsonList(data);
        } else if (data is Map<String, dynamic>) {
          // Vérifie s'il s'agit d'une réponse paginée (Spring Boot typique)
          if (data.containsKey('content')) {
            final content = data['content'];
            if (content is List) {
              return ReservationModel.fromJsonList(content);
            } else {
              throw Exception("Le champ 'content' n'est pas une liste.");
            }
          } else {
            throw Exception("Réponse inattendue : aucune liste trouvée.");
          }
        } else {
          throw Exception("Structure de réponse inattendue.");
        }
      } else {
        throw Exception("Erreur HTTP ${response.statusCode}");
      }
    } on DioException catch (e) {
      print('DioException: ${e.response?.data}');
      throw Exception(_handleDioError(e));
    } catch (e) {
      print('Exception générique: $e');
      throw Exception('Erreur lors du traitement des données: $e');
    }
  }

  Future<void> createReservation({required int mealId, int? userId}) async {
    try {
      final response = await _apiService.dio.post(
        '/reservations',
        data: {'userId': userId, 'mealId': mealId},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        // Contournement temporaire pour les tests
        if (_allowSelfReservationForTesting) {
          // Simulation d'une réponse réussie
        }
        throw Exception('Action non autorisée');
      }
      throw Exception('Erreur de connexion: ${e.message}');
    }
  }

  Future<bool> valid(int reservationId,int status) async {
    print( status==1?'reservations/$reservationId/accept':'reservations/$reservationId/refuse');
    final response = await _apiService.dio.put(
      status==1?'reservations/$reservationId/accept':'reservations/$reservationId/refuse',
    );
    print(response );
    try {
      final response = await _apiService.dio.put(
        status==1?'reservations/$reservationId/accept':'reservations/$reservationId/refuse',
      );
      print(response );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<bool> acceptReservation(int reservationId) async {
    try {
      final response = await _apiService.dio.patch(
        '/reservations/$reservationId/accept',
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<bool> refuseReservation(int reservationId) async {
    try {
      final response = await _apiService.dio.patch(
        '/reservations/$reservationId/refuse',
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<bool> cancelReservation(int reservationId) async {
    try {
      final response = await _apiService.dio.delete(
        '/reservations/$reservationId',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<List<Reservation>> getUserReservations(int userId) async {
    try {
      final response = await _apiService.dio.get('/reservations/user/$userId');

      if (response.statusCode == 200) {
        // Même logique de parsing que pour getReservationsByMeal
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> responseMap = response.data;

          // Vérifier d'abord pour la structure paginée
          if (responseMap.containsKey('content')) {
            final content = responseMap['content'];
            if (content is List) {
              return content
                  .map((reservation) => Reservation.fromJson(reservation))
                  .toList();
            }
          } else if (responseMap.containsKey('data')) {
            final data = responseMap['data'];
            if (data is List) {
              return data
                  .map((reservation) => Reservation.fromJson(reservation))
                  .toList();
            }
          } else if (responseMap.containsKey('reservations')) {
            final reservations = responseMap['reservations'];
            if (reservations is List) {
              return reservations
                  .map((reservation) => Reservation.fromJson(reservation))
                  .toList();
            }
          }
          return [];
        } else if (response.data is List) {
          return (response.data as List)
              .map((reservation) => Reservation.fromJson(reservation))
              .toList();
        }
        return [];
      }
      throw Exception('Erreur lors de la récupération');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 400:
          return 'Requête invalide';
        case 401:
          return 'Non autorisé - Veuillez vous reconnecter';
        case 403:
          return 'Action interdite';
        case 404:
          return 'Ressource introuvable';
        case 409:
          return 'Conflit - Vous avez déjà une réservation';
        default:
          return e.response!.data['message'] ?? 'Erreur serveur';
      }
    }
    return 'Erreur de connexion: ${e.message}';
  }
}
