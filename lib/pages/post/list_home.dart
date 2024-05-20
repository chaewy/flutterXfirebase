import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/services/add_post.dart';

// for list all post at home page


class ListPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      // Get the feed stream from PostService
      stream: PostService().getFeed(),
      builder: (context, snapshot) {
        // While the connection is still loading, show a progress indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        // If there's an error in the stream, display an error message
        else if (snapshot.hasError) {
          print('Error retrieving posts: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        // If the stream is empty or no data is found, display a message
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('No posts found.');
          return Center(child: Text('No posts found.'));
        }
        // If data is available, display the list of posts
        else {
          List<PostModel> posts = snapshot.data!;
          print('Number of posts retrieved: ${posts.length}');
          print('Posts: $posts');

          // Display the posts using a ListView
          return Container(
            height: 300, // Set a fixed height or adjust as needed
            child: ListView.builder(
              itemCount: posts.length, // Number of posts
              itemBuilder: (context, index) {
                final post = posts[index]; // Get the post at the current index
                print('Post at index $index: $post');
                // Display each post using a ListTile
                return ListTile(
                  title: Text(post.creator), // Display the creator
                  subtitle: Text(post.text), // Display the post text
                );
              },
            ),
          );
        }
      },
    );
  }
}


