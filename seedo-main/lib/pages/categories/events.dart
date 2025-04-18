import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_state.dart';

class EventsSection extends StatefulWidget {
  const EventsSection({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EventsSectionState createState() => _EventsSectionState();
}

class _EventsSectionState extends State<EventsSection> {
  List<EventModel> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      // Load the JSON file from assets
      final String response = await rootBundle.loadString(
        'assets/data/events.json',
      );
      final List<dynamic> jsonData = json.decode(response);

      // Vérifier si le widget est toujours monté avant d'appeler setState
      if (mounted) {
        setState(() {
          events = EventModel.fromJsonList(jsonData);
          isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error loading events: $e');
      // Vérifier si le widget est toujours monté avant d'appeler setState
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to access HomeBloc and listen to state changes
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'Événements à venir',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            // Show loading indicator or events
            isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                  height: 300, // Fixed height for the container
                  child:
                      events.isEmpty
                          ? Center(child: Text('Aucun événement disponible'))
                          : ListView.builder(
                            scrollDirection:
                                Axis.horizontal, // Scroll horizontally
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return EventCardRedesigned(
                                event: events[index],
                                onFavoriteToggle: () {
                                  setState(() {
                                    events[index].isFavorite =
                                        !events[index].isFavorite;
                                  });
                                },
                              );
                            },
                          ),
                ),
          ],
        );
      },
    );
  }
}

class EventCardRedesigned extends StatelessWidget {
  final EventModel event;
  final VoidCallback onFavoriteToggle;

  const EventCardRedesigned({
    super.key,
    required this.event,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      height: 550,
      margin: const EdgeInsets.only(left: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec padding
          Padding(
            padding: const EdgeInsets.all(10), // Padding autour de l'image
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    event.image,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                // Date
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    width: 72,
                    height: 65,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 60, 69, 87),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          event.date,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          event.month,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Catégorie
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 130,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 251, 189, 5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_bar,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            event.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Détails de l'événement
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${event.startTime} - ${event.endTime}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 14,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.participants}/${event.maxParticipants}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          'inscrits',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                        SizedBox(width: 115),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              'Participer',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: Color.fromARGB(255, 0, 0, 0),
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Here's the EventModel class if needed
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
    this.isFavorite = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      title: json['title'],
      date: json['date'],
      month: json['month'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      category: json['category'],
      participants: json['participants'],
      maxParticipants: json['maxParticipants'],
      image: json['image'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  static List<EventModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => EventModel.fromJson(json)).toList();
  }
}
