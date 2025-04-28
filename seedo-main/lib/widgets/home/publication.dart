// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/pages/reservation.dart';
import 'package:seddoapp/utils/DashedLinePainter.dart';
import 'package:seddoapp/utils/constant.dart';
import 'package:seddoapp/utils/date_formatter.dart';
import 'package:seddoapp/widgets/home/DistanceBadge.dart';

class PublicationCard extends StatelessWidget {
  final Publication publication;
  final double width;
  final String? location;
  final double height;
  final Publication item;
  final Position currentPosition;

  const PublicationCard({
    super.key,
    required this.publication,
    this.width = 250,
    this.location,
    this.height = 200,
    required this.item,
    required this.currentPosition,
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
        width: width,
        // Remove fixed height constraint to let content determine it naturally
        // Use constraints to ensure minimum height, but allow for expansion
        constraints: BoxConstraints(minHeight: height),
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
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
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use minimum space needed
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image principale - fixed height is fine for images
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child:
                  publication.picture.isNotEmpty
                      ? Image.network(
                        '${APIConstants.API_BASE_URL_IMG}${publication.picture}',
                        height: 105,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height:
                                105, // Reduced from 150 to 105 to match other case
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 40),
                            ),
                          );
                        },
                      )
                      : Container(
                        height: 105,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 40),
                        ),
                      ),
            ),

            // Conteneur pour le reste du contenu
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et badge de distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          publication.titre,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DistanceBadge(distance: publication.distance),
                    ],
                  ),

                  // Publié il y'a x mins
                  Text(
                    getTimeAgo(item.createdDate),
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),

                  const SizedBox(height: 6), // Reduced from 16 to 8
                  // Ligne avec point et premier lieu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          // First location dot
                          Container(
                            width: 8,
                            height: 15,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromARGB(255, 213, 59, 12),
                            ),
                          ),
                          // Dashed line
                          CustomPaint(
                            size: const Size(1, 15),
                            painter: DashedLinePainter(
                              color: const Color.fromARGB(255, 187, 187, 187),
                              dashHeight: 2,
                              dashSpace: 2,
                            ),
                          ),
                          // Second location dot with location icon
                          const Icon(
                            Icons.location_on,
                            color: Color.fromARGB(255, 213, 59, 12),
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              publication.author != null
                                  ? '${publication.author!.firstName} ${publication.author!.lastName} - Lieu'
                                  : 'Partageur - Lieu',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'Maison',
                              style: TextStyle(
                                fontSize: 7,
                                color: Color.fromARGB(255, 116, 116, 116),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Dans la section où vous affichez "Vous - Nord Foire"
                            Text(
                              'Vous - ${context.watch<HomeBloc>().state.currentLocation}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Maison',
                              style: TextStyle(
                                fontSize: 7,
                                color: Color.fromARGB(255, 119, 119, 119),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
