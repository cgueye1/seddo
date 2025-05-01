import 'package:flutter/material.dart';
import '../../models/transit/PlaceModel.dart';
import '../../services/transit/FavoritePlaceService.dart';
import 'DakarSearchWidget.dart';

class FavoritePlacesWidget extends StatefulWidget {
  final Function(PlaceModel) onFavoritePlaceSelected; // Add callback

  FavoritePlacesWidget({required this.onFavoritePlaceSelected});

  @override
  _FavoritePlacesWidgetState createState() => _FavoritePlacesWidgetState();
}

class _FavoritePlacesWidgetState extends State<FavoritePlacesWidget> {
  final _service = FavoritePlaceService();
  Map<String, PlaceModel?> favoris = {
    'home': null,
    'work': null,
    'school': null,
  };

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    favoris['home'] = await _service.getFavorite('home');
    favoris['work'] = await _service.getFavorite('work');
    favoris['school'] = await _service.getFavorite('school');
    setState(() {});

  }

  Widget _buildFavoriteTile({
    required String label,
    required IconData icon,
    required String key,
  }) {
    final place = favoris[key];
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        place?.name ?? 'Ajouter une adresse',
        style: TextStyle(fontWeight: FontWeight.w400, color: Colors.grey),
      ),
      trailing:
          place != null
              ? IconButton(
                onPressed: () => _handleFavoriteTap(null, key),
                icon: Icon(Icons.edit, color: Colors.grey),
              )
              : Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
      onTap: () => _handleFavoriteTap(place, key),
    );
  }

  void _handleFavoriteTap(PlaceModel? favori, String key) async {
    if (favori == null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (context) {
          final screenHeight = MediaQuery.of(context).size.height;
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

          // Si le clavier est ouvert, la hauteur du bottom sheet sera réduite.
          final sheetHeight =
              keyboardHeight > 0
                  ? screenHeight - keyboardHeight
                  : screenHeight * 0.5;

          return SizedBox(
            height: sheetHeight, // Ajuste la taille en fonction du clavier
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: DakarSearchWidget(
                label: 'Choisissez un lieu',
                icon: Icon(Icons.location_on),
                onLocationSelected: (selectedPlace) async {
                  Navigator.of(context).pop();
                  setState(() {
                    favoris[key] = selectedPlace;
                  });
                  await _service.saveFavorite(key, selectedPlace);
                },
              ),
            ),
          );
        },
      );
    } else {
      widget.onFavoritePlaceSelected(favori);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(

    padding: EdgeInsets.only(left: 16, right: 16,bottom: 16),
    child:Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20,),
       Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Favoris", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.grey)),
              Text(""),
            ],
          ),

        _buildFavoriteTile(label: 'Maison', icon: Icons.home, key: 'home'),
   Divider(height: .1),
        _buildFavoriteTile(label: 'Bureau', icon: Icons.work, key: 'work'),

          Divider(),

        _buildFavoriteTile(label: 'École', icon: Icons.school, key: 'school'),
      ],
    )
    );
  }
}
