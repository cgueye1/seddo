import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  Future<void> openWhatsApp(String phoneNumber, {String message = ''}) async {
    final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossible d\'ouvrir WhatsApp pour le numéro $phoneNumber';
    }
  }
}
