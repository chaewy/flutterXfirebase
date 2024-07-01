import 'package:flutter/material.dart';
import 'package:flutter_application_1/loading,dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/pages/events/eventDetails_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure this import for EventModel
import 'package:firebase_auth/firebase_auth.dart'; // Ensure this import for FirebaseAuth

class UpcomingEvent extends StatefulWidget {
  @override
  _UpcomingEventState createState() => _UpcomingEventState();
}

class _UpcomingEventState extends State<UpcomingEvent> {
  List<EventModel> savedEvents = []; // State variable to hold saved events
  List<EventModel> joinedEvents = []; // State variable to hold joined events
  PostService _postService = PostService();
  bool isLoading = false;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    fetchEvents(); // Fetch saved and joined events when widget initializes
  }

  Future<void> fetchEvents() async {
    try {
      setState(() {
        isLoading = true;
        errorText = '';
      });

      await fetchSavedEvents();
      await fetchJoinEvent();
    } catch (error) {
      print('Error fetching events: $error');
      setState(() {
        errorText = 'Error fetching events. Please try again later.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSavedEvents() async {
    try {
      List<EventModel> fetchedSavedEvents = await _postService.fetchSavedEvents();
      setState(() {
        savedEvents = fetchedSavedEvents; // Update state with fetched saved events
      });
    } catch (error) {
      print('Error fetching saved events: $error');
      // Handle error fetching saved events
    }
  }

  Future<void> fetchJoinEvent() async {
    try {
      List<EventModel> fetchedJoinedEvents = await _postService.fetchJoinEvent();
      setState(() {
        joinedEvents = fetchedJoinedEvents; // Update state with fetched joined events
      });
    } catch (error) {
      print('Error fetching joined events: $error');
      setState(() {
        errorText = 'Error fetching joined events. Please try again later.'; // Update error text
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CustomLoadingIndicator())
          : errorText.isNotEmpty
              ? Center(child: Text(errorText))
              : Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Joined Events',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      // Display joined events dynamically
                      joinedEvents.isEmpty
                          ? Center(child: Text('No joined events found.'))
                          : Expanded(
                              child: ListView.builder(
                                itemCount: joinedEvents.length,
                                itemBuilder: (context, index) {
                                  return EventCard(event: joinedEvents[index], isJoinedEvent: true, postService: _postService);
                                },
                              ),
                            ),
                      SizedBox(height: 16),
                      const Text(
                        'Saved Events',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      // Display saved events dynamically
                      savedEvents.isEmpty
                          ? Center(child: Text('No saved events found.'))
                          : Expanded(
                              child: ListView.builder(
                                itemCount: savedEvents.length,
                                itemBuilder: (context, index) {
                                  return EventCard(event: savedEvents[index], isJoinedEvent: false, postService: _postService);
                                },
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;
  final bool isJoinedEvent;
  final PostService postService;

  EventCard({required this.event, required this.isJoinedEvent, required this.postService});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(Icons.event),
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Region: ${event.region}'),
            Text('State: ${event.state}'),
          ],
        ),
        trailing: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 255, 255, 255)),
             foregroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 252, 0, 0)), // Set text color to white
          ),
          onPressed: () async {
            if (isJoinedEvent) {
              // Leave Event
              await postService.leaveEvent(event, FirebaseAuth.instance.currentUser!.uid);
            } else {
              // Unsave Event
              await postService.unsaveEvent(event.id);
            }
            // Refresh the UI after leaving or unsaving
            // Assuming fetchEvents is a method in _UpcomingEventState
            _UpcomingEventState? state = context.findAncestorStateOfType<_UpcomingEventState>();
            if (state != null) {
              state.fetchEvents();
            }
          },
          child: Text(isJoinedEvent ? 'Leave' : 'Unsave'),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetails(event: event),
            ),
          );
        },
      ),
    );
  }
}
