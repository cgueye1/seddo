// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/pages/reservation.dart';
import 'package:seddoapp/utils/constant.dart';
import 'package:seddoapp/utils/date_formatter.dart';

class PublicationListCard extends StatelessWidget {
  final Publication publication;
  final double width;
  final String? location;
  final double height;
  final Publication item;
  final Position currentPosition;
  final String priceTag;
  final Color priceTagColor;
  final String category;
  final String expirationDate;

  const PublicationListCard({
    super.key,
    required this.publication,
    this.width = 250,
    this.location,
    this.height = 120,
    required this.item,
    required this.currentPosition,
    this.priceTag = "Gratuit",
    this.priceTagColor = Colors.green,
    this.category = "Alimentation",
    this.expirationDate = "06/05/2025",
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigation vers la page de détail de la publication sélectionnée
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MealDetailPage(
                  publication: publication,
                  currentPosition: currentPosition,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child:
                  publication.picture.isNotEmpty
                      ? Image.network(
                        '${APIConstants.API_BASE_URL_IMG}${publication.picture}',
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            width: 120,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 40),
                            ),
                          );
                        },
                      )
                      : Container(
                        height: 120,
                        width: 120,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 40),
                        ),
                      ),
            ),

            // Right content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      publication.titre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Published time
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Publié il y a ${getTimeAgo(item.createdDate)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Expiration date
                    Text(
                      'Expire le $expirationDate',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent,
                      ),
                    ),

                    // Spacer to push price tag to bottom
                    const Spacer(),

                    // Price tag (Right aligned)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: priceTagColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          priceTag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
