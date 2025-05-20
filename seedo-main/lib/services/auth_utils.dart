// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/pages/auth/login.dart';
import 'package:seddoapp/utils/HexColor.dart';

class AuthUtils {
  /// Vérifie si l'utilisateur est connecté, retourne true si c'est le cas.
  /// Sinon affiche une boîte de dialogue et retourne false.
  static bool checkAuthentication(
    BuildContext context, {
    String? customMessage,
  }) {
    // Récupérer l'état actuel
    final state = context.read<HomeBloc>().state;
    final bool isLoggedIn = state.currentUser != null;

    if (!isLoggedIn) {
      // Afficher la boîte de dialogue de connexion requise
      showLoginRequiredDialog(
        context,
        message:
            customMessage ??
            'Vous devez être connecté pour accéder à cette fonctionnalité.',
      );
      return false;
    }

    return true;
  }

  /// Affiche une boîte de dialogue demandant à l'utilisateur de se connecter
  static void showLoginRequiredDialog(
    BuildContext context, {
    String message =
        'Vous devez être connecté pour accéder à cette fonctionnalité.',
  }) {
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
          content: Text(message, style: const TextStyle(fontSize: 16)),
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
