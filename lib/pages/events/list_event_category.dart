import 'package:flutter/material.dart';
import 'package:flutter_application_1/loading,dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/pages/events/eventDetails_page.dart';
import 'package:flutter_application_1/services/add_post.dart';

class EventListPage extends StatefulWidget {
  final String category;

  EventListPage({required this.category});

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late Stream<List<EventModel>> _eventsStream;
  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    _eventsStream = _postService.getEventsSortedByParticipants(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text('Events in ${widget.category}'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20.0), // Set the preferred size for the bottom widget
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(right: 200.0),
            child: Text(
              'By Most Popular',
              style: TextStyle(
                fontSize: 16,
                color: const Color.fromARGB(255, 178, 9, 9),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CustomLoadingIndicator(), // Show custom loading indicator
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found.'));
          }
          // Display the list of events
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              EventModel event = snapshot.data![index];
              String firstImageUrl = event.imageUrl.isNotEmpty ? event.imageUrl[0] : ''; // Get the first imageUrl or empty string if none

              return GestureDetector(
                onTap: () {
                  // Navigate to EventDetailsPage and pass the event object
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetails(event: event),
                    ),
                  );
                },
                child: Container(
                  height: 110, // Adjust the height of each ListTile
                  padding: EdgeInsets.all(5.0),
                  child: Card(
                    elevation: 2.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Expanded(
                          child: ListTile(
                            title: Text(
                              event.title,
                              style: TextStyle(fontWeight: FontWeight.bold), // Make the title bold
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(event.description),
                            ),
                          ),
                        ),
                        Container(
                          width: 120, 
                          height: 80,// Width of the image container
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: firstImageUrl.isNotEmpty
                                ? Image.network(
                                    firstImageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Container(color: Colors.grey), // Placeholder if no imageUrl
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

