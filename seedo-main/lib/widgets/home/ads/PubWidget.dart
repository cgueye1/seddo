// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:seddoapp/utils/constant.dart';
import '../../../models/publication_model.dart';
import '../../../pages/reservation.dart';
import '../../../pages/webview/WebViewPage.dart';
import '../../../utils/date_formatter.dart';

class PubWidget extends StatelessWidget {
  final Publication item;

  const PubWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.darken,
              ),
              child: Image.network(
                APIConstants.API_BASE_URL_IMG + item.picture,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) =>
                        Container(color: Colors.grey[300], height: 200),
              ),
            ),
          ),

          // Contenu superposé
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  item.titre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                // Distance
                Text(
                  getTimeAgo(item.createdDate),
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Bouton en bas à droite
          Positioned(
            bottom: 12,
            right: 12,
            child: ElevatedButton(
              onPressed: () {
                if (item.link.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewPage(url: item.link),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MealDetailPage(publication: item),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              child: Text(
                item.action.isNotEmpty ? item.action : item.categorie.action,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
