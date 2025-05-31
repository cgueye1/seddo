import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/models/Reservation.dart';
import 'package:seddoapp/models/publication_model.dart';
import 'package:seddoapp/models/user_model.dart';
import 'package:seddoapp/services/PhoneCallService.dart';
import 'package:seddoapp/services/WhatsAppService.dart';
import 'package:seddoapp/services/ReservationService.dart';
import 'package:seddoapp/utils/DashedLinePainter.dart';
import 'package:seddoapp/utils/ExpandableText.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/utils/constant.dart';
import 'package:seddoapp/utils/date_formatter.dart';
import 'package:seddoapp/utils/url_launcher.dart';
import 'package:seddoapp/widgets/home/DistanceBadge.dart';
import 'package:seddoapp/widgets/navitems.dart';

class MealDetailPage extends StatefulWidget {
  final Publication publication;
  final String? location;
  final Position? currentPosition;
  final UserModel? user;

  const MealDetailPage({
    super.key,
    required this.publication,
    this.location,
    this.currentPosition, this.user,
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
  bool _isCreatingReservation = false;
  bool _reserved = false;
  UserModel? user;
  final ReservationService _reservationService = ReservationService();

  // Variables pour gérer les réservations
  List<Reservation> _reservations = [];
  bool _isLoadingReservations = false;
  bool _hasUserReservation = false;
  Reservation? _userReservation;

  // Liste des images à afficher - inclut l'image principale et les images supplémentaires
  late List<String> pictures;

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadCurrentUser());

    // Debug pour voir si l'utilisateur est bien récupéré
    final homeState = context.read<HomeBloc>().state;
    print(
      "🔍 Debug - Current User: ${homeState.currentUser?.firstName} (ID: ${homeState.currentUser?.id})",
    );
    print("🔍 Debug - Publication ID: ${widget.publication.id}");
    print(
      "🔍 Debug - Publication Author: ${widget.publication.author?.firstName} (ID: ${widget.publication.author?.id})",
    );

    setState(() {
      user=homeState.currentUser;
    });

    // ... reste du code initState existant ...
    pictures = [widget.publication.picture];
    if (widget.publication.pictures.isNotEmpty) {
      pictures.addAll(widget.publication.pictures);
    }

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

  void _showReservationConfirmationModal() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text(
              'Voulez-vous envoyer votre commande ? '
             ,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Ferme le modal
                  _createReservation();

                },
                child: const Text('Envoyer'),
              ),
            ],
          ),
    );
  }

  int? _getCurrentUserId() {
    final homeState = context.read<HomeBloc>().state;
    return homeState.currentUser?.id;
  }

  Future<void> _createReservation() async {

    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour faire une réservation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreatingReservation = true);

    try {

      context.read<HomeBloc>().add(
        AddReservedPublication(
          publicationId:  widget.publication.id,
          userId: context.read<HomeBloc>().state.currentUser!.id,
        ),
      );
      setState(() => _reserved=true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar( SnackBar(content: Text("Réservation envoyée")));



    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    } finally {
      setState(() => _isCreatingReservation = false);
    }
  }




  Widget _buildReservationButton() {
    if (_hasUserReservation) {
      // L'utilisateur a déjà une réservation
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Statut de la réservation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getReservationStatusColor(
                  _userReservation!.status,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getReservationStatusColor(_userReservation!.status),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getReservationStatusIcon(_userReservation!.status),
                    color: _getReservationStatusColor(_userReservation!.status),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getReservationStatusText(_userReservation!.status),
                    style: TextStyle(
                      color: _getReservationStatusColor(
                        _userReservation!.status,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Bouton d'annulation
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: (){

                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
                child: const Text(
                  'Annuler ma réservation',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // L'utilisateur n'a pas de réservation
      return Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isCreatingReservation ? null : _createReservation,
          style: ElevatedButton.styleFrom(
            backgroundColor: HexColor("#D95C18"),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              _isCreatingReservation
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    'Réserver maintenant',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
        ),
      );
    }
  }

  Widget _buildReservationButtonWithBloc() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final currentUser = state.currentUser;

        if (currentUser == null) {
          // Utilisateur non connecté
          return Container(
            width: double.infinity,
            height: 50,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Rediriger vers la page de connexion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Veuillez vous connecter pour faire une réservation',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Se connecter pour réserver',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }

        // Utilisateur connecté - utiliser la logique existante
        return _buildReservationButton();
      },
    );
  }

  Color _getReservationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'refused':
        return Colors.red;
      case 'pendding':
      default:
        return Colors.orange;
    }
  }

  IconData _getReservationStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'refused':
        return Icons.cancel;
      case 'pendding':
      default:
        return Icons.schedule;
    }
  }

  String _getReservationStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return 'Réservation acceptée';
      case 'refused':
        return 'Réservation refusée';
      case 'pendding':
      default:
        return 'Réservation en attente';
    }
  }



  void _signaler(BuildContext context, int publicationId) {
    final TextEditingController _raisonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Veuillez indiquer la raison du signalement :'),
            const SizedBox(height: 10),
            TextField(
              controller: _raisonController,
              decoration: const InputDecoration(
                hintText: 'Raison',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme le dialogue
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final raison = _raisonController.text.trim();

              if (raison.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer une raison')),
                );
                return;
              }

              // Appelle ici ta fonction pour signaler avec l'ID et la raison
              _envoyerSignalement(publicationId, raison);

              Navigator.pop(context); // Ferme le dialogue après envoi
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _envoyerSignalement(int publicationId, String raison) {
    // TODO : Logique pour envoyer le signalement (API, BLoC, etc.)


    ScaffoldMessenger.of(context).showSnackBar(
   SnackBar(content: Text('Publication  signalée pour : $raison')),
    );
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
        actions: [
          if(!widget.publication.ad)
          InkWell(
            onTap: (){
              _signaler( context, widget.publication.id);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(30)
              ),
              padding: EdgeInsets.all(5),
              child: Text("Signaler",style: TextStyle(color: Colors.grey),),
            ),
          )
          // Bouton de rafraîchissement des réservations
          /*  IconButton(
            icon:
                _isLoadingReservations
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.refresh, color: Colors.black),
            onPressed: _isLoadingReservations ? null : _loadReservations,
          ),*/
        ],
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
                        height: 380,
                        width: double.infinity,
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
                            return Container(
                              color: Colors.black,
                              alignment: Alignment.center,
                              child:
                                  imagePath.isNotEmpty
                                      ? InteractiveViewer(
                                        panEnabled: true,
                                        minScale: 1,
                                        maxScale: 4,
                                        child: SizedBox(
                                          //height: 350,
                                          width: double.infinity,
                                          child: Image.network(
                                            '${APIConstants.API_BASE_URL_IMG}$imagePath',
                                            fit: BoxFit.contain,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                      : Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                          ),
                                        ),
                                      ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Heart icon positionné comme avant
                    /* Positioned(
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
                    ),*/
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
                if (!widget.publication.ad &&
                    widget.publication.categorie.parentCategorie != null)
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
                if (!widget.publication.ad &&
                    widget.publication.categorie.parentCategorie != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.publication.price == 0
                                ? "Gratuit"
                                : "${widget.publication.price.toString()} CFA",
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
                if (!widget.publication.ad &&
                    widget.publication.categorie.parentCategorie != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: HexColor("#D95C18"),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          getTimeAgo(widget.publication.createdDate),
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),

                        /*
                      Icon(
                        Icons.add_road,
                        color: HexColor("#D95C18"),
                        size: 16,
                      ),
                      const SizedBox(width: 4),*/
                        DistanceBadge(distance: widget.publication.distance),

                        const SizedBox(width: 12),
                        /* Icon(
                        Icons.access_time,
                        color: HexColor("#F44336"),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatDate(widget.publication.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: HexColor("#F44336"),
                        ),
                      ),*/
                      ],
                    ),
                  ),

                // Compteur de réservations
                if (_reservations.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: HexColor("#D95C18").withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: HexColor("#D95C18"),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people,
                            color: HexColor("#D95C18"),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_reservations.length} réservation${_reservations.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: HexColor("#D95C18"),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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
                /* const Divider(
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
                      const Text(
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
                ),*/
                // const SizedBox(height: 12),
                /*  const Divider(
                  height: 0.5,
                  thickness: 1,
                  color: Color.fromARGB(255, 224, 224, 224),
                ),
                const SizedBox(height: 12),*/

                // Localisation
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /*   const Text(
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
                                Text(
                                  'Vous - ${widget.location ?? 'Votre position'}',
                                  style: const TextStyle(
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
                      ),*/
                    ],
                  ),
                ),
                //  const SizedBox(height: 12),
                if (!widget.publication.ad &&
                    widget.publication.categorie.parentCategorie != null)
                  const Divider(
                    height: 0.5,
                    thickness: 1,
                    color: Color.fromARGB(255, 224, 224, 224),
                  ),
                if (!widget.publication.ad &&
                    widget.publication.categorie.parentCategorie != null)
                  const SizedBox(height: 12),
                if (!widget.publication.ad &&
                    widget.publication.categorie.parentCategorie != null)
                  // Partageur
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Partageur",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const CircleAvatar(
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
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "",
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
                const SizedBox(height: 90),
              ],
            ),
          ),
          // Barre de boutons en bas de l'écran
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 20),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 5),
                  if (widget.publication.telephone.isNotEmpty)
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
                  SizedBox(width: 5),
                  if (widget.publication.telephone.isNotEmpty)
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

                  SizedBox(width: 5),
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

                  SizedBox(width: 5),
                  if (widget.publication.link.isNotEmpty)
                    InkWell(
                      child: Container(
                        width: 50,
                        height: 50,

                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/icons/actions/link.png"),
                          ),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onTap: () async {

                            await UrlLauncher().openWebLink(
                              widget.publication.link,);


                      },
                    ),

                  SizedBox(width: 5),
                  if (!widget.publication.ad && _reserved==false && user!=null )
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: Center(
                          child: ElevatedButton(
                            onPressed:
                                () async {
                                  _showReservationConfirmationModal();
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
                            child:
                                _isCreatingReservation
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(
                                      _hasUserReservation
                                          ? (widget
                                                  .publication
                                                  .action
                                                  .isNotEmpty
                                              ? widget.publication.action
                                              : widget
                                                  .publication
                                                  .categorie
                                                  .action)
                                          : 'Réserver ',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
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
