import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/pages/events/eventDetails_page.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/pages/events/list_event.dart';

class EventPage extends StatefulWidget {
  EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late Future<List<EventModel>> _futureEvents;
  PostService _postService = PostService();

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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildEventPopular(context, 'Popular Events'),
            _buildEventCategory(context, 'Cooking'),
            _buildEventCategory(context, 'War'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCategory(BuildContext context, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.0),
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListEvent(category: category),
        ),
      ],
    );
  }

 Widget _buildEventPopular(BuildContext context, String category) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        category,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12.0),
      Container(
        height: MediaQuery.of(context).size.height * 0.4, // Reduced height
        child: FutureBuilder<List<EventModel>>(
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            event.title,
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Reduced font size
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: Icon(Icons.more_vert, color: Colors.grey),
                                          onSelected: (String value) async {
                                            if (value == 'save') {
                                              bool alreadySaved = await _postService.saveEvent(event);

                                              if (alreadySaved) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Event is already saved.')),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Event saved successfully.')),
                                                );
                                              }
                                            } else if (value == 'unsave') {
                                              bool unsaveSuccess = await _postService.unsaveEvent(event.id);

                                              if (unsaveSuccess) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Event unsaved.')),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Event was not saved.')),
                                                );
                                              }
                                            }
                                          },
                                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                            const PopupMenuItem<String>(
                                              value: 'save',
                                              child: ListTile(
                                                title: Text('Save Event'),
                                              ),
                                            ),
                                            const PopupMenuItem<String>(
                                              value: 'unsave',
                                              child: ListTile(
                                                title: Text('Unsave Event'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 14), // Reduced icon size
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            "${event.region}, ${event.state}",
                                            style: TextStyle(color: Colors.grey, fontSize: 12), // Reduced font size
                                            // overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
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
      ),
    ],
  );
}

Widget _buildImageList(BuildContext context, List<String> imageUrl) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullImagePage(imageUrl: imageUrl[0]),
        ),
      );
    },
    child: Center(
      child: Image.network(
        imageUrl[0],
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height * 0.2, // Adjusted height
        width: double.infinity, // Full width to avoid empty space
      ),
    ),
  );
}
}
