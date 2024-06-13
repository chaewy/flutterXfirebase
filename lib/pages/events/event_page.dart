import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/events/list_event.dart';

class EventPage extends StatefulWidget {
  EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  String? _selectedCategory; // Variable to store the selected category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListEvent(), // Display the list of event posts
          Positioned(
            top: 8.0,
            right: 8.0,
            child: PopupMenuButton<String>(
              onSelected: (String value) {
                setState(() {
                  _selectedCategory = value; // Update the selected category
                });
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'hobbies',
                  child: Text('Hobbies'),
                ),
                const PopupMenuItem<String>(
                  value: 'cooking',
                  child: Text('Cooking'),
                ),
                const PopupMenuItem<String>(
                  value: 'reading',
                  child: Text('Reading'),
                ),
                // Add more categories as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}
