import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/reservation/reservation_event.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/utils/constant.dart';
import '../bloc/reservation/reservation_bloc.dart';
import '../bloc/reservation/reservation_state.dart';
import '../models/ReservationModel.dart';
import '../repositories/ReservationRepository.dart';

class CommandesPageWrapper extends StatelessWidget {
  final int id;
   CommandesPageWrapper({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReservationBloc(
        reservationRepository: ReservationRepositoryImpl(),
      )..add(LoadUserReservations(id, ReservationStatus.PENDDING.name)),
      child:  CommandesPage(id: id,),
    );
  }
}

class CommandesPage extends StatefulWidget {
  final int id;
  const CommandesPage({super.key, required this.id});

  @override
  State<CommandesPage> createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.index = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservationsForCurrentTab();
    });

    _tabController.addListener(() {
      _loadReservationsForCurrentTab();
      setState(() {});
    });
  }

  void _loadReservationsForCurrentTab() {
    final userId = widget.id; // À remplacer par l'ID réel
    String status;

    switch (_tabController.index) {
      case 0: status = ReservationStatus.PENDDING.name; break;
      case 1: status = ReservationStatus.ACCEPTED.name; break;
      case 2: status = ReservationStatus.REFUSED.name; break;
      default: status = 'pending';
    }


    context.read<ReservationBloc>().add(LoadUserReservations(userId, status));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = HexColor('#D95C18');

    return Scaffold(
      backgroundColor: HexColor('#F1F2F6'),
      appBar: AppBar(
        backgroundColor: HexColor('#F1F2F6'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Mes commandes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0.5),
            child: TabBar(
              controller: _tabController,
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                _buildTab("En attente", "", 0),
                _buildTab("Validée", "1", 1),
                _buildTab("Refusée", "1", 2),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ReservationBloc, ReservationState>(
              builder: (context, state) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReservationList(state, 'pending'),
                    _buildReservationList(state, 'accepted'),
                    _buildReservationList(state, 'refused'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  String traduireStatut(String status) {
    switch (status.toUpperCase()) {
      case 'PENDDING':
        return 'En attente';
      case 'ACCEPTED':
        return 'Acceptée';
      case 'REFUSED':
        return 'Refusée';
      default:
        return 'Inconnu';
    }
  }

  Widget _buildReservationList(ReservationState state, String expectedStatus) {
    if (state is ReservationLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ReservationError) {
      return Center(child: Text(state.message));
    } else if (state is ReservationsLoaded) {
      final reservations = state.reservations;
         /* .where((reservation) => reservation.status == expectedStatus)
          .toList();*/

      if (reservations.isEmpty) {
        return _buildEmptyState(
          expectedStatus == 'pending' ? "En attente"
              : expectedStatus == 'accepted' ? "Validée" : "Refusée",
          expectedStatus == 'pending' ? "Aucune commande en attente. ${state.userId} ${state.reservations.length}"
              : expectedStatus == 'accepted'
              ? "Les commandes validées apparaîtront ici."
              : "Aucune commande refusée.",
          expectedStatus == 'pending' ? "assets/images/empty1.png"
              : expectedStatus == 'accepted'
              ? "assets/images/empty1.png"
              : "assets/images/empty2.png",
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          return _buildCommandeItem(reservations[index]);
        },
      );
    }
    return const Center(child: Text('Chargement...'));
  }

  Widget _buildCommandeItem(ReservationModel reservation) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      elevation: .1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE + TITRE + NUMÉRO
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
              reservation.meal.picture.isNotEmpty?  "${APIConstants.API_BASE_URL_IMG + reservation.meal.picture}" : 'https://via.placeholder.com/80',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.meal.titre ,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'N° #${reservation.id}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // DESCRIPTION avec Voir plus
            ExpandableText(
              text: reservation.meal.description,
              maxLines: 3,
            ),

            const SizedBox(height: 12),
            Divider(),

            // STATUT + DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${traduireStatut(reservation.status.name)}',
                  style: TextStyle(
                    color: reservation.status.name.toUpperCase() == 'PENDDING'
                        ? Colors.orange
                        : reservation.status.name.toUpperCase() == 'ACCEPTED'
                        ? Colors.green
                        : reservation.status.name.toUpperCase() == 'REFUSED'
                        ? Colors.red
                        : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  reservation.formattedCreatedAt ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTab(String text, String count, int index) {
    final isSelected = _tabController.index == index;
    final primaryColor = HexColor('#D95C18');

    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
         /* const SizedBox(height: 4),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? primaryColor : Colors.grey,
            ),
            child: Center(
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, String imagePath) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 150, height: 150),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableText({
    required this.text,
    this.maxLines = 3,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      maxLines: _expanded ? null : widget.maxLines,
      overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget,
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Text(
            _expanded ? 'Voir moins' : 'Voir plus',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
