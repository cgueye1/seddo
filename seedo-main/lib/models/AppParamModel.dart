// ignore_for_file: file_names
import 'dart:io';

class AppParamModel {
  final int id;
  bool hideAds;
  bool hideTransit;
  String appVersion;
  String androidLink;
  String iosLink;
  String apiKey;
  bool useGoogleSearch;
  List<String> appVersionList;

  AppParamModel({
    required this.id,
    required this.hideAds,
    required this.hideTransit,
    required this.appVersion,
    required this.androidLink,
    required this.iosLink,
    required this.apiKey,
    required this.useGoogleSearch,
    required this.appVersionList,
  });

  factory AppParamModel.fromJson(Map<String, dynamic> map) {
    final bool platformHideAds = true;
    
    
    /*Platform.isIOS
        ? (map['hideAdsIos'] ?? false)
        : (map['hideAds'] ?? false);*/


    return AppParamModel(
      id: map['id'],
      hideAds: platformHideAds,
      hideTransit: map['hideTransit'] ?? false,
      appVersion: map['appVersion'] ?? '',
      androidLink: map['androidLink'] ?? '',
      iosLink: map['iosLink'] ?? '',
      useGoogleSearch: map['useGoogleSearch'] ?? false,
      apiKey: map['apiKey'] ?? '',
      appVersionList: List<String>.from(map['appVersionList'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hideAds': Platform.isIOS ? null : hideAds,
      'hideAdsIos': Platform.isIOS ? hideAds : null,
      'hideTransit': hideTransit,
      'appVersion': appVersion,
      'androidLink': androidLink,
      'iosLink': iosLink,
      'apiKey': apiKey,
      'useGoogleSearch': useGoogleSearch,
      'appVersionList': appVersionList,
    }..removeWhere((key, value) => value == null); // Nettoie les null
  }
}
