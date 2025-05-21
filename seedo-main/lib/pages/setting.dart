import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/auth/auth_event.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/bloc/auth/auth_bloc.dart';
import 'package:seddoapp/pages/CommandesPage.dart';
import 'package:seddoapp/pages/auth/login.dart';
import 'package:seddoapp/pages/profil.dart';
import 'package:seddoapp/utils/HexColor.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool notificationsEnabled = true;
  bool locationEnabled = false;
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(LoadCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthUnauthenticatedState) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LogIn()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final bool isLoggedIn = state.currentUser != null;

          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: Colors.grey[100],
              elevation: 0,
              title: const Text(
                'Paramètres',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      leading: const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/icons/profile.png'),
                      ),
                      title: Text(
                        isLoggedIn
                            ? '${state.currentUser!.firstName} ${state.currentUser!.lastName}'
                            : 'Invité',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        state.currentUser?.email ?? 'exemple@gmail.com',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () {
                        // Vérifier si l'utilisateur est connecté avant d'accéder au profil
                        if (isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        } else {
                          // Afficher une boîte de dialogue demandant à l'utilisateur de se connecter
                          _showLoginRequiredDialog(context);
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Mes commandes
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: HexColor('#D95C18').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.article_rounded,
                          color: HexColor('#D95C18'),
                        ),
                      ),
                      title: const Text(
                        'Mes commandes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 30,
                      ),
                      onTap: () {
                        // Vérifier si l'utilisateur est connecté avant d'accéder aux commandes
                        if (isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommandesPage(),
                            ),
                          );
                        } else {
                          // Afficher une boîte de dialogue demandant à l'utilisateur de se connecter
                          _showLoginRequiredDialog(context);
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Notifications
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: HexColor('#D95C18').withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.notifications,
                              color: HexColor('#D95C18'),
                            ),
                          ),
                          title: const Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Switch(
                            value: notificationsEnabled,
                            onChanged: (value) {
                              setState(() {
                                notificationsEnabled = value;
                              });
                            },
                            activeTrackColor: HexColor('#D95C18'),
                            activeColor: HexColor('#FFF'),
                          ),
                          onTap: () {
                            setState(() {
                              notificationsEnabled = !notificationsEnabled;
                            });
                          },
                        ),
                        const Divider(
                          height: 0.5,
                          thickness: 1,
                          color: Color.fromARGB(255, 224, 224, 224),
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: HexColor('#D95C18').withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: HexColor('#D95C18'),
                            ),
                          ),
                          title: const Text(
                            'Localisation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Switch(
                            value: locationEnabled,
                            onChanged: (value) {
                              setState(() {
                                locationEnabled = value;
                              });
                            },
                            activeTrackColor: HexColor('#D95C18'),
                            activeColor: HexColor('#FFF'),
                          ),
                          onTap: () {
                            setState(() {
                              locationEnabled = !locationEnabled;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bouton de connexion/déconnexion qui change en fonction de l'état de l'utilisateur
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: HexColor('#D95C18').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isLoggedIn ? Icons.logout : Icons.login,
                          color: HexColor('#D95C18'),
                        ),
                      ),
                      title: Text(
                        isLoggedIn ? 'Se déconnecter' : 'Se connecter',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        if (isLoggedIn) {
                          // Afficher le dialogue de confirmation de déconnexion
                          _showLogoutConfirmDialog(context);
                        } else {
                          // Rediriger vers la page de connexion
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LogIn()),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Méthode pour afficher une boîte de dialogue lorsque l'utilisateur n'est pas connecté
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connexion requise'),
          content: const Text(
            'Vous devez être connecté pour accéder à cette fonctionnalité.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LogIn()),
                );
              },
              child: const Text('Se connecter'),
              style: TextButton.styleFrom(foregroundColor: HexColor('#D95C18')),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher une boîte de dialogue de confirmation de déconnexion
  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Utiliser le bloc AuthBloc pour la déconnexion
                context.read<AuthBloc>().add(AuthLogoutEvent());

                // Afficher un message de déconnexion réussie
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vous avez été déconnecté avec succès.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Déconnecter'),
              style: TextButton.styleFrom(foregroundColor: HexColor('#D95C18')),
            ),
          ],
        );
      },
    );
  }
}
