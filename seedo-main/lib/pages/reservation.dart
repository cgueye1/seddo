// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/pages/home.dart';
import 'package:seddoapp/utils/DashedLinePainter.dart';
import 'package:seddoapp/utils/ExpandableText.dart';
import 'package:seddoapp/utils/constant.dart';
import 'package:seddoapp/utils/date_formatter.dart';
import 'package:seddoapp/widgets/home/DistanceBadge.dart';

// Réutilisation de l'événement de basculement des favoris
// (importé de PublicationCard pour assurer la cohérence)
class ToggleFavoritePublication extends HomeEvent {
  final int publicationId;

  const ToggleFavoritePublication({required this.publicationId});

  @override
  List<Object> get props => [publicationId];
}

class MealDetailPage extends StatefulWidget {
  final Publication publication;
  final String? location;

  const MealDetailPage({super.key, required this.publication, this.location});

  @override
  _MealDetailPageState createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  bool _showConfirmation = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Retourner à la publication',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Contenu principal
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du plat avec bouton favori superposé
                Stack(
                  children: [
                    widget.publication.picture.isNotEmpty
                        ? Image.network(
                          '${APIConstants.API_BASE_URL_IMG}${widget.publication.picture}',
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
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
                          height: 250,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        ),
                    // Heart icon positionné comme dans PublicationCard
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          widget.publication.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                              widget.publication.isFavorite
                                  ? Colors.red
                                  : const Color.fromARGB(255, 0, 0, 0),
                          size: 35,
                        ),
                        onPressed: () {
                          context.read<HomeBloc>().add(
                            ToggleFavoritePublication(
                              publicationId: widget.publication.id,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Titre
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.publication.titre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Distance tag comme dans PublicationCard
                      DistanceBadge(
                        distance: widget.publication.distance,
                        // Option pour une version plus compacte
                      ),
                    ],
                  ),
                ),

                // Temps de publication
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Publié ${formatTimeAgo(widget.publication.timestamp * 1000)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Catégorie
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
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
                      widget.publication.categorie.titre,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 119, 0),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Date et heure comme dans PublicationCard
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatDate(widget.publication.timestamp * 100),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Disponibilité
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Disponible ',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(text: 'pour 01 à 05 personnes'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Section avec deux colonnes: Chef profile et Adresses avec timeline
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column: Chef profile
                      Expanded(
                        flex: 3,
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
                                    Text(
                                      widget.publication.author != null
                                          ? '${widget.publication.author!.firstName} ${widget.publication.author!.lastName}'
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
                                        color: Color.fromARGB(
                                          255,
                                          117,
                                          117,
                                          117,
                                        ),
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
                                    widget.publication.author != null
                                        ? '${widget.publication.author!.firstName} ${widget.publication.author!.lastName} - Lieu'
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
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description du repas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ExpandableText(
                        text: widget.publication.description,
                        maxLines: 5,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),

                // Boutons d'action au bas de la page
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    children: [
                      // Bouton de réservation - style cohérent avec PublicationCard
                      SizedBox(
                        width: 400,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showConfirmation = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              208,
                              88,
                              23,
                            ),
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
                      const SizedBox(height: 12),
                      // Bouton de discussion
                      // Dans MealDetailPage, modifiez le bouton "Discuter avec le partageur":
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Overlay de confirmation
          if (_showConfirmation)
            Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Votre demande a bien été enregistrée !',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Votre demande a bien été envoyée ! Maintenant, il ne reste plus qu\'à attendre que le partageur l\'accepte ou non. Vous recevrez une notification dès qu\'il aura fait son choix.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                        },
                        child: const Text(
                          'Continuer à naviguer',
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
