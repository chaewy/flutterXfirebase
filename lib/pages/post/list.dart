import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/services/add_post.dart';


// display user post on profile page
class PostListByUser extends StatelessWidget {
  final String uid;

  PostListByUser({required this.uid});

  @override
  Widget build(BuildContext context) {

//------------------------------------------------------------------------------

    return StreamBuilder<List<PostModel>>(
      stream: PostService().getPostByUser(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error retrieving posts: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<PostModel> posts = snapshot.data ?? [];
          print('Number of posts retrieved: ${posts.length}');
          print('Posts: $posts');

//------------------------------------------------------------------------------


          return Container(
            height: 300, // Set a fixed height or adjust as needed
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                print('Post at index $index: $post');
                return ListTile(
                  title: Text(post.creator),
                  subtitle: Text(post.title),
                );
              },
            ),
          );
        }
      },
    );
  }
}