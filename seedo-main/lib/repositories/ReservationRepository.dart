// repositories/reservation_repository.dart
import 'package:seddoapp/models/Reservation.dart';
import 'package:seddoapp/services/ReservationService.dart';

class ReservationRepository {
  final ReservationService _reservationService;

  ReservationRepository({required ReservationService reservationService})
    : _reservationService = reservationService;

  // Créer une réservation
  Future<Reservation> createReservation({
    required int userId,
    required int publicationId,
  }) async {
    try {
      return await _reservationService.createReservation(
        userId: userId,
        publicationId: publicationId,
      );
    } catch (e) {
      print('Erreur dans le repository lors de la création: $e');
      rethrow;
    }
  }

  // Récupérer les réservations par publication
  Future<List<Reservation>> getReservationsByPublication({
    required int publicationId,
    String? status,
  }) async {
    try {
      return await _reservationService.getReservationsByPublication(
        publicationId: publicationId,
        status: status,
      );
    } catch (e) {
      print('Erreur dans le repository lors de la récupération: $e');
      rethrow;
    }
  }

  // Mettre à jour le statut d'une réservation
  Future<Reservation> updateReservationStatus({
    required int reservationId,
    required String status,
  }) async {
    try {
      return await _reservationService.updateReservationStatus(
        reservationId: reservationId,
        status: status,
      );
    } catch (e) {
      print('Erreur dans le repository lors de la mise à jour: $e');
      rethrow;
    }
  }

  // Récupérer les réservations d'un utilisateur
  Future<List<Reservation>> getUserReservations({
    required int userId,
    String? status,
  }) async {
    try {
      return await _reservationService.getUserReservations(
        userId: userId,
        status: status,
      );
    } catch (e) {
      print(
        'Erreur dans le repository lors de la récupération utilisateur: $e',
      );
      rethrow;
    }
  }

  // Vérifier si un utilisateur a déjà réservé une publication
  Future<bool> hasUserReserved({
    required int userId,
    required int publicationId,
  }) async {
    try {
      final reservations = await _reservationService.getUserReservations(
        userId: userId,
      );

      return reservations.any(
        (reservation) =>
            reservation.publicationId == publicationId &&
            reservation.status == 'PENDING',
      );
    } catch (e) {
      print('Erreur lors de la vérification de réservation: $e');
      return false;
    }
  }
}
