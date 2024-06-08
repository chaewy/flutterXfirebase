import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/events/eventDetails_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';

class ListEvent extends StatelessWidget {
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EventModel>>(
      stream: _postService.getEventPosts(), // Fetch event posts
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error retrieving event posts: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No event posts found.'));
        } else {
          List<EventModel> eventPosts = snapshot.data!;
          return ListView.builder(
            itemCount: eventPosts.length,
            itemBuilder: (context, index) {
              final eventPost = eventPosts[index];
              return StreamBuilder<UserModel>(
                stream: _userService.getUserInfo(eventPost.creator), // Fetch post creator info
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox.shrink(); // Hide placeholder while loading user info
                  } else if (userSnapshot.hasError) {
                    return SizedBox.shrink(); // Hide placeholder if there's an error
                  } else if (!userSnapshot.hasData) {
                    return SizedBox.shrink(); // Hide placeholder if user not found
                  } else {
                    final user = userSnapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        height: 280, // Adjust the height as needed
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetails(event: eventPost),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          radius: 20, // Adjust the radius of the profile image
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded( // Wrap with Expanded
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        eventPost.title,
                                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.location_on, size: 16),
                                                          SizedBox(width: 4),
                                                          Expanded( // Wrap with Expanded
                                                            child: Text(
                                                              "${eventPost.streetName}, ${eventPost.town}, ${eventPost.region}, ${eventPost.state}",
                                                              style: TextStyle(color: Colors.grey),
                                                              overflow: TextOverflow.ellipsis,
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


                                          ],
                                        ),
                                      ),
                                    ],

                                  ),
                                ),
                                if (eventPost.imageUrl.isNotEmpty)
                                  Expanded(
                                    child: Image.network(
                                      eventPost.imageUrl,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                
                              ],
                            ),
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
