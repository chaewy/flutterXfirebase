import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/events/list_event.dart';
import 'package:flutter_application_1/pages/events/list_popular_event.dart';

class EventPage extends StatefulWidget {
  EventPage({Key? key}) : super(key: key);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildEventPopular(context, 'Popular Events'),
            //  SizedBox(height: 10.0),
            _buildEventCategory(context, 'Cooking'),
            // SizedBox(height: 16.0),
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
          height: MediaQuery.of(context).size.height * 0.5,
          child: PopularEventPage(),
        ),
      ],
    );
  }
}
