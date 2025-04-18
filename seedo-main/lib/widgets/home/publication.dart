// ignore_for_file: deprecated_member_use, file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/pages/reservation.dart';
import 'package:seddoapp/utils/DashedLinePainter.dart';
import 'package:seddoapp/utils/constant.dart';
import 'package:seddoapp/utils/date_formatter.dart';
import 'package:seddoapp/widgets/home/DistanceBadge.dart';

// Nouvel événement pour gérer les favoris des publications
class ToggleFavoritePublication extends HomeEvent {
  final int publicationId;

  const ToggleFavoritePublication({required this.publicationId});

  @override
  List<Object> get props => [publicationId];
}

class PublicationCard extends StatelessWidget {
  final Publication publication;
  final double width;
  final String? location;

  const PublicationCard({
    super.key,
    required this.publication,
    this.width = 350,
    this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      margin: const EdgeInsets.only(left: 6, top: 10, bottom: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 238, 238, 238),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with heart icon
          Container(
            margin: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: 8,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  child:
                      publication.picture.isNotEmpty
                          ? Image.network(
                            '${APIConstants.API_BASE_URL_IMG}${publication.picture}',
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 220,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                  ),
                                ),
                              );
                            },
                          )
                          : Container(
                            height: 220,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 50),
                            ),
                          ),
                ),
                // Heart icon
                Positioned(
                  bottom: 2,
                  right: 5,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      publication.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          publication.isFavorite
                              ? Colors.red
                              : const Color.fromARGB(255, 0, 0, 0),
                      size: 35,
                    ),
                    onPressed: () {
                      context.read<HomeBloc>().add(
                        ToggleFavoritePublication(
                          publicationId: publication.id,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Section for title and details
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4, right: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        publication.titre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DistanceBadge(distance: publication.distance),
                  ],
                ),

                const SizedBox(height: 2),

                // Published time
                Text(
                  'Publié ${formatTimeAgo(publication.timestamp * 1000)}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 16),

                // Two-column layout for bottom section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column: Category, Date, Profile
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromARGB(255, 255, 111, 0),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              publication.categorie.titre,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 119, 0),
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Date with icon
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatDate(publication.timestamp * 100),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Chef profile
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
                                  Text(
                                    publication.author != null
                                        ? '${publication.author!.firstName} ${publication.author!.lastName}'
                                        : 'Utilisateur',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Text(
                                    'Partageur',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Color.fromARGB(255, 117, 117, 117),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Right column: Location timeline with dashed line
                    Expanded(
                      flex: 4,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timeline column with dots and dashed line
                          Column(
                            children: [
                              // First location dot
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(255, 213, 59, 12),
                                ),
                              ),
                              // Dashed line
                              CustomPaint(
                                size: const Size(1, 50),
                                painter: DashedLinePainter(
                                  color: const Color.fromARGB(
                                    255,
                                    187,
                                    187,
                                    187,
                                  ),
                                  dashHeight: 3,
                                  dashSpace: 3,
                                ),
                              ),
                              // Second location dot with location icon
                              const Icon(
                                Icons.location_on,
                                color: Color.fromARGB(255, 213, 59, 12),
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          // Location details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  publication.author != null
                                      ? '${publication.author!.firstName} ${publication.author!.lastName} - Lieu'
                                      : 'Partageur - Lieu',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Maison',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color.fromARGB(255, 116, 116, 116),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                // Dans la section où vous affichez "Vous - Nord Foire"
                                Text(
                                  'Vous - ${context.watch<HomeBloc>().state.currentLocation}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Maison',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color.fromARGB(255, 119, 119, 119),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Reservation button
                // Bouton de réservation - navigation vers la page de réservation
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigation vers la page de détail de la publication sélectionnée
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    MealDetailPage(publication: publication),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 208, 88, 23),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Faire une réservation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
