import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class UrlLauncher {
  Future<void> openMapsNavigation(
      double startLat,
      double startLon,
      double endLat,
      double endLon, {
        String travelMode = "walk",
      }) async {
    final googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLon&destination=$endLat,$endLon&travelmode=$travelMode';

    final appleMapsUrl =
        'https://maps.apple.com/?saddr=$startLat,$startLon&daddr=$endLat,$endLon&dirflg=$travelMode';

    final googleUri = Uri.parse(googleMapsUrl);
    final appleUri = Uri.parse(appleMapsUrl);

    // Check platform to determine which app to open
    if (Platform.isAndroid) {
      // On Android, try Google Maps
      bool googleMapsCanLaunch = await launchUrl(googleUri);
      if (googleMapsCanLaunch) {
        await launchUrl(googleUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Impossible d\'ouvrir Google Maps sur Android.';
      }
    } else if (Platform.isIOS) {
      // On iOS, try Apple Maps
      bool appleMapsCanLaunch = await launchUrl(appleUri);
      if (appleMapsCanLaunch) {
        await launchUrl(appleUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Impossible d\'ouvrir Apple Maps sur iOS.';
      }
    } else {
      throw 'Plateforme non prise en charge. Cette fonctionnalité fonctionne uniquement sur Android ou iOS.';
    }
  }

  Future<void> openWebLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossible d\'ouvrir le lien : $url';
    }
  }
}

