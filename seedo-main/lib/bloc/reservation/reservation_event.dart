// bloc/reservation/reservation_event.dart
abstract class ReservationEvent {}

class CreateReservationEvent extends ReservationEvent {
  final int userId;
  final int publicationId;

  CreateReservationEvent({required this.userId, required this.publicationId});
}

class LoadReservationsByPublicationEvent extends ReservationEvent {
  final int publicationId;
  final String? status;

  LoadReservationsByPublicationEvent({
    required this.publicationId,
    this.status,
  });
}

class UpdateReservationStatusEvent extends ReservationEvent {
  final int reservationId;
  final String status;

  UpdateReservationStatusEvent({
    required this.reservationId,
    required this.status,
  });
}

class LoadUserReservationsEvent extends ReservationEvent {
  final int userId;
  final String? status;

  LoadUserReservationsEvent({required this.userId, this.status});
}

class CheckUserReservationEvent extends ReservationEvent {
  final int userId;
  final int publicationId;

  CheckUserReservationEvent({
    required this.userId,
    required this.publicationId,
  });
}

class ClearMessagesEvent extends ReservationEvent {}
