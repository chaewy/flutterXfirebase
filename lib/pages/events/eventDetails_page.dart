import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/user.dart';

class EventDetails extends StatelessWidget {
  final EventModel event;
  final UserService _userService = UserService();

  EventDetails({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<UserModel>(
          future: _userService.getUserInfo(event.creator).first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('User not found'));
            } else {
              final user = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Posted by ',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(user: user),
                              ),
                            );
                          },
                          child: Text(
                            user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      event.title,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Location: ${event.state}, ${event.city}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    if (event.imageUrl.isNotEmpty)
                      Image.network(
                        event.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    SizedBox(height: 8),
                    Text(
                      '${event.description}',
                      style: TextStyle(fontSize: 16),
                    ),
                    // Add more details as needed
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
