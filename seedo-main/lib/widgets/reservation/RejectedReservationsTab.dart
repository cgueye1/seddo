import 'package:flutter/material.dart';
import 'package:seddoapp/models/publication_model.dart';

class RejectedReservationsTab extends StatelessWidget {
  final Publication publication;

  const RejectedReservationsTab({Key? key, required this.publication})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dans une vraie application, vous récupéreriez ces données depuis une API
    final rejectedReservations = 0; // Exemple: pas de réservations refusées

    return rejectedReservations > 0
        ? ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: rejectedReservations,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(
                            'assets/icons/profile.png',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ousmane Sow',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Réservation refusée le 12/05/2023',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Refusée',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Je souhaitais participer à ce partage. Dommage que ce ne soit pas possible.',
                      style: TextStyle(fontSize: 14),
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
              'Aucune réservation refusée',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        );
  }
}
