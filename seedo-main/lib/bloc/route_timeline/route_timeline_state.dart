part of 'route_timeline_bloc.dart';

enum RouteTimelineStatus { initial, loading, success, failure }

class RouteTimelineState extends Equatable {
  final RouteTimelineStatus status;
  final List<TransitFullResponseModel> departureTransit;

  //final Filter? selectedFilter;
  final double startLat;
  final double startLon;
  final double endLat;
  final double endLon;
  final int maxDistanceFrom;
  final int maxDistanceTo;
  final String? errorMessage;
  final bool departureLoader;
  final Position? currentPosition;
  final bool adShown;
  final AppParamModel? appParam;
  final int itineraireIndex;
  final PlaceModel? fromPlaceDetails;
  final PlaceModel? toPlaceDetails;
  final itineraireSize;

  final String date;
  final String time;

  final List<CampaignWinnerDTOModel> campaignToWinners;

  const RouteTimelineState({
    this.status = RouteTimelineStatus.initial,
    this.departureTransit = const [],
    // this.selectedFilter,
    this.startLat = 0,
    this.startLon = 0,
    this.endLat = 0,
    this.endLon = 0,
    this.maxDistanceFrom = 500,
    this.maxDistanceTo = 500,
    this.departureLoader = false,
    this.errorMessage,
    this.currentPosition,
    this.adShown = false,
    this.appParam,
    this.itineraireIndex = 0,
    this.itineraireSize = 0,
    this.fromPlaceDetails,
    this.toPlaceDetails,
    this.date = "",
    this.time = "",
    this.campaignToWinners = const [],
  });

  RouteTimelineState copyWith({
    RouteTimelineStatus? status,
    List<TransitFullResponseModel>? departureTransit,
    //  Filter? selectedFilter,
    double? startLat,
    double? startLon,
    bool? departureLoader,
    double? endLat,
    double? endLon,
    int? maxDistanceFrom,
    int? maxDistanceTo,
    String? errorMessage,
    Position? currentPosition,
    bool? adShown,
    AppParamModel? appParam,
    int? itineraireIndex,
    int? itineraireSize,
    PlaceModel? fromPlaceDetails,
    PlaceModel? toPlaceDetails,
    String? date,
    String? time,
    List<CampaignWinnerDTOModel>? campaignToWinners,
  }) {
    return RouteTimelineState(
      status: status ?? this.status,
      departureTransit: departureTransit ?? this.departureTransit,
      //selectedFilter: selectedFilter ?? this.selectedFilter,
      startLat: startLat ?? this.startLat,
      startLon: startLon ?? this.startLon,
      endLat: endLat ?? this.endLat,
      endLon: endLon ?? this.endLon,
      maxDistanceFrom: maxDistanceFrom ?? this.maxDistanceFrom,
      maxDistanceTo: maxDistanceTo ?? this.maxDistanceTo,
      errorMessage: errorMessage ?? this.errorMessage,
      departureLoader: departureLoader ?? this.departureLoader,
      currentPosition: currentPosition ?? this.currentPosition,
      adShown: adShown ?? this.adShown,
      appParam: appParam ?? this.appParam,
      itineraireIndex: itineraireIndex ?? this.itineraireIndex,
      itineraireSize: itineraireSize ?? this.itineraireSize,

      fromPlaceDetails: fromPlaceDetails ?? this.fromPlaceDetails,
      toPlaceDetails: toPlaceDetails ?? this.toPlaceDetails,
      date: date ?? this.date,
      time: time ?? this.time,
      campaignToWinners: campaignToWinners ?? this.campaignToWinners,
    );
  }

  @override
  List<Object?> get props => [
    status,
    departureTransit,
    //  selectedFilter,
    startLat,
    startLon,
    endLat,
    endLon,
    maxDistanceFrom,
    maxDistanceTo,
    errorMessage,
    departureLoader,
    currentPosition,
    adShown,
    appParam,
    itineraireIndex,
    itineraireSize,
    fromPlaceDetails,
    toPlaceDetails,
    date,
    time,
    campaignToWinners,
  ];
}
