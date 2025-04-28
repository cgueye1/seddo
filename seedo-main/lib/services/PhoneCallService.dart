import 'package:url_launcher/url_launcher.dart';

class PhoneCallService {
  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Impossible de lancer l\'appel vers $phoneNumber';
    }
  }
}
