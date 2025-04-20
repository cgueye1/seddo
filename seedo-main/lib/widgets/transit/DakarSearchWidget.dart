import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../models/transit/PlaceModel.dart';
class DakarSearchWidget extends StatefulWidget {
  final Function(PlaceModel) onLocationSelected;
  final String label;
  final Icon icon;

  const DakarSearchWidget({Key? key, required this.onLocationSelected, required this.label, required this.icon}) : super(key: key);

  @override
  _DakarSearchWidgetState createState() => _DakarSearchWidgetState();
}

class _DakarSearchWidgetState extends State<DakarSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  final Duration _debounceDelay = const Duration(milliseconds: 500);

  static const double dakarLat = 14.7167;
  static const double dakarLon = -17.4677;
  Future<void> _useCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permission refusée');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permission refusée en permanence');
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json'
            '&lat=${position.latitude}&lon=${position.longitude}'
            '&addressdetails=1',);

      final response = await http.get(url, headers: {
        'User-Agent': 'solimus/1.0 (contactwakana@gmail.com)',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final place = PlaceModel(
          latitude: position.latitude,
          longitude: position.longitude,
          name: data['name'] ?? data['display_name'] ?? 'Ma position actuelle',
          address:_formatAddress(data['address']),
        );

        _controller.text = place.name;
        widget.onLocationSelected(place);
        FocusScope.of(context).unfocus();
        print('place.name');
        print(place.name);

      } else {
        print('Erreur reverse geocoding : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur GPS ou reverse geocoding : $e');
    }
  }
  static String _formatAddress(Map<String, dynamic>? address) {
    if (address == null) return '';

    final parts = [
      address['road'],
      address['neighbourhood'],
      address['suburb'],
      address['city_district'],
      address['city'],
      address['country'],
    ].where((part) => part != null).toList();

    return parts.join(', ');
  }

  Future<List<PlaceModel>> _fetchSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search'
              '?format=json'
              '&q=${Uri.encodeComponent(query)}'
              '&addressdetails=1'
              '&limit=5'
              '&countrycodes=sn'
              '&viewbox=${dakarLon - 0.3},${dakarLat + 0.3},${dakarLon + 0.3},${dakarLat - 0.3}'
              '&bounded=1');

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'solimus/1.0 (contactwakana@gmail.com)',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => PlaceModel.fromJson(item)).toList();
      } else {
        print('Erreur HTTP : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la recherche : $e');
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TypeAheadField<PlaceModel>(
          suggestionsCallback: (pattern) async {
            if (pattern.length < 3) return [];
            return await _fetchSuggestions(pattern);
          },
          builder: (context, controller, focusNode) {

            // Synchronisation manuelle
            if (!focusNode.hasFocus && _controller.text != controller.text) {
              controller.text = _controller.text;
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            }
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: 'Ex: Plateau, Almadies, Sacré Coeur...',
                prefixIcon: widget.icon,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (text) {
                if (_debounceTimer?.isActive ?? false) {
                  _debounceTimer?.cancel();
                }
                _debounceTimer = Timer(_debounceDelay, () {
                  if (mounted) setState(() {});
                });
              },
            );
          },
          itemBuilder: (context, suggestion) {
            return ListTile(
              leading: Icon(Icons.location_on, color: Colors.blue),
              title: Text(
                suggestion.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                suggestion.address,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
          onSelected: (suggestion) {
            _controller.text = suggestion.name;
            widget.onLocationSelected(suggestion);
            FocusScope.of(context).unfocus();
          },
          emptyBuilder: (context) => Padding(
            padding: EdgeInsets.all(16),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aucun résultat trouvé',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _useCurrentLocation,
                  icon: Icon(Icons.my_location),
                  label: Text("Utiliser ma position actuelle"),
                ),
              ],
            ),
          ),
          loadingBuilder: (context) => Center(child: CircularProgressIndicator()),
        ),
        if (_controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Recherche limitée à la région de Dakar',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
