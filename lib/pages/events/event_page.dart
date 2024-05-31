import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/events/list_event.dart';

class EventPage extends StatefulWidget {
  EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event'), // Change the title accordingly
        // Add any other app bar customization here
      ),
      body: ListEvent(), // Display the list of event posts
    );
  }
}
