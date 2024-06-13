import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/events/eventDetails_page.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';

class ListEvent extends StatelessWidget {
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<List<EventModel>>(
            stream: _postService.getEventPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                print('Error retrieving event posts: ${snapshot.error}');
                return Center(child: Text('An error occurred: ${snapshot.error}. Please try again later.'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No event posts found.'));
              } else {
                List<EventModel> eventPosts = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: eventPosts.length,
                  itemBuilder: (context, index) {
                    final eventPost = eventPosts[index];
                    return StreamBuilder<UserModel>(
                      stream: _userService.getUserInfo(eventPost.creator),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return SizedBox.shrink();
                        } else if (userSnapshot.hasError) {
                          print('Error retrieving user info: ${userSnapshot.error}');
                          return SizedBox.shrink();
                        } else if (!userSnapshot.hasData) {
                          print('User info not found.');
                          return SizedBox.shrink();
                        } else {
                          final user = userSnapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                                              radius: 15,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
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
                                                    Expanded(
                                                      child: Text(
                                                        "${eventPost.region}, ${eventPost.state}",
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
                                    ),
                                    _buildImageList(context, eventPost.imageUrl),
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
          ),
        ),
      ),
    );
  }

  Widget _buildImageList(BuildContext context, List<String> imageUrls) {
    if (imageUrls.length == 1) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullImagePage(imageUrl: imageUrls.first),
            ),
          );
        },
        child: Center(
          child: Image.network(
            imageUrls.first,
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height * 0.3, // Adjust the height as needed
          ),
        ),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height * 0.3, // Adjust the height as needed
        child: PageView.builder(
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullImagePage(imageUrl: imageUrls[index]),
                  ),
                );
              },
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      );
    }
  }


}

void main() {
  runApp(MaterialApp(
    home: ListEvent(),
  ));
}