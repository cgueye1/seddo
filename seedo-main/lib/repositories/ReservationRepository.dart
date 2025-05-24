// repositories/reservation_repository.dart
import 'package:seddoapp/models/Reservation.dart';
import 'package:seddoapp/services/ReservationService.dart';

abstract class ReservationRepository {
  Future<List<Reservation>> getReservationsByMeal(int mealId);
  Future<Reservation> createReservation({
    required int mealId,
    int? userId,
    int? publicationAuthorId,
  });
  Future<bool> acceptReservation(int reservationId);
  Future<bool> refuseReservation(int reservationId);
  Future<bool> cancelReservation(int reservationId);
  Future<List<Reservation>> getUserReservations(int userId);
  Future<bool> hasUserReservation(int mealId, int userId);
}

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationService _reservationService;

  ReservationRepositoryImpl({ReservationService? reservationService})
    : _reservationService = reservationService ?? ReservationService();

  @override
  Future<List<Reservation>> getReservationsByMeal(int mealId) async {
    try {
      return await _reservationService.getReservationsByMeal(mealId);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réservations: $e');
    }
  }

  @override
  Future<Reservation> createReservation({
    required int mealId,
    int? userId,
    int? publicationAuthorId,
  }) async {
    try {
      return await _reservationService.createReservation(
        mealId: mealId,
        userId: userId,
        publicationAuthorId: publicationAuthorId,
      );
    } catch (e) {
      throw Exception('Erreur lors de la création de la réservation: $e');
    }
  }

  @override
  Future<bool> acceptReservation(int reservationId) async {
    try {
      return await _reservationService.acceptReservation(reservationId);
    } catch (e) {
      throw Exception('Erreur lors de l\'acceptation de la réservation: $e');
    }
  }

  @override
  Future<bool> refuseReservation(int reservationId) async {
    try {
      return await _reservationService.refuseReservation(reservationId);
    } catch (e) {
      throw Exception('Erreur lors du refus de la réservation: $e');
    }
  }

  @override
  Future<bool> cancelReservation(int reservationId) async {
    try {
      return await _reservationService.cancelReservation(reservationId);
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la réservation: $e');
    }
  }

  @override
  Future<List<Reservation>> getUserReservations(int userId) async {
    try {
      return await _reservationService.getUserReservations(userId);
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des réservations utilisateur: $e',
      );
    }
  }

  @override
  Future<bool> hasUserReservation(int mealId, int userId) async {
    try {
      return await _reservationService.hasUserReservation(mealId, userId);
    } catch (e) {
      return false;
    }
  }
}
