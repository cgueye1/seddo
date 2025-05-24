import 'package:flutter/material.dart';
import 'package:seddoapp/models/Reservation.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/services/ReservationService.dart';

class PendingReservationsTab extends StatefulWidget {
  final Publication publication;
  final VoidCallback? onReservationChanged;

  const PendingReservationsTab({
    Key? key,
    required this.publication,
    this.onReservationChanged,
  }) : super(key: key);

  @override
  _PendingReservationsTabState createState() => _PendingReservationsTabState();
}

class _PendingReservationsTabState extends State<PendingReservationsTab> {
  final ReservationService _reservationService = ReservationService();
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Récupérer les réservations pour le repas de cette publication
      final reservations = await _reservationService.getReservationsByMeal(
        widget.publication.id, // Assumer que publication a un meal avec un id
      );

      // Filtrer seulement les réservations en attente
      final pendingReservations =
          reservations
              .where((reservation) => reservation.status == 'PENDING')
              .toList();

      setState(() {
        _reservations = pendingReservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} mins';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    }
  }

  Future<void> _handleReservationAction(
    int reservationId,
    String action,
  ) async {
    try {
      bool success = false;

      if (action == 'accept') {
        success = await _reservationService.acceptReservation(reservationId);
      } else if (action == 'refuse') {
        success = await _reservationService.refuseReservation(reservationId);
      }

      if (success) {
        // Recharger la liste des réservations
        await _loadReservations();

        // Notifier le parent pour mettre à jour les compteurs
        if (widget.onReservationChanged != null) {
          widget.onReservationChanged!();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action == 'accept'
                  ? 'Réservation acceptée avec succès'
                  : 'Réservation refusée avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Erreur de chargement',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadReservations,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return _reservations.isNotEmpty
        ? RefreshIndicator(
          onRefresh: _loadReservations,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _reservations.length,
            separatorBuilder:
                (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFEEEEEE),
                ),
            itemBuilder: (context, index) {
              final reservation = _reservations[index];

              // Pour l'instant, on utilise des données simulées pour les informations utilisateur
              // Dans une vraie app, vous devriez récupérer ces infos via une autre API
              final userName = 'Utilisateur ${reservation.userId}';
              final userPhone = '+221 77 XXX XX XX';

              return InkWell(
                onTap: () {
                  // showReservationDetailModal(
                  //   context,
                  //   name: userName,
                  //   phoneNumber: userPhone,
                  //   date:
                  //       widget.publication.meal?.scheduledFor?.toString().split(
                  //         ' ',
                  //       )[0] ??
                  //       'Date non définie',
                  //   time:
                  //       widget.publication.meal?.scheduledFor?.toString().split(
                  //         ' ',
                  //       )[1] ??
                  //       'Heure non définie',
                  //   numberOfPeople:
                  //       1,
                  //   status: reservation.status,
                  //   onAccept:
                  //       () =>
                  //           _handleReservationAction(reservation.id, 'accept'),
                  //   onReject:
                  //       () =>
                  //           _handleReservationAction(reservation.id, 'refuse'),
                  // );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Avatar gris avec initiales
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0E0E0), // Gris clair
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(userName),
                            style: const TextStyle(
                              color: Color(0xFF757575), // Gris foncé
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Informations utilisateur
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '1 personne • ${_getTimeAgo(reservation.createdAt)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Flèche de navigation
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
        : Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, color: Colors.grey, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Aucune réservation en attente',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _loadReservations,
                  child: const Text('Actualiser'),
                ),
              ],
            ),
          ),
        );
  }
}
