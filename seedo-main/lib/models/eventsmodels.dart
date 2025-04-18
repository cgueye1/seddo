class EventModel {
  final String title;
  final String date;
  final String month;
  final String startTime;
  final String endTime;
  final String category;
  final int participants;
  final int maxParticipants;
  final String image;
   bool isFavorite;

  EventModel({
    required this.title,
    required this.date,
    required this.month,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.participants,
    required this.maxParticipants,
    required this.image,
    required this.isFavorite,
  });

  factory EventModel.fromJson(Map<String, dynamic> map) {
    return EventModel(
      title: map['title'],
      date: map['date'],
      month: map['month'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      category: map['category'],
      participants: map['participants'],
      maxParticipants: map['maxParticipants'],
      image: map['image'],
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'month': month,
      'startTime': startTime,
      'endTime': endTime,
      'category': category,
      'participants': participants,
      'maxParticipants': maxParticipants,
      'image': image,
      'isFavorite': isFavorite,
    };
  }

  static List<EventModel> fromJsonList(List<dynamic> list) {
    return list.map((item) => EventModel.fromJson(item)).toList();
  }
}