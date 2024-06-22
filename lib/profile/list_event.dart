import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';

import '../pages/events/eventDetails_page.dart';

class EventListByUser extends StatelessWidget {
  final String uid;

  EventListByUser({required this.uid});

  final PostService _postService = PostService();
  final UserService _userService = UserService();


  Widget _buildImages(BuildContext context, List<String> imageUrl) {
  return Container(
    height: 200, // Adjust the height of the image container as needed
    child: ListView.builder(
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
          child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl[index],
                width: MediaQuery.of(context).size.width, // Adjust width to fill the card
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EventModel>>(
      stream: _postService.fetchEventsByCreator(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<EventModel> events = snapshot.data ?? [];
          print('Number of events retrieved: ${events.length}');
          print('Events: $events');

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return StreamBuilder<UserModel>(
                stream: _userService.getUserInfo(event.creator),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError || !userSnapshot.hasData) {
                    return ListTile(
                      title: Text('Error loading user info'),
                      subtitle: Text(event.title),
                    );
                  } else {
                    final user = userSnapshot.data!;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetails(event: event),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Card(
                          elevation: 2.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfilePage(user: user),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(user.profileImageUrl),
                                        radius: 16,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  event.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.0),
                              _buildImages(context, event.imageUrl),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }
}


