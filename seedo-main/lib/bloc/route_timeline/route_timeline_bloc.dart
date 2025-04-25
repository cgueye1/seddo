import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/AppParamModel.dart';
import '../../models/transit/PlaceModel.dart';
import '../../models/transit/StopTimeResponse.dart';
import '../../models/transit/TransitResponseModel.dart';
import '../../repositories/defaultRepository.dart';
import '../../services/AdMobService.dart';
import '../../services/LocationService.dart';
import '../../utils/location.dart';

part 'route_timeline_event.dart';

part 'route_timeline_state.dart';

class RouteTimelineBloc extends Bloc<RouteTimelineEvent, RouteTimelineState> {
  final DefaultRepository repository = DefaultRepository();
  final LocationService locationService = LocationService();
  final AdService adService = AdService();

  int maxDistanceToIncrementCount = 0;
  int maxDistanceFromIncrementCount = 0;

  StreamSubscription<Position>? positionStreamSubscription;

  RouteTimelineBloc() : super(const RouteTimelineState()) {
    on<RouteTimelineInitialized>(_onInitialized);
    on<RouteTimelineDepartureDataRequested>(_onDepartureDataRequested);
    on<RouteTimelineCurrentPositionUpdated>(_onCurrentPositionUpdated);
    on<RouteTimelineDispose>(_onDispose);
  }

  @override
  Future<void> close() async {
    adService.dispose();
    await positionStreamSubscription?.cancel();
    return super.close();
  }

  Future<void> _onInitialized(
    RouteTimelineInitialized event,
    Emitter<RouteTimelineState> emit,
  ) async {
    final appParam = await _getAppParam();
    emit(state.copyWith(status: RouteTimelineStatus.loading));

    try {
      final currentPosition = await locationService.getCurrentLocation();
      double startLat = event.fromPlaceDetails?.latitude ?? 0;
      double startLon = event.fromPlaceDetails?.longitude ?? 0;
      double endLat = event.toPlaceDetails?.latitude ?? 0;
      double endLon = event.toPlaceDetails?.longitude ?? 0;

      emit(
        state.copyWith(
          appParam: appParam,
          status: RouteTimelineStatus.success,
          startLat: startLat,
          startLon: startLon,
          endLat: endLat,
          endLon: endLon,
        ),
      );

      positionStreamSubscription = locationService.getPositionStream().listen((
        position,
      ) {
        add(RouteTimelineCurrentPositionUpdated(position));
      });

      if (DistanceUtils().calculateDistanceByLL(
            startLat,
            startLon,
            endLat,
            endLon,
          ) >=
          0.5) {
        await retryUntilDepartureDataFound(
          startLat: startLat,
          startLon: startLon,
          endLat: endLat,
          endLon: endLon,
          emit: emit,
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RouteTimelineStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _showInterstitialAd() async {
    // Délai minimum avant d'afficher la pub (3 secondes)
    await Future.delayed(Duration(seconds: 3));
    await adService.showInterstitialAd();
  }

  Future<void> _onDepartureDataRequested(
    RouteTimelineDepartureDataRequested event,
    Emitter<RouteTimelineState> emit,
  ) async {
    await getDepartureData(
      startLat: event.startLat,
      startLon: event.startLon,
      endLat: event.endLat,
      endLon: event.endLon,
      emit: emit,
    );
  }

  void _onCurrentPositionUpdated(
    RouteTimelineCurrentPositionUpdated event,
    Emitter<RouteTimelineState> emit,
  ) {
    emit(state.copyWith(currentPosition: event.position));
  }

  Future<void> _onDispose(
    RouteTimelineDispose event,
    Emitter<RouteTimelineState> emit,
  ) async {
    await positionStreamSubscription?.cancel();
  }

  Future<TransitResponseModel?> _findTrips(
    double dlat,
    double dlon,
    double alat,
    double alon,
    bool orderByFrom,
    int maxDistanceFrom,
    int maxDistanceTo,
  ) async {
    final body = {
      "departureLat": dlat,
      "departureLon": dlon,
      "destinationLat": alat,
      "destinationLon": alon,
      "maxDistanceFrom": maxDistanceFrom,
      "maxDistanceTo": maxDistanceTo,
      "type": "",
      "orderByFrom": orderByFrom,
    };

    final response = await repository.saveBodyFree(
      body,
      "transit/stops/findTrips",
    );

    if (response.data != null && response.data is Map<String, dynamic>) {
      return TransitResponseModel.fromJson(response.data);
    }
    return null;
  }

  Future<void> retryUntilDepartureDataFound({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
    required Emitter<RouteTimelineState> emit,
  }) async {
    var maxDistanceFrom = state.maxDistanceFrom;
    var maxDistanceTo = state.maxDistanceTo;
    emit(state.copyWith(adShown: false));
    await getDepartureData(
      startLat: startLat,
      startLon: startLon,
      endLat: endLat,
      endLon: endLon,
      emit: emit,
    );

    while (state.departureTransit.isEmpty) {
      if (maxDistanceToIncrementCount < 5) {
        maxDistanceTo += 500;
        maxDistanceToIncrementCount++;
      } else if (maxDistanceFromIncrementCount < 5) {
        maxDistanceFrom += 500;
        maxDistanceFromIncrementCount++;
        maxDistanceToIncrementCount = 0;
      } else {
        emit(
          state.copyWith(
            status: RouteTimelineStatus.success,
            errorMessage: 'No transit data found after multiple retry loops',
          ),
        );
        break;
      }

      emit(
        state.copyWith(
          maxDistanceFrom: maxDistanceFrom,
          maxDistanceTo: maxDistanceTo,
        ),
      );

      await getDepartureData(
        startLat: startLat,
        startLon: startLon,
        endLat: endLat,
        endLon: endLon,
        emit: emit,
      );

      if (state.departureTransit.isNotEmpty) {
        if (!state.adShown &&
            state.appParam != null &&
            !state.appParam!.hideAds) {
          await _showInterstitialAd();
          emit(state.copyWith(adShown: true));
        }
        break;
      }
    }
  }

  Future<void> getDepartureData({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
    required Emitter<RouteTimelineState> emit,
  }) async {
    var maxDistanceFrom = state.maxDistanceFrom;
    var maxDistanceTo = state.maxDistanceTo;
    var departureTransit = [...state.departureTransit];

    emit(state.copyWith(departureLoader: true));

    TransitResponseModel? data = await _findTrips(
      startLat,
      startLon,
      endLat,
      endLon,
      false,
      maxDistanceFrom,
      maxDistanceTo,
    );

    print('sddsdsd');

    if (data != null) {
      double firstDistanceDepartureToStop = data.distanceToDestination!;
      double distanceDepartureToStop = data.distanceDepartureToStop!;
      departureTransit.add(data);

      emit(state.copyWith(departureTransit: departureTransit));

      if (distanceDepartureToStop > 1000) {
        maxDistanceTo = 1000;
        maxDistanceFrom = 1000;

        TransitResponseModel? stepData = await _findTrips(
          startLat,
          startLon,
          data.stopStart!.stopLat,
          data.stopStart!.stopLon,
          true,
          maxDistanceFrom,
          maxDistanceTo,
        );

        if (stepData != null &&
            stepData.distanceToDestination! <= 1000 &&
            firstDistanceDepartureToStop > stepData.distanceDepartureToStop! &&
            stepData.distanceToDestination! < data.distanceToDestination!) {
          // Uncomment if stepData should be added
          // departureTransit.insert(0, stepData);
        }
      }

      int iterationCount = 0;
      maxDistanceTo = 500;
      maxDistanceFrom = 500;

      while (data!.distanceToDestination! > 1000 && iterationCount < 20) {
        maxDistanceTo += 100;
        maxDistanceFrom += 100;
        iterationCount++;

        TransitResponseModel? stepDataEnd = await _findTrips(
          data.stopEnd!.stopLat,
          data.stopEnd!.stopLon,
          endLat,
          endLon,
          false,
          maxDistanceFrom,
          maxDistanceTo,
        );

        if (stepDataEnd != null &&
            _checkForDuplicateStopId(departureTransit, stepDataEnd) &&
            stepDataEnd.distanceToDestination! <=
                data.distanceToDestination! / 2 &&
            (stepDataEnd.distanceDepartureToStop! +
                    stepDataEnd.distanceToDestination!) <
                data.distanceToDestination!) {
          if (stepDataEnd.trip!.tripId.trim() == data.trip!.tripId.trim() ||
              stepDataEnd.stopEnd!.stopId == data.stopEnd!.stopId) {
            if (departureTransit.isNotEmpty &&
                departureTransit.last.stopEnd != stepDataEnd.stopEnd) {
              departureTransit[departureTransit.length - 1] = stepDataEnd;
            } else if (departureTransit.isEmpty ||
                departureTransit.last.stopEnd == stepDataEnd.stopEnd) {
              departureTransit.add(stepDataEnd);
            }
            data = stepDataEnd;
          } else {
            if (stepDataEnd.distanceDepartureToStop! < 2000) {
              departureTransit.add(stepDataEnd);
              maxDistanceTo = 500;
              maxDistanceFrom = 500;
            }
            data = stepDataEnd;
          }

          emit(
            state.copyWith(
              departureTransit: [...departureTransit],
              maxDistanceTo: maxDistanceTo,
              maxDistanceFrom: maxDistanceFrom,
            ),
          );
        }
      }
    }

    emit(state.copyWith(departureLoader: false));
  }

  bool _checkForDuplicateStopId(
    List<TransitResponseModel> data,
    TransitResponseModel tr,
  ) {
    return !data.any((item) => item.stopEnd!.stopId == tr.stopEnd!.stopId);
  }

  Future<AppParamModel> _getAppParam() async {
    try {
      final response = await repository.getData("/appparam");

      if (response.data != null) {
        return AppParamModel.fromJson(response.data);
      } else {
        return AppParamModel(
          id: 0,
          hideAds: false,
          hideTransit: false,
          appVersion: "",
          androidLink:
              "https://apps.apple.com/us/app/seddo/id6737347803?l=fr-FR",
          iosLink:
              "https://play.google.com/store/apps/details?id=com.wakana.seddo&hl=ln",
        );
      }
    } catch (e) {
      return AppParamModel(
        id: 0,
        hideAds: false,
        hideTransit: false,
        appVersion: "",
        androidLink: "https://apps.apple.com/us/app/seddo/id6737347803?l=fr-FR",
        iosLink:
            "https://play.google.com/store/apps/details?id=com.wakana.seddo&hl=ln",
      );
    }
  }
}
