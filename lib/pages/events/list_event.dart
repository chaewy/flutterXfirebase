import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';

class ListEvent extends StatelessWidget {
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: _postService.getEventPosts(), // Fetch event posts
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error retrieving event posts: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No event posts found.'));
        } else {
          List<PostModel> eventPosts = snapshot.data!;
          // Display event posts in a list or grid view
          return ListView.builder(
            itemCount: eventPosts.length,
            itemBuilder: (context, index) {
              final eventPost = eventPosts[index];
              return StreamBuilder<UserModel>(
                stream: _userService.getUserInfo(eventPost.creator), // Fetch post creator info
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error loading user info'),
                      subtitle: Text(eventPost.text),
                    );
                  } else if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('User not found'),
                      subtitle: Text(eventPost.text),
                    );
                  } else {
                    final user = userSnapshot.data!;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.profileImageUrl),
                      ),
                      title: Text(user.name),
                      subtitle: Text(eventPost.text),
                      // Add more UI components to display other information about the event post
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
