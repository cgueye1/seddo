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



String getTimeAgo(String isoDateString) {
  final date = DateTime.parse(isoDateString).toLocal();
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return "Publié il y a quelques secondes";
  } else if (difference.inMinutes < 60) {
    return "Publié il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}";
  } else if (difference.inHours < 24) {
    return "Publié il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}";
  } else if (difference.inDays < 7) {
    return "Publié il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}";
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return "Publié il y a $weeks semaine${weeks > 1 ? 's' : ''}";
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return "Publié il y a $months mois";
  } else {
    final years = (difference.inDays / 365).floor();
    return "Publié il y a $years an${years > 1 ? 's' : ''}";
  }
}



String formatTimeToHHmm(String? timeStr) {
  try {
    final time = DateFormat('HH:mm:ss').parse(timeStr!);
    return DateFormat('HH:mm').format(time);
  } catch (e) {
    return timeStr!; // ou retournez "??:??" en cas d'erreur
  }
}