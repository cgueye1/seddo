// ignore_for_file: file_names

class AppParamModel {
  final int id;
  bool hideAds;
  bool hideTransit;
  String appVersion;
  String androidLink;
  String iosLink;

  AppParamModel({
    required this.id,
    required this.hideAds,
    required this.hideTransit,
    required this.appVersion,
    required this.androidLink,
    required this.iosLink,
  });

  factory AppParamModel.fromJson(Map<String, dynamic> map) {
    return AppParamModel(
      id: map['id'],
      hideAds: map['hideAds'] ?? false,
      hideTransit: map['hideTransit'] ?? false,
      appVersion: map['appVersion'] ?? '',
      androidLink: map['androidLink'] ?? '',
      iosLink: map['iosLink'] ?? '',
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
    };
  }
}
