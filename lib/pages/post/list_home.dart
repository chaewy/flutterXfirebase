import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';

class ListPost extends StatelessWidget {
  final UserService _userService = UserService();
  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: _postService.getFeed(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error retrieving posts: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No posts found.'));
        } else {
          List<PostModel> posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return StreamBuilder<UserModel>(
                stream: _userService.getUserInfo(post.creator),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error loading user info'),
                      subtitle: Text(post.text),
                    );
                  } else if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('User not found'),
                      subtitle: Text(post.text),
                    );
                  } else {
                    final user = userSnapshot.data!;

                    return StreamBuilder<bool>(
                      stream: _postService.getCurrentUserLike(post),
                      builder: (context, likeSnapshot) {
                        if (likeSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (likeSnapshot.hasError) {
                          return ListTile(
                            title: Text('Error loading like status'),
                            subtitle: Text(post.text),
                          );
                        } else if (!likeSnapshot.hasData) {
                          return ListTile(
                            title: Text('Like status not found'),
                            subtitle: Text(post.text),
                          );
                        } else {
                          final isLiked = likeSnapshot.data!;

                          return StreamBuilder<int>(
                            stream: _postService.getLikeCount(post),
                            builder: (context, likeCountSnapshot) {
                              if (likeCountSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              } else if (likeCountSnapshot.hasError) {
                                return ListTile(
                                  title: Text('Error loading like count'),
                                  subtitle: Text(post.text),
                                );
                              } else {
                                final likeCount = likeCountSnapshot.data ?? 0; // Total number of likes

                                return Padding(
                                  padding: EdgeInsets.fromLTRB(3.0, 8.0, 16.0, 0),
                                  child: ListTile(
                                    leading: user.profileImageUrl.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 20,
                                            backgroundImage: NetworkImage(user.profileImageUrl),
                                          )
                                        : Icon(Icons.person, size: 40),
                                    title: Text(
                                      user.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8.0),
                                        Text(post.text),
                                        SizedBox(height: 8.0),
                                        Text(
                                          post.timestamp.toDate().toString(),
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        IconButton(
                                          icon: Icon(
                                            isLiked ? Icons.favorite : Icons.favorite_border,
                                            color: isLiked ? Colors.red : Colors.blue,
                                            size: 30.0,
                                          ),
                                          onPressed: () {
                                            // Update the like status in Firestore
                                            _postService.likePost(post, isLiked);

                                            // Update the like count in Firestore
                                            _postService.updateLikeCount(post); 
                                          },
                                        ),
                                        Text('$likeCount Likes'), // Display like count
                                      ],
                                    ),
                                  ),
                                );


                              }
                            },
                          );

                        }
                      },
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