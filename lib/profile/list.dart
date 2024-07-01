import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
import 'package:flutter_application_1/pages/post/comment_page.dart';
import 'package:flutter_application_1/profile/editpost.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class PostListByUser extends StatelessWidget {
  final String uid;
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  PostListByUser({required this.uid});

  Widget _buildImages(BuildContext context, List<String> imageUrls) {
    return Container(
      height: 200, // Adjust the height according to your design
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PostModel>>(
      stream: _postService.getPostByUser(uid),
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

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CommentPage(post: post),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 8.0),
                                    child: Card(
                                      elevation: 2.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                      child: CircleAvatar(
                                                        backgroundImage: NetworkImage(user.profileImageUrl),
                                                        radius: 16,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
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
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                FutureBuilder<String?>(
                                                  future: _authService.getCurrentUserId(),
                                                  builder: (context, currentUserSnapshot) {
                                                    if (!currentUserSnapshot.hasData) {
                                                      return Container(); // If no user is logged in, return an empty container
                                                    }

                                                    final currentUserId = currentUserSnapshot.data!;
                                                    return currentUserId == post.creator
                                                        ? PopupMenuButton<String>(
                                                            onSelected: (value) {
                                                              if (value == 'edit') {
                                                                // Navigate to edit post page
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => EditPostPage(post: post), // Assuming you have an EditPostPage
                                                                  ),
                                                                );
                                                              } else if (value == 'delete') {
                                                                // Delete the post
                                                                _postService.deletePost(post.id);
                                                              }
                                                            },
                                                            itemBuilder: (BuildContext context) {
                                                              return {'Edit', 'Delete'}
                                                                  .map((String choice) {
                                                                return PopupMenuItem<String>(
                                                                  value: choice.toLowerCase(),
                                                                  child: Text(choice),
                                                                );
                                                              }).toList();
                                                            },
                                                          )
                                                        : Container();
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.0),
                                            Text(
                                              post.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            _buildImages(context, post.imageUrls),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(width: 40),
                                                    IconButton(
                                                      icon: Icon(
                                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                                        color: isLiked ? Colors.red : Colors.grey,
                                                      ),
                                                      onPressed: () {
                                                        // Add like/unlike functionality
                                                      },
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text('$likeCount likes'),
                                                    SizedBox(width: 70),
                                                    IconButton(
                                                      icon: Icon(Icons.comment),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => CommentPage(post: post),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
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
