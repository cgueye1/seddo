import 'package:flutter/material.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/widgets/reservation/reservation_detail_modal.dart';

class PendingReservationsTab extends StatelessWidget {
  final Publication publication;

  const PendingReservationsTab({Key? key, required this.publication})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Données des réservations en attente
    // Dans une vraie application, ces données viendraient d'une API
    final List<Map<String, dynamic>> reservations = [
      {
        'name': 'Amadou Diallo',
        'initials': 'AD',
        'phoneNumber': '+221 77 123 45 67',
        'personCount': 3,
        'timeAgo': 'Il y a 30 mins',
        'date': '28 mars 2025 à 13h',
        'time': '10 : 15',
        'status': 'En attente',
      },
      {
        'name': 'Mariama Bâ',
        'initials': 'MB',
        'phoneNumber': '+221 77 234 56 78',
        'personCount': 2,
        'timeAgo': 'Il y a 1 heure',
        'date': '29 mars 2025 à 14h',
        'time': '11 : 30',
        'status': 'En attente',
      },
      {
        'name': 'Souleymane Kane',
        'initials': 'SK',
        'phoneNumber': '+221 77 345 67 89',
        'personCount': 1,
        'timeAgo': 'Il y a 2 heures',
        'date': '30 mars 2025 à 15h',
        'time': '12 : 45',
        'status': 'En attente',
      },
    ];

    return reservations.isNotEmpty
        ? ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: reservations.length,
          separatorBuilder:
              (context, index) => const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
                color: Color(0xFFEEEEEE),
              ),
          itemBuilder: (context, index) {
            final reservation = reservations[index];

            return InkWell(
              onTap: () {
                // Afficher le modal de détail de réservation
                showReservationDetailModal(
                  context,
                  name: reservation['name'],
                  phoneNumber: reservation['phoneNumber'],
                  date: reservation['date'],
                  time: reservation['time'],
                  numberOfPeople: reservation['personCount'],
                  status: reservation['status'],
                );
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
                          reservation['initials'],
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
                            reservation['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reservation['personCount']} ${reservation['personCount'] == 1 ? 'personne' : 'personnes'} • ${reservation['timeAgo']}',
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
        )
        : const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Aucune réservation en attente',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
  }
}
