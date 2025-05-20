import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/pages/auth/login.dart';
import 'package:seddoapp/widgets/navitems.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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
            'Veuillez vous connecter d\'abord pour modifier votre profil.',
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
                backgroundColor: const Color(
                  0xFFD95C18,
                ), // Utiliser HexColor si disponible
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue

                // Naviguer vers la page de connexion
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

  // Fonction pour gérer l'appui sur le bouton Éditer le profil
  void handleEditProfileButtonPress(BuildContext context) {
    // Déclencher l'événement de vérification d'authentification
    context.read<HomeBloc>().add(const CheckAuthStatusEvent());
  }

  // Fonction pour éditer le profil si l'utilisateur est authentifié
  void editProfile(BuildContext context) {
    // Logique pour enregistrer les modifications du profil
    // Vous pouvez ajouter ici le code pour mettre à jour le profil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil mis à jour avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        // Si l'utilisateur est authentifié et a cliqué pour éditer le profil
        if (state.isAuthenticated && state.showLoginDialog == false) {
          editProfile(context);
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
        return Scaffold(
          bottomNavigationBar: CustomBottomNavigationBar(state: state),
          backgroundColor: Colors.white,
          appBar: AppBar(
            leadingWidth: 200,
            leading: Row(
              mainAxisSize:
                  MainAxisSize.min, // ← Important pour éviter l'espace inutile
              children: [
                IconButton(
                  icon: Transform.translate(
                    offset: const Offset(
                      12,
                      0,
                    ), // ← Déplace légèrement l'icône vers la droite
                    child: const Icon(Icons.arrow_back_ios, size: 20),
                  ), // ← Taille réduite si besoin
                  onPressed: () => Navigator.pop(context),
                  padding:
                      EdgeInsets
                          .zero, // ← Supprime le padding interne du bouton
                  constraints:
                      const BoxConstraints(), // ← Désactive les contraintes par défaut
                ),
                const Text(
                  'Profil',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            titleSpacing: 0, // ← Supprime l'espace réservé au titre
          ),

          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Profile Image
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icons/profile.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nom d'utilisateur
                  Text(
                    state.currentUser != null
                        ? '${state.currentUser!.firstName} ${state.currentUser!.lastName}'
                        : 'Invité',

                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    state.currentUser?.email ?? 'email@gmail.com',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  // Champ Prénom
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prénom',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _prenomController,
                        decoration: InputDecoration(
                          hintText: state.currentUser?.firstName ?? 'Prénom',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Champ Nom
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nom',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nomController,
                        decoration: InputDecoration(
                          hintText: state.currentUser?.lastName ?? 'Nom',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Champ Téléphone
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Téléphone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _telephoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          prefixIcon: Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/senegal.png', // Remplacez par le chemin de votre drapeau du Sénégal
                                  width: 24,
                                  height: 16,
                                  fit: BoxFit.contain,
                                  // En cas d'erreur, remplacez avec:
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.flag, size: 24),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(+221)',
                                  semanticsLabel: state.currentUser?.phone,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Champ Email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: state.currentUser?.email ?? 'Email',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Bouton Éditer le profil
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logique pour éditer le profil
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFE2703A,
                        ), // Couleur orange comme sur l'image
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Editer le profil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
