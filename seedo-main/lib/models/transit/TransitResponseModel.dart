
import '../TransitStopModel.dart';
import 'TransitRoute.dart';
import 'TransitStopTimeModel.dart';
import 'TransitTripModel.dart';

class TransitResponseModel {
  final TransitStopTimeModel? stopTime;
  final TransitTripModel? trip;
  final TransitStopModel? stopStart;
  final TransitStopModel? stopEnd;
  final TransitStopModel stop;
  final TransitRoute? route;
  final TransitStopTimeModel? departureStopTime;
  final TransitStopTimeModel? destinationStopTime;
  double? distanceToDestination;
  double? distanceDepartureToStop;

  TransitResponseModel({
    this.stopTime,
    this.trip,
    required this.stopStart,
    required this.stopEnd,
    required this.departureStopTime,
    required this.destinationStopTime,
    this.route,
    this.distanceToDestination,
    this.distanceDepartureToStop,
    required this.stop,
  });

  factory TransitResponseModel.fromJson(Map<String, dynamic> json) {
    return TransitResponseModel(
        stopTime: json['stopTime'] != null
            ? TransitStopTimeModel.fromJson(json['stopTime'])
            : null,
        trip: json['trip'] != null
            ? TransitTripModel.fromJson(json['trip'])
            : null,
        route:
            json['route'] != null ? TransitRoute.fromJson(json['route']) : null,
        departureStopTime: json['departureStopTime'] != null
            ? TransitStopTimeModel.fromJson(json['departureStopTime'])
            : null,
        destinationStopTime: json['destinationStopTime'] != null
            ? TransitStopTimeModel.fromJson(json['destinationStopTime'])
            : null,
        stopStart: json['stopStart'] != null
            ? TransitStopModel.fromJson(json['stopStart'])
            : null,
        stopEnd: json['stopEnd'] != null
            ? TransitStopModel.fromJson(json['stopEnd'])
            : null,
        distanceToDestination: json['distanceToDestination']?.toDouble(),
        distanceDepartureToStop: json['distanceDepartureToStop']?.toDouble(),
        stop: TransitStopModel.fromJson(json['stopEnd']));
  }

  Map<String, dynamic> toJson() {
    return {
      'stopTime': stopTime?.toJson(),
      'trip': trip?.toJson(),
      'stopStart': stopStart?.toJson(),
      'stopEnd': stopEnd?.toJson(),
      'route': route?.toJson(),
      'departureStopTime': departureStopTime?.toJson(),
      'destinationStopTime': destinationStopTime?.toJson(),
      'distanceToDestination': distanceToDestination,
      'distanceDepartureToStop': distanceDepartureToStop
    };
  }

  static List<TransitResponseModel> fromJsonList(List<dynamic> list) {
    return list.map((item) => TransitResponseModel.fromJson(item)).toList();
  }
}
