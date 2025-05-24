import 'package:flutter/material.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/services/ReservationService.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/widgets/reservation/ApprovedReservationsTab.dart';
import 'package:seddoapp/widgets/reservation/PendingReservationsTab.dart';
import 'package:seddoapp/widgets/reservation/RejectedReservationsTab.dart';

class ReservationsTab extends StatefulWidget {
  final Publication publication;

  const ReservationsTab({Key? key, required this.publication})
    : super(key: key);

  @override
  _ReservationsTabState createState() => _ReservationsTabState();
}

class _ReservationsTabState extends State<ReservationsTab> {
  int _selectedTabIndex = 0;
  final ReservationService _reservationService = ReservationService();

  // Compteurs pour chaque type de réservation
  int _pendingCount = 0;
  int _approvedCount = 0;
  int _rejectedCount = 0;

  bool _isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _loadReservationCounts();
  }

  Future<void> _loadReservationCounts() async {
    try {
      setState(() {
        _isLoadingCounts = true;
      });

      // Récupérer toutes les réservations pour ce repas
      final reservations = await _reservationService.getReservationsByMeal(
        widget.publication.id,
      );

      // Compter par statut
      int pending = 0;
      int approved = 0;
      int rejected = 0;

      for (final reservation in reservations) {
        switch (reservation.status.toUpperCase()) {
          case 'PENDING':
            pending++;
            break;
          case 'APPROVED':
          case 'ACCEPTED':
            approved++;
            break;
          case 'REJECTED':
          case 'REFUSED':
            rejected++;
            break;
        }
      }

      setState(() {
        _pendingCount = pending;
        _approvedCount = approved;
        _rejectedCount = rejected;
        _isLoadingCounts = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des compteurs: $e');
      setState(() {
        _isLoadingCounts = false;
      });
    }
  }

  // Méthode pour actualiser les compteurs (à appeler depuis les tabs enfants)
  void refreshCounts() {
    _loadReservationCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              _buildPillTab('En attente', 0, _pendingCount),
              const SizedBox(width: 10),
              _buildPillTab('Validées', 1, _approvedCount),
              const SizedBox(width: 10),
              _buildPillTab('Refusées', 2, _rejectedCount),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab content
        IndexedStack(
          index: _selectedTabIndex,
          children: [
            PendingReservationsTab(
              publication: widget.publication,
              onReservationChanged: refreshCounts,
            ),
            ApprovedReservationsTab(
              publication: widget.publication,
              // onReservationChanged: refreshCounts,
            ),
            RejectedReservationsTab(
              publication: widget.publication,
              // onReservationChanged: refreshCounts,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPillTab(String title, int index, int count) {
    final isSelected = _selectedTabIndex == index;

    Color backgroundColor;
    Color textColor;
    Color countBgColor;
    Color countTextColor;

    if (isSelected) {
      backgroundColor = HexColor("#FCE9DE");
      textColor = HexColor("#D95C18");
      countBgColor = HexColor("#D95C18");
      countTextColor = Colors.white;
    } else {
      backgroundColor = HexColor('#F5F5F5');
      textColor = HexColor('#777777');
      countBgColor = HexColor('#777777');
      countTextColor = HexColor('#F5F5F5');
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: countBgColor,
                shape: BoxShape.circle,
              ),
              child:
                  _isLoadingCounts
                      ? SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            countTextColor,
                          ),
                        ),
                      )
                      : Text(
                        count.toString(),
                        style: TextStyle(
                          color: countTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
