// bloc/reservation/reservation_state.dart
import 'package:seddoapp/models/Reservation.dart';

class ReservationState {
  final List<Reservation> reservations;
  final List<Reservation> pendingReservations;
  final List<Reservation> approvedReservations;
  final List<Reservation> rejectedReservations;
  final List<Reservation> userReservations;
  final bool isLoading;
  final bool isCreating;
  final String? error;
  final String? successMessage;
  final bool? hasReserved;

  ReservationState({
    this.reservations = const [],
    this.pendingReservations = const [],
    this.approvedReservations = const [],
    this.rejectedReservations = const [],
    this.userReservations = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.error,
    this.successMessage,
    this.hasReserved,
  });

  ReservationState copyWith({
    List<Reservation>? reservations,
    List<Reservation>? pendingReservations,
    List<Reservation>? approvedReservations,
    List<Reservation>? rejectedReservations,
    List<Reservation>? userReservations,
    bool? isLoading,
    bool? isCreating,
    String? error,
    String? successMessage,
    bool? hasReserved,
  }) {
    return ReservationState(
      reservations: reservations ?? this.reservations,
      pendingReservations: pendingReservations ?? this.pendingReservations,
      approvedReservations: approvedReservations ?? this.approvedReservations,
      rejectedReservations: rejectedReservations ?? this.rejectedReservations,
      userReservations: userReservations ?? this.userReservations,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      error: error,
      successMessage: successMessage,
      hasReserved: hasReserved ?? this.hasReserved,
    );
  }
}
