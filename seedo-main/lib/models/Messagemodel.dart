class Message {
  final String id;
  final String phoneNumber;
  final String content;
  final DateTime timestamp;
  final bool isSent;
  final bool isRead;

  Message({
    required this.id,
    required this.phoneNumber,
    required this.content,
    required this.timestamp,
    required this.isSent,
    this.isRead = false,
  });

  // Factory constructor pour créer un Message à partir de JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      content: json['content'] ?? '',
      timestamp:
          json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      isSent: json['isSent'] ?? false,
      isRead: json['isRead'] ?? false,
    );
  }

  // Convertir un Message en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isSent': isSent,
      'isRead': isRead,
    };
  }

  // Créer une copie d'un Message avec des champs modifiés
  Message copyWith({
    String? id,
    String? phoneNumber,
    String? content,
    DateTime? timestamp,
    bool? isSent,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isSent: isSent ?? this.isSent,
      isRead: isRead ?? this.isRead,
    );
  }

  // Formatter la date pour l'affichage
  String getFormattedDate() {
    final jour = _getJourSemaine(timestamp.weekday);
    final mois = _getMoisNom(timestamp.month);

    return '$jour. ${timestamp.day} $mois ${timestamp.year} ${_formatHeure(timestamp.hour, timestamp.minute)}';
  }

  // Méthode privée pour obtenir le jour de la semaine en français
  String _getJourSemaine(int weekday) {
    const jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return jours[weekday - 1];
  }

  // Méthode privée pour obtenir le mois en français
  String _getMoisNom(int month) {
    const mois = [
      'jan',
      'fév',
      'mars',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sept',
      'oct',
      'nov',
      'déc',
    ];
    return mois[month - 1];
  }

  // Méthode privée pour formater l'heure
  String _formatHeure(int heure, int minute) {
    return '${heure.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
