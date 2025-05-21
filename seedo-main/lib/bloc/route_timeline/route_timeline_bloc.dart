import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../models/AppParamModel.dart';
import '../../models/campaign/CampaignWinnerDTOModel.dart';
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
  final AdService adService = AdService();

  int maxDistanceToIncrementCount = 0;
  int maxDistanceFromIncrementCount = 0;
  final LocationService locationService = LocationService();

  StreamSubscription<Position>? positionStreamSubscription;

  RouteTimelineBloc() : super(const RouteTimelineState()) {
    on<RouteTimelineInitialized>(_onInitialized);
    on<RouteTimelineDepartureDataRequested>(_onDepartureDataRequested);
    on<RouteTimelineCurrentPositionUpdated>(_onCurrentPositionUpdated);
    on<RouteTimelineDispose>(_onDispose);
    on<RouteTimelineTabChanged>((event, emit) async {
      emit(state.copyWith(itineraireIndex: event.index));
    });
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
    emit(
      state.copyWith(
        status: RouteTimelineStatus.loading,
        departureTransit: [],
        itineraireIndex: event.index,
        appParam: appParam,
      ),
    );

    try {
      final currentPosition = await locationService.getCurrentLocation();
      double startLat = event.fromPlaceDetails?.latitude ?? 0;
      double startLon = event.fromPlaceDetails?.longitude ?? 0;
      double endLat = event.toPlaceDetails?.latitude ?? 0;
      double endLon = event.toPlaceDetails?.longitude ?? 0;

      String date = event.date;
      String time = event.time;
      int itineraireIndex = event.index;

      emit(
        state.copyWith(
          appParam: appParam,
          status: RouteTimelineStatus.success,
          startLat: startLat,
          startLon: startLon,
          endLat: endLat,
          endLon: endLon,
          currentPosition: currentPosition,
          itineraireIndex: itineraireIndex,
          date: date,
          time: time,
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

        if (event.canShowAd &&
            state.appParam != null &&
            !state.appParam!.hideAds) {

          await _showInterstitialAd();

        }


      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RouteTimelineStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }

    /*final campaignTopWinner = await _getCampaignTop();

    emit(state.copyWith(campaignToWinners: campaignTopWinner));*/
  }

  Future<void> _showInterstitialAd() async {
    // Délai minimum avant d'afficher la pub (3 secondes)
    await Future.delayed(Duration(seconds: 1));

    await adService.showInterstitialAd();

  }

  Future<void> _onDepartureDataRequested(
    RouteTimelineDepartureDataRequested event,
    Emitter<RouteTimelineState> emit,
  ) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd').format(now); // ex: "20250515"
    final formattedTime = DateFormat('HH:mm:ss').format(now); // ex: "14:32:07"

    await getDepartureData(
      startLat: event.startLat,
      startLon: event.startLon,
      endLat: event.endLat,
      endLon: event.endLon,
      emit: emit,
      formattedDate: formattedDate,
      formattedTime: formattedTime,
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

  Future<TransitFullResponseModel?> _findTrips(
    double dlat,
    double dlon,
    double alat,
    double alon,
    bool orderByFrom,
    int maxDistanceFrom,
    int maxDistanceTo,
    String formattedDate,
    String formattedTime,
  ) async {
    String date = state.date;
    String time = state.time;

    final body = {
      "date": date.isEmpty ? formattedDate : date,
      "time": time.isEmpty ? formattedTime : time,
      "stopId": "",
      "start_stop_code": "",
      "end_stop_code": "",
      "arrivalStopId": "",
      "departureLat": dlat,
      "departureLon": dlon,
      "destinationLat": alat,
      "destinationLon": alon,
      "maxDistanceFrom": maxDistanceFrom,
      "maxDistanceTo": maxDistanceTo,
      "type": "string",
      "orderByFrom": orderByFrom,
      "index": state.itineraireIndex,
    };

    final response = await repository.saveBody(body, "transit/stops/findBus");

    if (response.data != null && response.data is Map<String, dynamic>) {
      return TransitFullResponseModel.fromJson(response.data);
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
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd').format(now); // ex: "20250515"
    final formattedTime = DateFormat('HH:mm:ss').format(now); // ex: "14:32:07"
    await getDepartureData(
      startLat: startLat,
      startLon: startLon,
      endLat: endLat,
      endLon: endLon,
      emit: emit,
      formattedDate: formattedDate,
      formattedTime: formattedTime,
    );

    while (state.departureTransit.isEmpty) {
      if (maxDistanceToIncrementCount < 5) {
        maxDistanceTo += 500;

        maxDistanceToIncrementCount++;
      } else if (maxDistanceFromIncrementCount < 5) {
        maxDistanceFrom += 500;
        maxDistanceFromIncrementCount++;
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

      final now = DateTime.now();
      final formattedDate = DateFormat(
        'yyyyMMdd',
      ).format(now); // ex: "20250515"
      final formattedTime = DateFormat(
        'HH:mm:ss',
      ).format(now); // ex: "14:32:07"

      await getDepartureData(
        startLat: startLat,
        startLon: startLon,
        endLat: endLat,
        endLon: endLon,
        emit: emit,
        formattedDate: formattedDate,
        formattedTime: formattedTime,
      );


      if (state.departureTransit.isNotEmpty) {
        emit(state.copyWith(itineraireSize: state.departureTransit.first.size));




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
    required formattedDate,
    required formattedTime,
  }) async {
    var maxDistanceFrom = state.maxDistanceFrom;
    var maxDistanceTo = state.maxDistanceTo;
    var departureTransit = [...state.departureTransit];

    emit(state.copyWith(departureLoader: true));

    TransitFullResponseModel? data = await _findTrips(
      startLat,
      startLon,
      endLat,
      endLon,
      false,
      maxDistanceFrom,
      maxDistanceTo,
      formattedDate,
      formattedTime,
    );

    if (data != null) {
      double firstDistanceDepartureToStop =
          data.mainTripInfo!.distanceToDestination!;
      double distanceDepartureToStop =
          data.mainTripInfo!.distanceDepartureToStop!;
      departureTransit.add(data);

      emit(state.copyWith(departureTransit: departureTransit));

      if (distanceDepartureToStop > 1000) {
        maxDistanceTo = 1000;
        maxDistanceFrom = 1000;
        final now = DateTime.now();
        final formattedDate = DateFormat(
          'yyyyMMdd',
        ).format(now); // ex: "20250515"
        final formattedTime = DateFormat(
          'HH:mm:ss',
        ).format(now); // ex: "14:32:07"
        TransitFullResponseModel? stepData = await _findTrips(
          startLat,
          startLon,
          data.mainTripInfo!.stopStart!.stopLat,
          data.mainTripInfo!.stopStart!.stopLon,
          true,
          maxDistanceFrom,
          maxDistanceTo,
          formattedDate,
          data.mainTripInfo!.destinationStopTime!.arrivalTime,
        );

        if (stepData != null &&
            stepData.mainTripInfo!.distanceToDestination! <= 1000 &&
            firstDistanceDepartureToStop >
                stepData.mainTripInfo!.distanceDepartureToStop! &&
            stepData.mainTripInfo!.distanceToDestination! <
                data.mainTripInfo!.distanceToDestination!) {
          // Uncomment if stepData should be added
          // departureTransit.insert(0, stepData);
        }
      }

      int iterationCount = 0;
      maxDistanceTo = 500;
      maxDistanceFrom = 500;

      while (data!.mainTripInfo!.distanceToDestination! > 1000 &&
          iterationCount < 20) {
        maxDistanceTo += 100;
        maxDistanceFrom += 100;
        iterationCount++;

        TransitFullResponseModel? stepDataEnd = await _findTrips(
          data.mainTripInfo!.stopEnd!.stopLat,
          data.mainTripInfo!.stopEnd!.stopLon,
          endLat,
          endLon,
          false,
          maxDistanceFrom,
          maxDistanceTo,
          formattedDate,

          data.mainTripInfo!.destinationStopTime!.arrivalTime,
        );

        print("OKLLLLL");

        if (stepDataEnd != null &&
            _checkForDuplicateStopId(
              departureTransit,
              stepDataEnd.mainTripInfo!,
            ) &&
            stepDataEnd.mainTripInfo!.distanceToDestination! <=
                data.mainTripInfo!.distanceToDestination! / 2 &&
            (stepDataEnd.mainTripInfo!.distanceDepartureToStop! +
                    stepDataEnd.mainTripInfo!.distanceToDestination!) <
                data.mainTripInfo!.distanceToDestination!) {
          if (stepDataEnd.mainTripInfo!.trip!.tripId.trim() ==
                  data.mainTripInfo!.trip!.tripId.trim() ||
              stepDataEnd.mainTripInfo!.stopEnd!.stopId ==
                  data.mainTripInfo!.stopEnd!.stopId) {
            if (departureTransit.isNotEmpty &&
                departureTransit.last.mainTripInfo!.stopEnd !=
                    stepDataEnd.mainTripInfo!.stopEnd) {
              departureTransit[departureTransit.length - 1] = stepDataEnd;
            } else if (departureTransit.isEmpty ||
                departureTransit.last.mainTripInfo!.stopEnd ==
                    stepDataEnd.mainTripInfo!.stopEnd) {
              departureTransit.add(stepDataEnd);
            }
            data = stepDataEnd;
          } else {
            if (stepDataEnd.mainTripInfo!.distanceDepartureToStop! < 2000) {
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
    List<TransitFullResponseModel> data,
    TransitResponseModel tr,
  ) {
    return !data.any(
      (item) => item.mainTripInfo!.stopEnd!.stopId == tr.stopEnd!.stopId,
    );
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
          apiKey: "",
          useGoogleSearch: false,
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
        apiKey: "",
        useGoogleSearch: false,
      );
    }
  }

  Future<List<CampaignWinnerDTOModel>> _getCampaignTop() async {
    try {
      final response = await repository.getData("/campaign/top");

      if (response.data != null &&
          response.data is List &&
          response.data.isNotEmpty) {
        return CampaignWinnerDTOModel.fromJsonList(response.data);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
