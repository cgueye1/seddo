// widgets/reservation/reservations_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/reservation/reservation_bloc.dart';
import 'package:seddoapp/bloc/reservation/reservation_event.dart';
import 'package:seddoapp/bloc/reservation/reservation_state.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/widgets/reservation/PendingReservationsTab.dart';

class ReservationsTab extends StatefulWidget {
  final Publication publication;

  const ReservationsTab({Key? key, required this.publication})
    : super(key: key);

  @override
  _ReservationsTabState createState() => _ReservationsTabState();
}

class _ReservationsTabState extends State<ReservationsTab>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Charger toutes les réservations au démarrage
    _loadAllReservations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAllReservations() {
    context.read<ReservationBloc>().add(
      LoadReservationsByPublicationEvent(publicationId: widget.publication.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReservationBloc, ReservationState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
          // Recharger les réservations après mise à jour
          _loadAllReservations();
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },
      child: Column(
        children: [
          // Custom Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                _buildPillTab('En attente', 0),
                const SizedBox(width: 10),
                _buildPillTab('Validées', 1),
                const SizedBox(width: 10),
                _buildPillTab('Refusées', 2),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab content
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                PendingReservationsTab(publication: widget.publication),
                ApprovedReservationsTab(publication: widget.publication),
                RejectedReservationsTab(publication: widget.publication),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;

    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        // Récupérer le vrai count depuis le state du BLoC
        int count = 0;
        switch (index) {
          case 0: // En attente
            count = state.pendingReservations.length;
            break;
          case 1: // Validées
            count = state.approvedReservations.length;
            break;
          case 2: // Refusées
            count = state.rejectedReservations.length;
            break;
        }

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
            _tabController.animateTo(index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
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
                  child: Text(
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
      },
    );
  }
}
