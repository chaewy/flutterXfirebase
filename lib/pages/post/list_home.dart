import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/comment_page.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';

class ListPost extends StatefulWidget {
  @override
  _ListPostState createState() => _ListPostState();
}

class _ListPostState extends State<ListPost> {
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
              return PostItem(
                post: posts[index],
                userService: _userService,
                postService: _postService,
              );
            },
          );
        }
      },
    );
  }
}

class PostItem extends StatefulWidget {
  final PostModel post;
  final UserService userService;
  final PostService postService;

  PostItem({
    required this.post,
    required this.userService,
    required this.postService,
  });

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late ValueNotifier<bool> isLikedNotifier;
  late ValueNotifier<int> likeCountNotifier;

  @override
  void initState() {
    super.initState();
    isLikedNotifier = ValueNotifier<bool>(false);
    likeCountNotifier = ValueNotifier<int>(0);

    _initializeLikeStatus();
  }

  Future<void> _initializeLikeStatus() async {
    try {
      final currentUserLike = await widget.postService.getCurrentUserLike(widget.post).first;
      final currentLikeCount = await widget.postService.getLikeCount(widget.post).first;
      isLikedNotifier.value = currentUserLike;
      likeCountNotifier.value = currentLikeCount;
    } catch (e) {
      print("Error initializing like status: $e");
    }
  }

  @override
  void dispose() {
    isLikedNotifier.dispose();
    likeCountNotifier.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return StreamBuilder<UserModel>(
      stream: widget.userService.getUserInfo(post.creator),
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
                              style: const TextStyle(
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
                    style: const TextStyle(
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
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: isLikedNotifier,
                      builder: (context, isLiked, child) {
                        return IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.blue,
                            size: 30.0,
                          ),
                          onPressed: () async {
                            // Update the like status in Firestore
                            await widget.postService.likePost(post, isLiked);

                            // Update the like count in Firestore
                            final updatedLikeCount = isLiked ? likeCountNotifier.value - 1 : likeCountNotifier.value + 1;
                            isLikedNotifier.value = !isLiked;
                            likeCountNotifier.value = updatedLikeCount;
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: likeCountNotifier,
                      builder: (context, likeCount, child) {
                        return Text('$likeCount Likes'); // Display like count
                      },
                    ),
                    SizedBox(width: 50),
                    IconButton(
                      icon: const Icon(
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
}
