import 'package:flutter/material.dart';
import 'package:flutter_application_1/loading,dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/pages/events/eventDetails_page.dart';
import 'package:flutter_application_1/pages/events/list_event_category.dart';
import 'package:flutter_application_1/services/add_post.dart'; // Replace with your actual service

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late Stream<List<EventModel>> _eventsStream;
  late List<EventModel> _events;

  // Categories list
  List<String> categories = [
    'anime & cosplay',
    'collectibles',
    'fashion & beauty',
    'art',
    'business & finance',
    'education & career',
    'food & drinks',
    'games',
    'law',
    'home & garden',
    'nature & outdoors',
    'music',
    'movies & tv',
    'news & politics',
    'places & travel',
    'reading and writing',
    'sports',
    'vehicles',
    'technology',
  ];

  @override
  void initState() {
    super.initState();
    _eventsStream = PostService().fetchAndSortEventsByParticipantCount();
    _events = []; // Initialize empty list
    _eventsStream.listen((events) {
      setState(() {
        _events = events;
      });
    }, onError: (error) {
      // Handle error
      print("Error fetching events: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
  padding: EdgeInsets.only(left: 15.0),
  child: Column( // Wrap the Text and SizedBox in a Column
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Explore Event by Category',
        style: TextStyle(
          color : Theme.of(context).colorScheme.onSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      SizedBox(height: 10), // SizedBox is now a child of Padding, not Text
    ],
  ),
),

          // First row with first 10 categories buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.take(10).map((category) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      navigateToEventListPage(category);
                    },
                    child: Text(category),
                  ),
                );
              }).toList(),
            ),
          ),
          // Second row with next 9 categories buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.skip(10).map((category) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      navigateToEventListPage(category);
                    },
                    child: Text(category),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 10,),
            Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: Text(
    'Popular Event',
    style: TextStyle(
      color : Theme.of(context).colorScheme.onSecondary,
      fontWeight: FontWeight.bold, // Make the text bold
      fontSize: 17, // Optional: Adjust font size if needed
    ),
  ),
          ),
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),
    );
  }

  // Function to navigate to EventListPage with selected category
  void navigateToEventListPage(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventListPage(category: category),
      ),
    );
  }

  Widget _buildEventList() {
    if (_events.isEmpty) {
      return Center(
              child: CustomLoadingIndicator(), // Show custom loading indicator
            );
      
    } else {
      return ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to EventDetailsPage with the corresponding EventModel
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetails(event: _events[index]),
                ),
              );
            },
            child: Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 14),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 9.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              _events[index].title,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(height: 6),
                            Text('Participants: ${_events[index].participantCount}'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Image Gallery
                    Container(
                      height: 100, // Adjust the height as needed
                      width: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _events[index].imageUrl.length,
                        itemBuilder: (context, imageIndex) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Image.network(
                              _events[index].imageUrl[imageIndex],
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
