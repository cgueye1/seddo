import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/services/PhoneCallService.dart';
import 'package:seddoapp/services/WhatsAppService.dart';
import 'package:seddoapp/utils/DashedLinePainter.dart';
import 'package:seddoapp/utils/ExpandableText.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/utils/constant.dart';
import 'package:seddoapp/utils/date_formatter.dart';
import 'package:seddoapp/utils/url_launcher.dart';
import 'package:seddoapp/widgets/home/DistanceBadge.dart';

class MealDetailPage extends StatefulWidget {
  final Publication publication;
  final String? location;
  final Position? currentPosition;

  const MealDetailPage({
    super.key,
    required this.publication,
    this.location,
    this.currentPosition,
  });

  @override
  _MealDetailPageState createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  bool _showConfirmation = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  bool _isFavorite = false;

  // Liste des images à afficher - inclut l'image principale et les images supplémentaires
  late List<String> pictures;

  @override
  void initState() {
    super.initState();

    // Initialiser la liste d'images avec l'image principale et les images supplémentaires
    pictures = [widget.publication.picture];
    if (widget.publication.pictures.isNotEmpty) {
      pictures.addAll(widget.publication.pictures);
    }

    // Démarrer le timer pour changer automatiquement les images
    _startImageTimer();
    _isFavorite = widget.publication.isFavorite;
  }

  @override
  void dispose() {
    // Arrêter le timer et libérer le contrôleur de page
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startImageTimer() {
    // Créer un timer qui change d'image toutes les 3 secondes
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pictures.length > 1) {
        final nextPage = (_currentPage + 1) % pictures.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        title: Text(
          widget.publication.titre,
          style: const TextStyle(
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
                // Carousel d'images avec PageView
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: HexColor("#fefefe"),
                          width: 2,
                        ),
                      ),
                      child: SizedBox(
                        height: 250,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: pictures.length,
                          itemBuilder: (context, index) {
                            final imagePath = pictures[index];
                            return imagePath.isNotEmpty
                                ? Image.network(
                                  '${APIConstants.API_BASE_URL_IMG}$imagePath',
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
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                    ),
                                  ),
                                );
                          },
                        ),
                      ),
                    ),

                    // Heart icon positionné comme avant
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.white,
                          size: 35,
                        ),
                        onPressed: () {
                          // Mettre à jour l'état local immédiatement pour une réponse UI instantanée
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });

                          // Envoyer l'événement au bloc pour mettre à jour l'état global
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

                // Indicateurs de position (dots)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < pictures.length; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                i == _currentPage
                                    ? HexColor("#D95C18")
                                    : Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                ),

                // Catégorie - Badge violet
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 223, 217, 224),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      widget.publication.categorie.titre,
                      style: TextStyle(
                        color: Colors.purple.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Titre
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    widget.publication.titre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Badges - Gratuit et Repas offert
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          "Prix : ",
                          style: TextStyle(
                            color: HexColor("#D95C18"),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Repas offert",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Informations de publication (temps, distance)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: HexColor("#D95C18"),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        getTimeAgo(widget.publication.createdDate),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.add_road,
                        color: HexColor("#D95C18"),
                        size: 16,
                      ),
                      const SizedBox(width: 4),

                      DistanceBadge(distance: widget.publication.distance),

                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        color: HexColor("#F44336"),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatDate(widget.publication.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: HexColor("#F44336"),
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
                        'Description',
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

                // Disponibilité
                const Divider(
                  height: 0.5,
                  thickness: 1,
                  color: Color.fromARGB(255, 224, 224, 224),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Disponibilité",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: HexColor("#D95C18"),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "3 à 5 personnes",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: HexColor("#D95C18"),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatDate(widget.publication.timestamp),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(
                  height: 0.5,
                  thickness: 1,
                  color: Color.fromARGB(255, 224, 224, 224),
                ),
                const SizedBox(height: 12),
                // Localisation
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Localisation",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                size: const Size(1, 55),
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.publication.author != null
                                      ? '${widget.publication.author!.firstName} ${widget.publication.author!.lastName} - Lieu'
                                      : 'Partageur - Lieu',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Point de Départ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color.fromARGB(255, 116, 116, 116),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                // Dans la section où vous affichez "Vous - Nord Foire"
                                Text(
                                  'Vous - ${context.watch<HomeBloc>().state.currentLocation}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Point D\'arrivée',
                                  style: TextStyle(
                                    fontSize: 10,
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
                const SizedBox(height: 12),
                const Divider(
                  height: 0.5,
                  thickness: 1,
                  color: Color.fromARGB(255, 224, 224, 224),
                ),
                const SizedBox(height: 12),
                // Partageur
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Partageur",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
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
                                    : 'Fatima Sène',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Membre depuis 3 mois",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 70), // Espace pour le bas de l'écran
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
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: Text(
                          'Continuer à naviguer',
                          style: TextStyle(
                            color: HexColor("#D95C18"),
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

          // Barre de boutons en bas de l'écran
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 3),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      PhoneCallService().makePhoneCall(
                        widget.publication.telephone.isNotEmpty
                            ? widget.publication.telephone
                            : widget.publication.author!.phone.toString(),
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/icons/actions/call.png"),
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  InkWell(
                    onTap: () {
                      WhatsAppService().openWhatsApp(
                        widget.publication.telephone.isNotEmpty
                            ? widget.publication.telephone
                            : widget.publication.author!.phone.toString(),
                        message: 'Salut ! Comment ça va ?',
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,

                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/icons/actions/whatsapp.png",
                          ),
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),

                  SizedBox(width: 16),
                  InkWell(
                    child: Container(
                      width: 50,
                      height: 50,

                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/icons/actions/map.png"),
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onTap: () {
                      if (widget.currentPosition != null) {
                        UrlLauncher().openMapsNavigation(
                          double.parse(
                            widget.currentPosition!.latitude.toString(),
                          ),
                          double.parse(
                            widget.currentPosition!.longitude.toString(),
                          ),
                          widget.publication.latitude,
                          widget.publication.longitude,
                          travelMode: "walk",
                        );
                      }
                    },
                  ),

                  SizedBox(width: 16),

                  Expanded(
                    child: SizedBox(
                      height: 50,

                      child: Center(
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            widget.publication.action.isNotEmpty
                                ? widget.publication.action
                                : widget.publication.categorie.action,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1, // Ajoute cette ligne
                            overflow: TextOverflow.ellipsis,
                          ),
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
    );
  }
}
