import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seddoapp/bloc/home/home_bloc.dart';
import 'package:seddoapp/bloc/home/home_event.dart';
import 'package:seddoapp/bloc/home/home_state.dart';
import 'package:seddoapp/pages/home.dart';
import 'package:seddoapp/pages/setting.dart';
import 'package:seddoapp/pages/sms.dart';
import 'package:seddoapp/pages/transit/TransportCommun.dart';
import 'package:seddoapp/utils/HexColor.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final HomeState state;

  const CustomBottomNavigationBar({Key? key, required this.state})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        color: const Color.fromARGB(255, 255, 255, 255),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3), // Bordure grise légère
          width: 1.0, // Épaisseur de la bordure
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ), // Ombre portée vers le haut
        ],
      ),
      height: 65, // Hauteur augmentée (était 60)
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, 'assets/icons/hom.png', 'Accueil', state),
          _buildNavItem(context, 1, 'assets/icons/Sms.png', 'SMS', state),
          _buildNavItem(context, 2, 'assets/icons/Bus.png', 'Transport', state),
          _buildNavItem(
            context,
            3,
            'assets/icons/param.png',
            'Paramètres',
            state,
          ),
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
    final isSelected = index == state.currentNavigationIndex;
    final iconSize = 28.0;
    final displayImagePath =
        isSelected
            ? imagePath.replaceFirst('.png', '_selected.png')
            : imagePath;
    final Color iconColor =
        isSelected ? HexColor("#D95C18") : const Color.fromARGB(255, 0, 0, 0);

    return InkWell(
      onTap: () {
        // Éviter de recharger la page si déjà sélectionnée
        if (!isSelected) {
          context.read<HomeBloc>().add(
            NavigationIndexChanged(navigationIndex: index),
          );

          // Navigation vers la page correspondante
          _navigateToPage(context, index);
        }
      },
      splashColor: const Color.fromARGB(90, 0, 0, 0),
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
                  color: iconColor,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color:
                    isSelected
                        ? HexColor("#D95C18")
                        : const Color.fromARGB(255, 113, 113, 113),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SmsPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TransportCommun()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingPage()),
        );
        break;
    }
  }
}
