import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/comment_page.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';

class PostListByUser extends StatelessWidget {
  final String uid;

  PostService _postService = PostService();
  UserService _userService = UserService();

 Widget _buildImages(BuildContext context, List<String> imageUrls) {
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
        ),
      ),
    );
  } else {
    return Container(
      height: 200, // Set a fixed height for the image container
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
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
            child: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Image.network(
                imageUrls[index],
                height: 200, // Set the height of each image
                width: 200, // Set the width of each image
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}

  PostListByUser({required this.uid});

  @override
  Widget build(BuildContext context) {
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

          return ListView.builder(
            shrinkWrap: true,
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              print('Post at index $index: $post');

              return StreamBuilder<UserModel>(
                stream: _userService.getUserInfo(post.creator),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (userSnapshot.hasError) {
                    return ListTile(
                      title: Text('Error loading user info'),
                      subtitle: Text(post.title),
                    );
                  } else if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('User not found'),
                      subtitle: Text(post.title),
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
                            subtitle: Text(post.title),
                          );
                        } else if (!likeSnapshot.hasData) {
                          return ListTile(
                            title: Text('Like status not found'),
                            subtitle: Text(post.title),
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
                                  subtitle: Text(post.title),
                                );
                              } else {
                                final likeCount = likeCountSnapshot.data ?? 0;

                                return Padding(
                                  padding: EdgeInsets.fromLTRB(10.0, 8.0, 16.0, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
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
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundImage: NetworkImage(user.profileImageUrl),
                                                  radius: 20,
                                                ),
                                                SizedBox(width: 10),
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
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CommentPage(post: post),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          post.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      _buildImages(context, post.imageUrls),
                                    ],
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
