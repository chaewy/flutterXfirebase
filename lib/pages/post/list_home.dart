import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/comment_page.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';

class ListPost extends StatelessWidget {
  final UserService _userService = UserService();
  final PostService _postService = PostService();

  // Display images using a Wrap widget
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
          height: MediaQuery.of(context).size.height * 0.3, // Adjust the height as needed
        ),
      ),
    );
  } else {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}


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
                                final likeCount = likeCountSnapshot.data ?? 0; // Total number of likes

                                return Padding(
                                  padding: EdgeInsets.fromLTRB(10.0, 8.0, 16.0, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        //-------------------
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
                                                  radius: 20, // Adjust the radius of the profile image
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
                                      // Display title with GestureDetector for navigation
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
                                      // Display images
                                      _buildImages(context, post.imageUrls),

                                      SizedBox(height: 8.0),
                                      // Display description
                                      Text(
                                        post.timestamp.toDate().toString(),
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12.0,
                                        ),
                                      ),
                                      SizedBox(height: 8.0),
                                      Row(
                                        children: [
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
                                          SizedBox(width: 50),
                                          IconButton(
                                            icon: Icon(
                                              Icons.chat_bubble,
                                              color: Colors.green, // Customize the color of the comment icon
                                              size: 30.0,
                                            ),
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
