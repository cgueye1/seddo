// events/reservation_event.dart
import 'package:equatable/equatable.dart';

abstract class ReservationEvent extends Equatable {
  const ReservationEvent();

  @override
  List<Object?> get props => [];
}

// Événements pour récupérer les réservations
class LoadReservationsByMeal extends ReservationEvent {
  final int mealId;

  const LoadReservationsByMeal(this.mealId);

  @override
  List<Object?> get props => [mealId];
}

class LoadUserReservations extends ReservationEvent {
  final int userId;
  final String status;

  const LoadUserReservations(this.userId,this.status);

  @override
  List<Object?> get props => [userId];
}

// Événements pour créer une réservation
class CreateReservation extends ReservationEvent {
  final int mealId;
  final int? userId;
  final int? publicationAuthorId;

  const CreateReservation({
    required this.mealId,
    this.userId,
    this.publicationAuthorId,
  });

  @override
  List<Object?> get props => [mealId, userId, publicationAuthorId];
}

// Événements pour accepter/refuser une réservation
class AcceptReservation extends ReservationEvent {
  final int reservationId;

  const AcceptReservation(this.reservationId);

  @override
  List<Object?> get props => [reservationId];
}

class RefuseReservation extends ReservationEvent {
  final int reservationId;

  const RefuseReservation(this.reservationId);

  @override
  List<Object?> get props => [reservationId];
}

// Événement pour annuler une réservation
class CancelReservation extends ReservationEvent {
  final int reservationId;

  const CancelReservation(this.reservationId);

  @override
  List<Object?> get props => [reservationId];
}

// Vérifier si l'utilisateur a déjà une réservation
class CheckUserReservation extends ReservationEvent {
  final int mealId;
  final int userId;

  const CheckUserReservation({required this.mealId, required this.userId});

  @override
  List<Object?> get props => [mealId, userId];
}

// Événement pour rafraîchir les données
class RefreshReservations extends ReservationEvent {
  const RefreshReservations();
}

// Événement pour réinitialiser l'état
class ResetReservationState extends ReservationEvent {
  const ResetReservationState();
}
