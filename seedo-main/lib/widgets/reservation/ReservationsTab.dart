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

  Future<void> _loadReservationCounts() async {}

  // Méthode pour actualiser les compteurs (à appeler depuis les tabs enfants)
  void refreshCounts() {
    _loadReservationCounts();
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = MediaQuery.of(context).size.height;
    const pillTabHeight = 36.0;
    const spacingHeight = 16.0;
    final remainingHeight = totalHeight - pillTabHeight - spacingHeight;
    return  Column(

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
        Flexible(
            child:  IndexedStack(
          index: _selectedTabIndex,
          children: [
            _selectedTabIndex == 0
                ?
             PendingReservationsTab(
                    publication: widget.publication,
                    onReservationChanged: refreshCounts,
                    status: 'PENDDING',

                )
                : SizedBox(),
            _selectedTabIndex == 1
                ? PendingReservationsTab(
                  publication: widget.publication,
                  onReservationChanged: refreshCounts,
                  status: 'ACCEPTED',
                )
                : SizedBox(),
            _selectedTabIndex == 2
                ? PendingReservationsTab(
                  publication: widget.publication,
                  onReservationChanged: refreshCounts,
                  status: 'REFUSED',
                )
                : SizedBox(),
          ],
        ))
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return PendingReservationsTab(
          publication: widget.publication,
          onReservationChanged: refreshCounts,
          status: 'PENDDING',
        );
      case 1:
        return PendingReservationsTab(
          publication: widget.publication,
          onReservationChanged: refreshCounts,
          status: 'ACCEPTED',
        );
      case 2:
        return PendingReservationsTab(
          publication: widget.publication,
          onReservationChanged: refreshCounts,
          status: 'REFUSED',
        );
      default:
        return const SizedBox.shrink();
    }
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
              /*_isLoadingCounts
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
                      : */
              Text(
                "",
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
