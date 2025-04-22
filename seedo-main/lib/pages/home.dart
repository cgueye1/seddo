// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/pages/transit/TransportCommun.dart';
import 'package:seddoapp/repositories/publication_repository.dart';
import 'package:seddoapp/services/LocationService.dart';
import 'package:seddoapp/services/api_service.dart';
import 'package:seddoapp/services/publication_service.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/widgets/home/CategoryDropdown.dart';
import 'package:seddoapp/widgets/home/PublicationsSection.dart';
import 'package:seddoapp/widgets/home/UserNameSection.dart';
import 'package:seddoapp/widgets/home/SearchBar.dart'; // Ajoutez cette importation

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Créer le PublicationRepository avec ApiService
    final apiService = ApiService();
    final publicationService = PublicationService(apiService.dio);
    final publicationRepository = PublicationRepository(
      publicationService: publicationService,
    );

    // Fournir le repository au HomeBloc
    return BlocProvider(
      create:
          (context) =>
              HomeBloc(publicationRepository)
                ..add(LoadCurrentUser())
                ..add(LoadCategories())
                ..add(const LoadCurrentLocation()),
      child: const _HomePageContent(),
    );
  }
}

// Separate stateless widget to use the provided HomeBloc
class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  @override
  Widget build(BuildContext context) {
    // Now we can safely access the HomeBloc from the context
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (!state.hasLoadedInitialPublications &&
            state.currentLatitude != null &&
            state.currentLongitude != null &&
            state.publications.isEmpty &&
            !state.isLoadingPublications &&
            state.publicationsError == null) {
          _loadNearbyPublications(context, state);
        }

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          // Ajout de la barre de navigation fixe en bas
          bottomNavigationBar: _buildBottomNavigationBar(context, state),
          body:
              state.currentNavigationIndex == 3
                  ? TransportCommun()
                  : SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          // Main Yellow Header Block
                          _buildHeaderBlock(context, state),
                          // Contenu basé sur l'onglet sélectionné
                          _buildPublicationsContent(context, state),
                        ],
                      ),
                    ),
                  ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, HomeState state) {
    // Code inchangé
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: Color.fromARGB(255, 233, 231, 231),
      ),
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, 'assets/icons/home.png', '', state),
          _buildNavItem(context, 1, 'assets/icons/chats.png', '', state),
          _buildNavItem(context, 2, 'assets/icons/grid.png', '', state),
          _buildNavItem(context, 3, 'assets/icons/notification.png', '', state),
          _buildNavItem(context, 4, 'assets/icons/profil.png', '', state),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String imagePath,
    String label,
    HomeState state,
  ) {
    // Code inchangé
    final isSelected = index == state.currentNavigationIndex;
    final iconSize = 28.0; // Taille uniforme pour toutes les icônes

    // Remplacer image.png par image_selected.png si sélectionné
    final displayImagePath =
        isSelected
            ? imagePath.replaceFirst('.png', '_selected.png')
            : imagePath;
    final Color iconColor = isSelected ? HexColor("#D95C18") : Colors.grey;

    return InkWell(
      onTap:
          () => context.read<HomeBloc>().add(
            NavigationIndexChanged(navigationIndex: index),
          ),
      splashColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: iconSize,
              height: iconSize,
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: iconSize,
                  height: iconSize,
                  color: iconColor,
                  fit:
                      BoxFit
                          .contain, // Force l'image à respecter les dimensions
                ),
              ),
            ),
            if (label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.orange : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBlock(BuildContext context, HomeState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Column(
        children: [
          // Top Row: Greeting, Notification, Settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Greeting and Username
              Row(
                children: [
                  const Text(
                    'Hello, ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const UserNameSection(),
                ],
              ),

              // Right side - Icons
              Image.asset(
                'assets/icons/settings.png',
                width: 26,
                height: 26,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
          // Section de localisation - Modifiée pour afficher l'icône de localisation
          Row(
            children: [
              Icon(Icons.location_on, size: 15, color: HexColor('#D95C18')),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  state.currentLocation,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Search Bar
          const SizedBox(height: 16),
          const SearchBars(), // Ce SearchBar doit être importé et défini correctement
        ],
      ),
    );
  }

  Widget _buildPublicationsContent(BuildContext context, HomeState state) {
    return Column(
      key: const ValueKey('publications'),
      children: [
        // Filter options - full width
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: CategoryDropdown(),
        ),

        // Chargement initial des publications
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.currentLatitude == null ||
                state.currentLongitude == null) {
              // Si la position n'est pas encore chargée, déclencher la localisation
              _loadUserLocation(context);
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Colors.orange),
                      SizedBox(height: 10),
                      Text("Chargement de votre position..."),
                    ],
                  ),
                ),
              );
            }

            // Si nous avons la position mais pas de publications chargées
            if (state.publications.isEmpty &&
                !state.isLoadingPublications &&
                state.publicationsError == null) {
              //  _loadNearbyPublications(context, state);
            }

            // Afficher la section des publications
            return const PublicationsSection();
          },
        ),
      ],
    );
  }

  // Méthode pour charger la position de l'utilisateur
  void _loadUserLocation(BuildContext context) async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();

      if (position != null) {
        // Get the address string using geocoding
        final address = await locationService.getAddressFromCoordinates(
          position,
        );

        // Mettre à jour l'état avec la position actuelle
        context.read<HomeBloc>().add(
          UpdateCurrentLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            location: address,
          ),
        );
      }
    } catch (e) {
      print('Erreur de localisation: $e');
    }
  }

  // Méthode pour charger les publications à proximité
  void _loadNearbyPublications(BuildContext context, HomeState state) {
    if (state.hasLoadedInitialPublications) {
      return; // Ne pas recharger si c'est déjà fait
    }

    if (state.currentLatitude != null && state.currentLongitude != null) {
      context.read<HomeBloc>().add(
        LoadNearbyPublications(
          latitude: state.currentLatitude!,
          longitude: state.currentLongitude!,
          categoryId: state.selectedCategory?.id,
        ),
      );
    }
  }
}
