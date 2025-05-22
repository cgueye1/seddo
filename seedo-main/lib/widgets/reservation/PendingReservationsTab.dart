// widgets/reservation/PendingReservationsTab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/reservation/reservation_event.dart';
import 'package:seddoapp/bloc/reservation/reservation_state.dart';
import 'package:seddoapp/models/Reservation.dart';
import '../../bloc/reservation/reservation_bloc.dart';
import '../../models/publication_model.dart';
import '../../utils/HexColor.dart';

class PendingReservationsTab extends StatefulWidget {
  final Publication publication;

  const PendingReservationsTab({Key? key, required this.publication})
    : super(key: key);

  @override
  _PendingReservationsTabState createState() => _PendingReservationsTabState();
}

class _PendingReservationsTabState extends State<PendingReservationsTab> {
  @override
  void initState() {
    super.initState();
    // Charger les réservations en attente
    context.read<ReservationBloc>().add(
      LoadReservationsByPublicationEvent(
        publicationId: widget.publication.id,
        status: 'PENDING',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReservationBloc, ReservationState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
          // Recharger les réservations après mise à jour
          context.read<ReservationBloc>().add(
            LoadReservationsByPublicationEvent(
              publicationId: widget.publication.id,
            ),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.pendingReservations.isEmpty) {
          return const Center(
            child: Text(
              'Aucune réservation en attente',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.pendingReservations.length,
          itemBuilder: (context, index) {
            final reservation = state.pendingReservations[index];
            return ReservationCard(reservation: reservation, showActions: true);
          },
        );
      },
    );
  }
}

// widgets/reservation/ApprovedReservationsTab.dart
class ApprovedReservationsTab extends StatefulWidget {
  final Publication publication;

  const ApprovedReservationsTab({Key? key, required this.publication})
    : super(key: key);

  @override
  _ApprovedReservationsTabState createState() =>
      _ApprovedReservationsTabState();
}

class _ApprovedReservationsTabState extends State<ApprovedReservationsTab> {
  @override
  void initState() {
    super.initState();
    context.read<ReservationBloc>().add(
      LoadReservationsByPublicationEvent(
        publicationId: widget.publication.id,
        status: 'APPROVED',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.approvedReservations.isEmpty) {
          return const Center(
            child: Text(
              'Aucune réservation validée',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.approvedReservations.length,
          itemBuilder: (context, index) {
            final reservation = state.approvedReservations[index];
            return ReservationCard(
              reservation: reservation,
              showActions: false,
            );
          },
        );
      },
    );
  }
}

// widgets/reservation/RejectedReservationsTab.dart
class RejectedReservationsTab extends StatefulWidget {
  final Publication publication;

  const RejectedReservationsTab({Key? key, required this.publication})
    : super(key: key);

  @override
  _RejectedReservationsTabState createState() =>
      _RejectedReservationsTabState();
}

class _RejectedReservationsTabState extends State<RejectedReservationsTab> {
  @override
  void initState() {
    super.initState();
    context.read<ReservationBloc>().add(
      LoadReservationsByPublicationEvent(
        publicationId: widget.publication.id,
        status: 'REJECTED',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.rejectedReservations.isEmpty) {
          return const Center(
            child: Text(
              'Aucune réservation refusée',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.rejectedReservations.length,
          itemBuilder: (context, index) {
            final reservation = state.rejectedReservations[index];
            return ReservationCard(
              reservation: reservation,
              showActions: false,
            );
          },
        );
      },
    );
  }
}

// Widget commun pour afficher les réservations
class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final bool showActions;

  const ReservationCard({
    Key? key,
    required this.reservation,
    required this.showActions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar utilisateur
              CircleAvatar(
                radius: 25,
                backgroundColor: HexColor("#F0DCFD"),
                child:
                    reservation.user?.profil != null
                        ? ClipOval(
                          child: Image.network(
                            reservation.user!.profil,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Text(
                          reservation.user?.firstName
                                  .substring(0, 1)
                                  .toUpperCase() ??
                              'U',
                          style: TextStyle(
                            color: HexColor("#7E30CE"),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
              const SizedBox(width: 12),
              // Informations utilisateur
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.user?.firstName ?? 'Utilisateur inconnu',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (reservation.user?.phone != null)
                      Text(
                        reservation.user!.phone,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              // Badge du statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(reservation.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(reservation.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date de réservation
          Text(
            'Réservé le ${_formatDate(reservation.createdDate)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),

          if (showActions) ...[
            const SizedBox(height: 15),
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<ReservationBloc>().add(
                        UpdateReservationStatusEvent(
                          reservationId: reservation.id,
                          status: 'APPROVED',
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Valider'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<ReservationBloc>().add(
                        UpdateReservationStatusEvent(
                          reservationId: reservation.id,
                          status: 'REJECTED',
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Refuser'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'APPROVED':
        return 'Validée';
      case 'REJECTED':
        return 'Refusée';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
