import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

import '../../models/transit/PlaceModel.dart';

class PlaceSearchWidget extends StatefulWidget {
  final Function(PlaceModel) onLocationSelected;
  final String label;
  final Icon icon;
  final PlaceModel? initPlace;
  final FocusNode? focusNode;
  final String apiKey;


  const PlaceSearchWidget ({
    Key? key,
    required this.onLocationSelected,
    required this.label,
    required this.icon,
    this.initPlace,
    this.focusNode,
    required this.apiKey
  }) : super(key: key);

  @override
  _DakarSearchWidgetState createState() => _DakarSearchWidgetState();
}

class _DakarSearchWidgetState extends State<PlaceSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  final Duration _debounceDelay = const Duration(milliseconds: 500);
  bool positionLoader = false;
  late FocusNode _focusNode;


  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
    super.initState();
    if (widget.initPlace != null) {
      _controller.text = widget.initPlace!.name;
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      setState(() {
        positionLoader = true;
      });
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
        'https://maps.googleapis.com/maps/api/geocode/json'
            '?latlng=${position.latitude},${position.longitude}'
            '&key=${widget.apiKey}'
            '&language=fr',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final place = PlaceModel(
            latitude: position.latitude,
            longitude: position.longitude,
            name: result['formatted_address'],
            address: result['formatted_address'],
          );
          print("result__");
          print(result );

          _controller.text = place.name;
          widget.onLocationSelected(place);
          FocusScope.of(context).unfocus();
        }
      } else {
        print('Erreur reverse geocoding : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur GPS ou reverse geocoding : $e');
    } finally {
      if (mounted) {
        setState(() {
          positionLoader = false;
        });
      }
    }
  }

  Future<List<PlaceModel>> _fetchSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=${Uri.encodeQueryComponent(query)}'
            '&key=${widget.apiKey}'
            '&language=fr'
            '&components=country:sn'
            '&location=14.7167,-17.4677' // Dakar coordinates
            '&radius=50000', // 50km around Dakar
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((prediction) {
            print("predic");
            print(prediction);

            return PlaceModel(
              latitude: 0, // Temporaire, sera mis à jour dans _getPlaceDetails
              longitude: 0, // Temporaire, sera mis à jour dans _getPlaceDetails
              name: prediction['description'],
              address: prediction['description'],
              placeId:  prediction['place_id'],
            );
          }).toList();
        }
      }
    } catch (e) {
      print('Erreur lors de la recherche : $e');
    }

    return [];
  }

  Future<PlaceModel> _getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&key=${widget.apiKey}'
          '&language=fr',
    );

    final response = await http.get(url);
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final result = data['result'];
      final location = result['geometry']['location'];
      return PlaceModel(
        latitude: location['lat'].toDouble(),
        longitude: location['lng'].toDouble(),
        name: result['name'] ?? result['formatted_address'],
        address: result['formatted_address'],
      );
    }

    throw Exception('Failed to get place details');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TypeAheadField<PlaceModel>(
          suggestionsCallback: _fetchSuggestions,
          builder: (context, controller, focusNode) {
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
              ),
              style: TextStyle(fontSize: 14),
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
              subtitle: suggestion.address != suggestion.name
                  ? Text(
                suggestion.address,
                overflow: TextOverflow.ellipsis,
              )
                  : null,
            );
          },
          onSelected: (suggestion) async {
            try {

              // Pour les suggestions Google, nous devons obtenir les détails complets
              final place = await _getPlaceDetails(suggestion.placeId!); // Note: Ici nous utilisons name comme ID temporaire
              print("place.longitude");
              print(place.longitude);
              _controller.text = place.name;
              widget.onLocationSelected(place);
              FocusScope.of(context).unfocus();
            } catch (e) {
              print('Erreur lors de la sélection: $e');
              // Si l'échec, utiliser les données de base
              _controller.text = suggestion.name;
              widget.onLocationSelected(suggestion);
              FocusScope.of(context).unfocus();
            }
          },
          emptyBuilder: (context) => Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Aucun résultat trouvé',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 10),
                positionLoader
                    ? Center(
                  child: Container(
                    width: 50,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballScaleRipple,
                      colors: const [Colors.orangeAccent],
                      strokeWidth: 2,
                      backgroundColor: Colors.transparent,
                      pathBackgroundColor: Colors.transparent,
                    ),
                  ),
                )
                    : Center(
                  child: ElevatedButton.icon(
                    onPressed: _useCurrentLocation,
                    icon: Icon(Icons.my_location),
                    label: Text("Utiliser ma position actuelle"),
                  ),
                ),
              ],
            ),
          ),
          loadingBuilder: (context) => Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }
}