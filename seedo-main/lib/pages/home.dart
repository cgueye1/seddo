import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
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
class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  static final tabIndicatorWidth = 120.0;

  @override
  Widget build(BuildContext context) {
    // Now we can safely access the HomeBloc from the context
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          // Ajout de la barre de navigation fixe en bas
          bottomNavigationBar: _buildBottomNavigationBar(context, state),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                children: [
                  // Main Yellow Header Block
                  _buildHeaderBlock(context, state),
                  // Contenu basé sur l'onglet sélectionné
                  state.selectedTabIndex == 0
                      ? _buildPublicationsContent(context, state)
                      : _buildMapContent(context, state),
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
                  displayImagePath,
                  width: iconSize,
                  height: iconSize,
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
      height: 175,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 243, 175, 5),
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
              Row(
                children: [
                  Image.asset(
                    'assets/icons/siren.png',
                    width: 30,
                    height: 30,
                    color: const Color.fromARGB(255, 202, 33, 21),
                  ),
                  const SizedBox(width: 16),
                  Image.asset(
                    'assets/icons/settings.png',
                    width: 26,
                    height: 26,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
              ),
            ],
          ),
          // Section de localisation - Modifiée pour afficher l'icône de localisation
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: HexColor('#D95C18')),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  state.currentLocation,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Search Bar
          const SizedBox(height: 16),
          const SearchBars(), // Ce SearchBar doit être importé et défini correctement
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tab Publications
              GestureDetector(
                onTap: () {
                  context.read<HomeBloc>().add(const TabChanged(tabIndex: 0));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        'Publications',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color:
                              state.selectedTabIndex == 0
                                  ? Colors.black
                                  : const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Map
              GestureDetector(
                onTap: () {
                  context.read<HomeBloc>().add(const TabChanged(tabIndex: 1));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Text(
                        'Map',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color:
                              state.selectedTabIndex == 1
                                  ? Colors.black
                                  : const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Barre de navigation animée
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(height: 2, color: const Color.fromARGB(0, 42, 42, 42)),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 2,
                width: tabIndicatorWidth,
                margin: EdgeInsets.only(
                  left:
                      state.selectedTabIndex == 0
                          ? 0
                          : MediaQuery.of(context).size.width -
                              1 * 2 -
                              tabIndicatorWidth -
                              1,
                ),
                color: const Color.fromARGB(255, 36, 36, 36),
              ),
            ],
          ),
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
              _loadNearbyPublications(context, state);
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

  Widget _buildMapContent(BuildContext context, HomeState state) {
    // Modifiez _buildMapContent pour utiliser Google Maps ou une autre bibliothèque de cartographie
    return Column(
      key: const ValueKey('map'),
      children: [
        Container(
          height: 500,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "Carte des restaurants",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              // Bouton pour rafraîchir la localisation sur la carte
              ElevatedButton.icon(
                onPressed: () {
                  context.read<HomeBloc>().add(const LoadCurrentLocation());
                },
                icon: const Icon(Icons.my_location),
                label: const Text("Ma position"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('#D95C18'),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
