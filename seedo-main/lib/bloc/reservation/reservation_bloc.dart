// blocs/reservation_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/reservation/reservation_event.dart';
import 'package:seddoapp/bloc/reservation/reservation_state.dart';
import 'package:seddoapp/repositories/ReservationRepository.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final ReservationRepository _reservationRepository;

  ReservationBloc({required ReservationRepository reservationRepository})
    : _reservationRepository = reservationRepository,
      super(const ReservationInitial()) {
    // Enregistrement des handlers d'événements
    //on<LoadReservationsByMeal>(_onLoadReservationsByMeal);
    on<LoadUserReservations>(_onLoadUserReservations);
    on<AcceptReservation>(_onAcceptReservation);
    on<RefuseReservation>(_onRefuseReservation);
    on<CancelReservation>(_onCancelReservation);
    on<RefreshReservations>(_onRefreshReservations);
    on<ResetReservationState>(_onResetReservationState);
  }

  // Handler pour charger les réservations par repas
 /* Future<void> _onLoadReservationsByMeal(
    LoadReservationsByMeal event,
    Emitter<ReservationState> emit,
  ) async {
    emit(const ReservationLoading());

    try {
      final reservations = await _reservationRepository.getReservationsByMeal(
        event.mealId,
      );
      emit(
        ReservationsLoaded(reservations: reservations, mealId: event.mealId),
      );
    } catch (e) {
      emit(ReservationError(message: e.toString()));
    }
  }*/

  // Handler pour charger les réservations d'un utilisateur
  Future<void> _onLoadUserReservations(
    LoadUserReservations event,
    Emitter<ReservationState> emit,
  ) async {
    emit(const ReservationLoading());

    try {
      final reservations = await _reservationRepository.getUserReservations(
        event.userId,
      );
      emit(
        ReservationsLoaded(reservations: reservations, userId: event.userId),
      );
    } catch (e) {
      emit(ReservationError(message: e.toString()));
    }
  }


  // Handler pour accepter une réservation
  Future<void> _onAcceptReservation(
    AcceptReservation event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationUpdating(event.reservationId));

    try {
      final success = await _reservationRepository.acceptReservation(
        event.reservationId,
      );
      if (success) {
        emit(ReservationAccepted(event.reservationId));
      } else {
        emit(
          ReservationUpdateError(
            message: 'Échec de l\'acceptation de la réservation',
            reservationId: event.reservationId,
          ),
        );
      }
    } catch (e) {
      emit(
        ReservationUpdateError(
          message: e.toString(),
          reservationId: event.reservationId,
        ),
      );
    }
  }

  // Handler pour refuser une réservation
  Future<void> _onRefuseReservation(
    RefuseReservation event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationUpdating(event.reservationId));

    try {
      final success = await _reservationRepository.refuseReservation(
        event.reservationId,
      );
      if (success) {
        emit(ReservationRefused(event.reservationId));
      } else {
        emit(
          ReservationUpdateError(
            message: 'Échec du refus de la réservation',
            reservationId: event.reservationId,
          ),
        );
      }
    } catch (e) {
      emit(
        ReservationUpdateError(
          message: e.toString(),
          reservationId: event.reservationId,
        ),
      );
    }
  }

  // Handler pour annuler une réservation
  Future<void> _onCancelReservation(
    CancelReservation event,
    Emitter<ReservationState> emit,
  ) async {
    emit(ReservationUpdating(event.reservationId));

    try {
      final success = await _reservationRepository.cancelReservation(
        event.reservationId,
      );
      if (success) {
        emit(ReservationCancelled(event.reservationId));
      } else {
        emit(
          ReservationUpdateError(
            message: 'Échec de l\'annulation de la réservation',
            reservationId: event.reservationId,
          ),
        );
      }
    } catch (e) {
      emit(
        ReservationUpdateError(
          message: e.toString(),
          reservationId: event.reservationId,
        ),
      );
    }
  }



  // Handler pour rafraîchir les réservations
  Future<void> _onRefreshReservations(
    RefreshReservations event,
    Emitter<ReservationState> emit,
  ) async {
    if (state is ReservationsLoaded) {
      final currentState = state as ReservationsLoaded;

      if (currentState.mealId != null) {
        add(LoadReservationsByMeal(currentState.mealId!));
      } else if (currentState.userId != null) {
        add(LoadUserReservations(currentState.userId!));
      }
    }
  }

  // Handler pour réinitialiser l'état
  Future<void> _onResetReservationState(
    ResetReservationState event,
    Emitter<ReservationState> emit,
  ) async {
    emit(const ReservationInitial());
  }

  // Méthodes utilitaires pour faciliter l'utilisation
  void loadReservationsByMeal(int mealId) {
    add(LoadReservationsByMeal(mealId));
  }

  void loadUserReservations(int userId) {
    add(LoadUserReservations(userId));
  }

  void createReservation({
    required int mealId,
    int? userId,
    int? publicationAuthorId,
  }) {
    add(
      CreateReservation(
        mealId: mealId,
        userId: userId,
        publicationAuthorId: publicationAuthorId,
      ),
    );
  }

  void acceptReservation(int reservationId) {
    add(AcceptReservation(reservationId));
  }

  void refuseReservation(int reservationId) {
    add(RefuseReservation(reservationId));
  }

  void cancelReservation(int reservationId) {
    add(CancelReservation(reservationId));
  }

  void checkUserReservation({required int mealId, required int userId}) {
    add(CheckUserReservation(mealId: mealId, userId: userId));
  }

  void refreshReservations() {
    add(const RefreshReservations());
  }

  void resetState() {
    add(const ResetReservationState());
  }
}
