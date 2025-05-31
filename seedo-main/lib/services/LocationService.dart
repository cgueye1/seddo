import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  /// Coordonnées par défaut : Dakar
  static const double defaultLatitude = 14.6928;
  static const double defaultLongitude = -17.4467;

  Future<Position> getCurrentLocation() async {

    bool serviceEnabled;
    LocationPermission permission;

   // serviceEnabled = await Geolocator.isLocationServiceEnabled();
  /*  if (!serviceEnabled) {
      print(
        'Les services de localisation sont désactivés. Position par défaut utilisée.',
      );
      return _defaultPosition();
    }*/

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Permission refusée. Position par défaut utilisée.');
        return _defaultPosition();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permission définitivement refusée. Position par défaut utilisée.');
      return _defaultPosition();
    }

    try {
      print("whattt");
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      print("Erreur lors de la récupération de la position : $e");
      return _defaultPosition();
    }
  }

  /// Position par défaut (Dakar)
  Position _defaultPosition() {
    return Position(
      latitude: defaultLatitude,
      longitude: defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  // Obtenir une adresse simplifiée à partir des coordonnées
  Future<String> getAddressFromCoordinates(Position position) async {
    try {
      // Essayer d'abord avec Nominatim pour une meilleure précision du quartier
      String nominatimResult = await getNominatimAddress(
        position.latitude,
        position.longitude,
      );

      // Si Nominatim a trouvé un résultat, l'utiliser
      if (nominatimResult != "Position actuelle") {
        return nominatimResult;
      }

      // Sinon, revenir à la méthode geocoding standard comme fallback
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: "fr_FR",
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String subLocality = place.subLocality ?? '';
        String locality = place.locality ?? '';

        if (subLocality.isNotEmpty && locality.isNotEmpty) {
          return "$subLocality, $locality";
        } else if (subLocality.isNotEmpty) {
          return subLocality;
        } else if (locality.isNotEmpty) {
          return locality;
        }
      }

      return "Position (${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)})";
    } catch (e) {
      print('Erreur lors de la récupération de l\'adresse: $e');
      return "Position actuelle";
    }
  }

  Future<String> getNominatimAddress(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SEDDO',
        }, // Remplacez par le nom de votre application
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Extraire les informations de quartier
        final Map<String, dynamic> address = data['address'];
        String? neighbourhood = address['neighbourhood'];
        String? suburb = address['suburb'];
        String? district = address['district'];
        String? city = address['city'] ?? address['town'] ?? address['village'];

        String result = '';

        // Utiliser la première information de quartier disponible
        if (neighbourhood != null && neighbourhood.isNotEmpty) {
          result = neighbourhood;
        } else if (suburb != null && suburb.isNotEmpty) {
          result = suburb;
        } else if (district != null && district.isNotEmpty) {
          result = district;
        }

        // Ajouter la ville si disponible
        if (result.isNotEmpty && city != null && city.isNotEmpty) {
          result += ", $city";
        } else if (city != null && city.isNotEmpty) {
          result = city;
        }

        return result.isNotEmpty ? result : "Position actuelle";
      }

      return "Position actuelle";
    } catch (e) {
      print('Erreur lors de la récupération des données Nominatim: $e');
      return "Position actuelle";
    }
  }

  // S'abonner aux mises à jour de position
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
