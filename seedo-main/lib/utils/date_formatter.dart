import 'package:intl/intl.dart';

String formatDate(int timestamp) {
  try {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMMM yyyy', 'fr_FR').format(date);
  } catch (e) {
    // Fallback si le formatage échoue
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return "${date.day}/${date.month}/${date.year}";
  }
}

// Formatte un timestamp en temps écoulé (il y a X heures, etc.)
String formatTimeAgo(int timestamp) {
  final now = DateTime.now();
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final difference = now.difference(date);

  if (difference.inDays > 365) {
    return 'il y\'a ${(difference.inDays / 365).floor()} an(s)';
  } else if (difference.inDays > 30) {
    return 'il y\'a ${(difference.inDays / 30).floor()} mois';
  } else if (difference.inDays > 0) {
    return 'il y\'a ${difference.inDays} jour(s)';
  } else if (difference.inHours > 0) {
    return 'il y\'a ${difference.inHours} heure(s)';
  } else if (difference.inMinutes > 0) {
    return 'il y\'a ${difference.inMinutes} minute(s)';
  } else {
    return 'à l\'instant';
  }
}
