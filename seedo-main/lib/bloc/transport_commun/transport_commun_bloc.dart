import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../models/transit/PlaceModel.dart';
import '../../services/LocationService.dart';

part 'transport_commun_event.dart';
part 'transport_commun_state.dart';

class TransportCommunBloc extends Bloc<TransportCommunEvent, TransportCommunState> {
  static const double dakarLat = 14.7167;
  static const double dakarLon = -17.4677;
  Timer? _debounceTimer;
  final LocationService locationService = LocationService();


  TransportCommunBloc() : super(const TransportCommunState()) {
    on<TransportCommunInit>(_onInit);
    on<OriginSelected>(_onOriginSelected);
    on<DestinationSelected>(_onDestinationSelected);
    on<SearchLocation>(_onSearchLocation);
    on<UseCurrentLocation>(_onUseCurrentLocation);
  }

  Future<void> _onInit(
      TransportCommunInit event,
      Emitter<TransportCommunState> emit,
      ) async {

  }

  void _onOriginSelected(
      OriginSelected event,
      Emitter<TransportCommunState> emit,
      ) {
    emit(state.copyWith(
      origin: event.origin,
      status: TransportCommunStatus.success,
    ));
  }

  void _onDestinationSelected(
      DestinationSelected event,
      Emitter<TransportCommunState> emit,
      ) {
    emit(state.copyWith(
      destination: event.destination,
      status: TransportCommunStatus.success,
    ));
  }

  Future<void> _onSearchLocation(
      SearchLocation event,
      Emitter<TransportCommunState> emit,
      ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(searchResults: []));
      return;
    }

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await Future.delayed(Duration(seconds: 2));
      emit(state.copyWith(status: TransportCommunStatus.loading));

      try {
        final results = await _fetchSuggestions(event.query);
        emit(state.copyWith(
          searchResults: results,
          status: TransportCommunStatus.success,
        ));
      } catch (e) {
        emit(state.copyWith(
          errorMessage: e.toString(),
          status: TransportCommunStatus.failure,
        ));
      }
    });
  }

  Future<void> _onUseCurrentLocation(
      UseCurrentLocation event,
      Emitter<TransportCommunState> emit,
      ) async {
    emit(state.copyWith(status: TransportCommunStatus.loading));

    try {
      final position = await locationService.getCurrentLocation();
      final place = await _reverseGeocode(position!);

      // Selon le contexte, mettez à jour l'origine ou la destination
      emit(state.copyWith(
        status: TransportCommunStatus.success,
        origin: place, // ou destination: place selon le besoin
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
        status: TransportCommunStatus.failure,
      ));
    }
  }

  Future<List<PlaceModel>> _fetchSuggestions(String query) async {
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
      headers: {'User-Agent': 'solimus/1.0 (contactwakana@gmail.com)'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => PlaceModel.fromJson(item)).toList();
    }
    throw Exception('Failed to load suggestions');
  }


  Future<PlaceModel> _reverseGeocode(Position position) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json'
          '&lat=${position.latitude}&lon=${position.longitude}'
          '&addressdetails=1',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'solimus/1.0 (contactwakana@gmail.com)',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PlaceModel(
        latitude: position.latitude,
        longitude: position.longitude,
        name: data['name'] ?? data['display_name'] ?? 'Ma position actuelle',
        address: _formatAddress(data['address']),
      );
    }
    throw Exception('Failed to reverse geocode');
  }

  String _formatAddress(Map<String, dynamic>? address) {
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

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}