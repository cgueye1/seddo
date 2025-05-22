// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/pages/SignalPage.dart';
import 'package:seddoapp/pages/auth/login.dart';
import 'package:seddoapp/pages/transit/TransportCommun.dart';
import 'package:seddoapp/repositories/publication_repository.dart';
import 'package:seddoapp/services/LocationService.dart';
import 'package:seddoapp/services/api_service.dart';
import 'package:seddoapp/services/publication_service.dart';
import 'package:seddoapp/utils/HexColor.dart';
import 'package:seddoapp/widgets/CustomFloatingButton.dart';
import 'package:seddoapp/widgets/home/CategoryDropdown.dart';
import 'package:seddoapp/widgets/home/PublicationsSection.dart';
import 'package:seddoapp/widgets/home/UserNameSection.dart';
import 'package:seddoapp/widgets/home/SearchBar.dart';

import '../widgets/home/ads/AdsHorizontalList.dart';
// import '../widgets/home/ads/PubWidget.dart';

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

void handleSignalButtonPress(BuildContext context) {
  // Déclencher l'événement de vérification d'authentification
  context.read<HomeBloc>().add(const CheckAuthStatusEvent());
}

class _HomePageContentState extends State<_HomePageContent> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        // Si l'utilisateur est authentifié et a cliqué pour signaler
        if (state.isAuthenticated && state.showLoginDialog == false) {
          showSignalModal(context);
        }

        // Si l'utilisateur n'est pas authentifié et doit voir le dialogue
        if (!state.isAuthenticated && state.showLoginDialog) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showLoginRequiredDialog(context);
            // Réinitialiser l'état showLoginDialog après l'affichage
            context.read<HomeBloc>().add(const ResetDialogFlagEvent());
          });
        }
      },

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
          // Ajout du bouton flottant avec navigation vers la page de signalement
          floatingActionButton: CustomFloatingButton(
            imagePath: 'assets/icons/siren.png',
            onPressed: () {
              // Use the new handler function instead of directly showing the modal
              handleSignalButtonPress(context);
            },
            label: '',
            backgroundColor: Colors.white,
            elevation: 4.0,
          ),
          // Placement du bouton en bas à droite
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body:
              SafeArea(
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
                    'Hello ',
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
                'assets/icons/notif.png',
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
          const SearchBars(),
          // Ce SearchBar doit être importé et défini correctement
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
        SizedBox(height: 10),
        _buildAds(context, state),

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

  Widget _buildAds(BuildContext context, HomeState state) {
    return Column(
      key: const ValueKey('ads'),
      children: [
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.adsList.isEmpty ||
                state.isSearching ||
                state.lastSearchKeyword!.isNotEmpty ||
                state.selectedSubcategory != null) {
              return SizedBox();
            }
            return AdsHorizontalList(adsList: state.adsList);
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

  // Fonction pour afficher la boîte de dialogue de connexion requise
  void showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Connexion requise',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Veuillez vous connecter d\'abord pour signaler une situation.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor('#D95C18'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue

                // Naviguer vers la page de connexion avec Navigator.push
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => LogIn()));
              },
              child: const Text(
                'Se connecter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
