// ignore_for_file: file_names

class AppParamModel {
  final int id;
  bool hideAds;
  bool hideTransit;
  String appVersion;
  String androidLink;
  String iosLink;
  String apiKey;
  bool useGoogleSearch;

  AppParamModel({
    required this.id,
    required this.hideAds,
    required this.hideTransit,
    required this.appVersion,
    required this.androidLink,
    required this.iosLink,
    required this.apiKey,
    required this.useGoogleSearch,
  });

  factory AppParamModel.fromJson(Map<String, dynamic> map) {
    return AppParamModel(
      id: map['id'],
      hideAds: map['hideAds'] ?? false,
      hideTransit: map['hideTransit'] ?? false,
      appVersion: map['appVersion'] ?? '',
      androidLink: map['androidLink'] ?? '',
      iosLink: map['iosLink'] ?? '',
      useGoogleSearch: map['useGoogleSearch'] ?? false,
      apiKey: map['apiKey'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hideAds': hideAds,
      'hideTransit': hideTransit,
      'appVersion': appVersion,
      'androidLink': androidLink,
      'iosLink': iosLink,
      'apiKey': apiKey,
      'useGoogleSearch': useGoogleSearch,
    };
  }
}
