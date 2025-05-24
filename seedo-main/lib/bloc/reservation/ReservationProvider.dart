// config/reservation_dependencies.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/reservation/reservation_bloc.dart';
import 'package:seddoapp/bloc/reservation/reservation_state.dart';
import 'package:seddoapp/repositories/ReservationRepository.dart';
import 'package:seddoapp/services/ReservationService.dart';

class ReservationProvider extends StatelessWidget {
  final Widget child;
  final ReservationRepository? reservationRepository;

  const ReservationProvider({
    Key? key,
    required this.child,
    this.reservationRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => ReservationBloc(
            reservationRepository:
                reservationRepository ??
                ReservationRepositoryImpl(
                  reservationService: ReservationService(),
                ),
          ),
      child: child,
    );
  }
}

// Extension pour faciliter l'accès au BLoC
extension ReservationBlocExtension on BuildContext {
  ReservationBloc get reservationBloc => read<ReservationBloc>();
}

// Widget listener pour les états de réservation
class ReservationListener extends StatelessWidget {
  final Widget child;
  final Function(BuildContext, ReservationState)? onSuccess;
  final Function(BuildContext, ReservationState)? onError;
  final Function(BuildContext, ReservationState)? onLoading;

  const ReservationListener({
    Key? key,
    required this.child,
    this.onSuccess,
    this.onError,
    this.onLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReservationBloc, ReservationState>(
      listener: (context, state) {
        if (state is ReservationLoading ||
            state is ReservationCreating ||
            state is ReservationUpdating) {
          onLoading?.call(context, state);
        } else if (state is ReservationError ||
            state is ReservationCreationError ||
            state is ReservationUpdateError) {
          onError?.call(context, state);
        } else if (state is ReservationsLoaded ||
            state is ReservationCreated ||
            state is ReservationAccepted ||
            state is ReservationRefused ||
            state is ReservationCancelled) {
          onSuccess?.call(context, state);
        }
      },
      child: child,
    );
  }
}

// Exemple d'utilisation dans un widget
class ReservationExampleUsage extends StatelessWidget {
  final int mealId;
  final int userId;

  const ReservationExampleUsage({
    Key? key,
    required this.mealId,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReservationProvider(
      child: ReservationListener(
        onSuccess: (context, state) {
          if (state is ReservationCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Réservation créée avec succès')),
            );
          }
        },
        onError: (context, state) {
          String message = 'Une erreur est survenue';
          if (state is ReservationError) {
            message = state.message;
          } else if (state is ReservationCreationError) {
            message = state.message;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Réservations')),
          body: BlocBuilder<ReservationBloc, ReservationState>(
            builder: (context, state) {
              if (state is ReservationLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ReservationsLoaded) {
                return ListView.builder(
                  itemCount: state.reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = state.reservations[index];
                    return ListTile(
                      title: Text('Réservation #${reservation.id}'),
                      subtitle: Text('Statut: ${reservation.status}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (reservation.status == 'PENDING') ...[
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed:
                                  () => context.reservationBloc
                                      .acceptReservation(reservation.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed:
                                  () => context.reservationBloc
                                      .refuseReservation(reservation.id),
                            ),
                          ],
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed:
                                () => context.reservationBloc.cancelReservation(
                                  reservation.id,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              return const Center(child: Text('Aucune réservation'));
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Charger les réservations pour ce repas
              context.reservationBloc.loadReservationsByMeal(mealId);
            },
            child: const Icon(Icons.refresh),
          ),
        ),
      ),
    );
  }
}
