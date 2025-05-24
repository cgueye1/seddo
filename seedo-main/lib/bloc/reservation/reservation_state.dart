// states/reservation_state.dart
import 'package:equatable/equatable.dart';
import 'package:seddoapp/models/Reservation.dart';

abstract class ReservationState extends Equatable {
  const ReservationState();

  @override
  List<Object?> get props => [];
}

// État initial
class ReservationInitial extends ReservationState {
  const ReservationInitial();
}

// États de chargement
class ReservationLoading extends ReservationState {
  const ReservationLoading();
}

class ReservationCreating extends ReservationState {
  const ReservationCreating();
}

class ReservationUpdating extends ReservationState {
  final int reservationId;

  const ReservationUpdating(this.reservationId);

  @override
  List<Object?> get props => [reservationId];
}

// États de succès
class ReservationsLoaded extends ReservationState {
  final List<Reservation> reservations;
  final int? mealId;
  final int? userId;

  const ReservationsLoaded({
    required this.reservations,
    this.mealId,
    this.userId,
  });

  @override
  List<Object?> get props => [reservations, mealId, userId];

  ReservationsLoaded copyWith({
    List<Reservation>? reservations,
    int? mealId,
    int? userId,
  }) {
    return ReservationsLoaded(
      reservations: reservations ?? this.reservations,
      mealId: mealId ?? this.mealId,
      userId: userId ?? this.userId,
    );
  }
}

class ReservationCreated extends ReservationState {
  final Reservation reservation;

  const ReservationCreated(this.reservation);

  @override
  List<Object?> get props => [reservation];
}

class ReservationAccepted extends ReservationState {
  final int reservationId;

  const ReservationAccepted(this.reservationId);

  @override
  List<Object?> get props => [reservationId];
}

class ReservationRefused extends ReservationState {
  final int reservationId;

  const ReservationRefused(this.reservationId);

  @override
  List<Object?> get props => [reservationId];
}

class ReservationCancelled extends ReservationState {
  final int reservationId;

  const ReservationCancelled(this.reservationId);

  @override
  List<Object?> get props => [reservationId];
}

class UserReservationChecked extends ReservationState {
  final bool hasReservation;
  final int mealId;
  final int userId;

  const UserReservationChecked({
    required this.hasReservation,
    required this.mealId,
    required this.userId,
  });

  @override
  List<Object?> get props => [hasReservation, mealId, userId];
}

// États d'erreur
class ReservationError extends ReservationState {
  final String message;
  final String? errorCode;

  const ReservationError({required this.message, this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}

class ReservationCreationError extends ReservationState {
  final String message;
  final int mealId;

  const ReservationCreationError({required this.message, required this.mealId});

  @override
  List<Object?> get props => [message, mealId];
}

class ReservationUpdateError extends ReservationState {
  final String message;
  final int reservationId;

  const ReservationUpdateError({
    required this.message,
    required this.reservationId,
  });

  @override
  List<Object?> get props => [message, reservationId];
}
