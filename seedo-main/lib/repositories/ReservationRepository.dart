// repositories/reservation_repository.dart
import 'package:seddoapp/models/Reservation.dart';
import 'package:seddoapp/services/ReservationService.dart';

import '../models/ReservationModel.dart';

abstract class ReservationRepository {
  Future<List<ReservationModel>>  getReservationsByMeal(int mealId,String status);
  Future<void> createReservation({
    required int mealId,
    int? userId,

  });
  Future<bool> acceptReservation(int reservationId);
  Future<bool> refuseReservation(int reservationId);
  Future<bool> cancelReservation(int reservationId);
  Future<List<ReservationModel>> getUserReservations(int userId,String status);
}

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationService _reservationService;

  ReservationRepositoryImpl({ReservationService? reservationService})
    : _reservationService = reservationService ?? ReservationService();

  @override
  Future<List<ReservationModel>> getReservationsByMeal(int mealId,String status) async {
    try {
      return await _reservationService.getReservationsByMeal(mealId,status);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réservations: $e');
    }
  }

  @override
  Future<void> createReservation({
    required int mealId,
    int? userId,

  }) async {
    try {
     await _reservationService.createReservation(
        mealId: mealId,
        userId: userId,
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
  Future<List<ReservationModel>> getUserReservations(int userId,String status) async {
    try {
      return await _reservationService.getUserReservations(userId,status);
    } catch (e) {
      throw Exception(
        'Erreur lors de la récupération des réservations utilisateur: $e',
      );
    }
  }


}
