// bloc/reservation/reservation_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/reservation/reservation_event.dart';
import 'package:seddoapp/bloc/reservation/reservation_state.dart';
import 'package:seddoapp/repositories/ReservationRepository.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final ReservationRepository _reservationRepository;

  ReservationBloc({required ReservationRepository reservationRepository})
    : _reservationRepository = reservationRepository,
      super(ReservationState()) {
    on<CreateReservationEvent>(_onCreateReservation);
    on<LoadReservationsByPublicationEvent>(_onLoadReservationsByPublication);
    on<UpdateReservationStatusEvent>(_onUpdateReservationStatus);
    on<LoadUserReservationsEvent>(_onLoadUserReservations);
    on<CheckUserReservationEvent>(_onCheckUserReservation);
    on<ClearMessagesEvent>(_onClearMessages);
  }

  Future<void> _onCreateReservation(
    CreateReservationEvent event,
    Emitter<ReservationState> emit,
  ) async {
    emit(state.copyWith(isCreating: true, error: null, successMessage: null));

    try {
      await _reservationRepository.createReservation(
        userId: event.userId,
        publicationId: event.publicationId,
      );

      emit(
        state.copyWith(
          isCreating: false,
          successMessage: 'Réservation effectuée avec succès!',
          hasReserved: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isCreating: false,
          error: e.toString(),
          hasReserved: false,
        ),
      );
    }
  }

  Future<void> _onLoadReservationsByPublication(
    LoadReservationsByPublicationEvent event,
    Emitter<ReservationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Charger toutes les réservations pour cette publication
      final allReservations = await _reservationRepository
          .getReservationsByPublication(publicationId: event.publicationId);

      // Séparer par statut
      final pending =
          allReservations.where((r) => r.status == 'PENDING').toList();
      final approved =
          allReservations.where((r) => r.status == 'APPROVED').toList();
      final rejected =
          allReservations.where((r) => r.status == 'REJECTED').toList();

      emit(
        state.copyWith(
          isLoading: false,
          reservations: allReservations,
          pendingReservations: pending,
          approvedReservations: approved,
          rejectedReservations: rejected,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateReservationStatus(
    UpdateReservationStatusEvent event,
    Emitter<ReservationState> emit,
  ) async {
    emit(state.copyWith(error: null, successMessage: null));

    try {
      await _reservationRepository.updateReservationStatus(
        reservationId: event.reservationId,
        status: event.status,
      );

      String message =
          event.status == 'APPROVED'
              ? 'Réservation approuvée avec succès!'
              : 'Réservation refusée avec succès!';

      emit(state.copyWith(successMessage: message));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onLoadUserReservations(
    LoadUserReservationsEvent event,
    Emitter<ReservationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final reservations = await _reservationRepository.getUserReservations(
        userId: event.userId,
        status: event.status,
      );

      emit(state.copyWith(isLoading: false, userReservations: reservations));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCheckUserReservation(
    CheckUserReservationEvent event,
    Emitter<ReservationState> emit,
  ) async {
    try {
      final hasReserved = await _reservationRepository.hasUserReserved(
        userId: event.userId,
        publicationId: event.publicationId,
      );

      emit(state.copyWith(hasReserved: hasReserved));
    } catch (e) {
      emit(state.copyWith(hasReserved: false));
    }
  }

  void _onClearMessages(
    ClearMessagesEvent event,
    Emitter<ReservationState> emit,
  ) {
    emit(state.copyWith(error: null, successMessage: null));
  }
}
