import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/pages/events/eventDetails_page.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';

class PopularEventPage extends StatefulWidget {
  @override
  _PopularEventPageState createState() => _PopularEventPageState();
}

class _PopularEventPageState extends State<PopularEventPage> {
  late Future<List<EventModel>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _futureEvents = fetchAndSortEventsByParticipantCount();
  }

  Future<List<EventModel>> fetchAndSortEventsByParticipantCount() async {
    try {
      final eventsSnapshot =
          await FirebaseFirestore.instance.collection('event').get();

      final events = eventsSnapshot.docs
          .map((doc) => EventModel.fromDocument(doc))
          .toList();

      // Fetch participant counts for each event
      await Future.forEach(events, (event) async {
        final participantsSnapshot = await FirebaseFirestore.instance
            .collection('event')
            .doc(event.id)
            .collection('participants')
            .get();
        event.participantCount = participantsSnapshot.size; // Update participant count for each event
      });

      // Sort events by participant count in descending order
      events.sort((a, b) => b.participantCount.compareTo(a.participantCount));

      return events;
    } catch (error) {
      print("Error fetching, counting participants, and sorting events: $error");
      return [];
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: FutureBuilder<List<EventModel>>(
      future: _futureEvents,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error fetching popular events: ${snapshot.error}');
          return Center(child: Text('An error occurred. Please try again later.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No popular events found.'));
        } else {
          List<EventModel> popularEvents = snapshot.data!;

          return ListView(
            scrollDirection: Axis.horizontal,
            children: popularEvents.map((event) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetails(event: event),
                      ),
                    );
                  },
                  child: SizedBox(
                    height: 270,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Card(
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageList(context, event.imageUrl),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "${event.region}, ${event.state}",
                                        style: TextStyle(color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  event.description,
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    ),
  );
}

Widget _buildImageList(BuildContext context, List<String> imageUrl) {
  if (imageUrl.length == 1) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullImagePage(imageUrl: imageUrl.first),
          ),
        );
      },
      child: Center(
        child: Image.network(
          imageUrl.first,
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height * 0.2,
        ),
      ),
    );
  } else {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrl.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullImagePage(imageUrl: imageUrl[index]),
                ),
              );
            },
            child: Image.network(
              imageUrl[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
}