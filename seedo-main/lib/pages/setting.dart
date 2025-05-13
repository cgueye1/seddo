import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/pages/CommandesPage.dart';
import 'package:seddoapp/pages/profil.dart';
import 'package:seddoapp/utils/HexColor.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool notificationsEnabled = true;
  bool locationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor:
              Colors.grey[100], // Mise à jour de la couleur de fond
          appBar: AppBar(
            backgroundColor:
                Colors.grey[100], // Mise à jour de la couleur de l'AppBar
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
              vertical: 10.0, // Réduction du padding vertical
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                Container(
                  decoration: BoxDecoration(
                    color:
                        Colors
                            .white, // Mise à jour de la couleur du fond en blanc
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ), // Ajout de padding vertical
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/icons/profile.png'),
                    ),
                    title: Text(
                      state.currentUser != null
                          ? '${state.currentUser!.firstName} ${state.currentUser!.lastName}'
                          : 'Cheikh Gueye', // Mise à jour du nom par défaut
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      state.currentUser?.email ??
                          'chgueye@gmail.com', // Mise à jour de l'email par défaut
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
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
                      child: Icon(Icons.article, color: HexColor('#D95C18')),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommandesPage(),
                        ),
                      );
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

                // Se déconnecter
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
                      child: Icon(Icons.logout, color: HexColor('#D95C18')),
                    ),
                    title: const Text(
                      'Se déconnecter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      // Logique de déconnexion
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
