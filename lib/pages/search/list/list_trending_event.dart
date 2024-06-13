import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event.dart';


class ListTrendingEvent extends StatelessWidget {
  Future<List<EventModel>> fetchAndSortEventsByParticipantCount() async {
    try {
      final eventsSnapshot = await FirebaseFirestore.instance.collection('event').get();

      final events = eventsSnapshot.docs.map((doc) => EventModel.fromDocument(doc)).toList();

      for (final event in events) {
        final participantsSnapshot = await FirebaseFirestore.instance.collection('event').doc(event.id).collection('participants').get();
        event.participantCount = participantsSnapshot.size; // Update participant count for each event
      }

      events.sort((a, b) => b.participantCount.compareTo(a.participantCount)); // Sort events by participant count in descending order

      return events;
    } catch (error) {
      print("Error fetching, counting participants, and sorting events: $error");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EventModel>>(
      future: fetchAndSortEventsByParticipantCount(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final events = snapshot.data!;

          return Column(
            children: [
              SizedBox(height: 20),
              Text("Trending Event", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(event.description),
                          Text('Participants: ${event.participantCount}'),
                        ],
                      ),
                      trailing: Container(
                        width: 50, // Adjust the width as needed
                        height: 50, // Adjust the height as needed
                        child: Image.network(event.imageUrl.first, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}