
import 'package:flutter/material.dart';
import 'package:seddoapp/models/Reservation.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/services/ReservationService.dart';
import 'package:seddoapp/widgets/reservation/reservation_detail_modal.dart';

import '../../models/ReservationModel.dart';

class PendingReservationsTab extends StatefulWidget {
  final Publication publication;
  final VoidCallback? onReservationChanged;
  final String status;

  const PendingReservationsTab({
    Key? key,
    required this.publication,
    this.onReservationChanged,
    required this.status,
  }) : super(key: key);

  @override
  _PendingReservationsTabState createState() => _PendingReservationsTabState();
}

class _PendingReservationsTabState extends State<PendingReservationsTab> {
  final ReservationService _reservationService = ReservationService();
  List<ReservationModel> _reservations = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _status='PENDDING';

  @override
  void initState() {
    setState(() {
      _status=widget.status;
    });
    super.initState();
    _loadReservations();
  }


  Future<void> _loadReservations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Charger les réservations avec le statut demandé
      final reservations = await _reservationService.getReservationsByMeal(
        widget.publication.id,
        _status, // Statut à filtrer (ex: PENDING, ACCEPTED, REFUSED)
      );

      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _validReservation(int status,int  id) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Charger les réservations avec le statut demandé
      final reservations = await _reservationService.valid(
        id,
        status, // Statut à filtrer (ex: PENDING, ACCEPTED, REFUSED)
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar( SnackBar(content: Text(status==1? "Commande validée":"Commande refusée")));
      _loadReservations();

      setState(() {

        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erreur de validation")));
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
        ?   RefreshIndicator(
          onRefresh: _loadReservations,
          child:  SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                ..._reservations.map((reservation) {
                  final userName = '${reservation.user.firstName} ${reservation.user.lastName}';
                  final userPhone = reservation.user.phone;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => ReservationDetailModal(reservation: reservation),
                          ).then((status) {
                            if (status != null) {
                              _validReservation(status, reservation.id);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0E0E0),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitials(userName),
                                    style: const TextStyle(
                                      color: Color(0xFF757575),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
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
                                      userPhone,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEEEEEE),
                      ),
                    ],
                  );
                }).toList(),

                // 👇 Pour forcer du scroll même quand peu d'éléments
                SizedBox(height: MediaQuery.of(context).size.height),
              ],
            ),
          )
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
