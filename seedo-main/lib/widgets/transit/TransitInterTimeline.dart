import 'package:flutter/material.dart';
import '../../models/transit/TransitResponseModel.dart';
import '../../utils/date_formatter.dart';

class TransitInterTimeline extends StatelessWidget {
  final List<TransitResponseInterModel> items;

  const TransitInterTimeline({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          items.map((item) {
            final isLast = item == items.last;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne de l'icône + ligne verticale
                Column(
                  children: [
                    Icon(Icons.circle, size: 10, color: Colors.blue),
                    if (!isLast)
                      Container(width: 1, height: 40, color: Colors.grey),
                  ],
                ),

                const SizedBox(width: 8),

                // Texte (heure + nom de l'arrêt)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatTimeToHHmm(item.stopTime?.departureTime),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.stop?.stopName ?? "Nom inconnu",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}
