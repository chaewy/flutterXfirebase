import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/post/comment_page.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';
import 'package:share_plus/share_plus.dart';

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
    if (imageUrls.isEmpty) {
      return SizedBox.shrink(); // Return empty SizedBox if no images
    } else if (imageUrls.length == 1) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullImagePage(imageUrl: imageUrls.first),
            ),
          );
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3, // Reduced height for single image
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: DecorationImage(
              image: NetworkImage(imageUrls.first),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height * 0.3, // Reduced height for multiple images
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    image: NetworkImage(imageUrls[index]),
                    fit: BoxFit.cover,
                  ),
                ),
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
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0), // Adjusted padding
              child: Card(
                elevation: 2, // Reduced elevation for a subtler shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Adjusted padding inside card
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
                            fontSize: 16, // Reduced font size for title
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
                          SizedBox(width: 30),
                          ValueListenableBuilder<bool>(
                            valueListenable: isLikedNotifier,
                            builder: (context, isLiked, child) {
                              return IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.blue,
                                  size: 20.0, // Reduced size of the icon
                                ),
                                onPressed: () async {
                                  // Update the like status in Firestore
                                  await widget.postService.likePost(post, isLiked);

                                  // Update the like count in Firestore
                                  final updatedLikeCount = isLiked
                                      ? likeCountNotifier.value - 1
                                      : likeCountNotifier.value + 1;
                                  isLikedNotifier.value = !isLiked;
                                  likeCountNotifier.value = updatedLikeCount;
                                },
                              );
                            },
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable: likeCountNotifier,
                            builder: (context, likeCount, child) {
                              return Text('$likeCount Likes',
                                  style: const TextStyle(fontSize: 14)); // Display like count with smaller font
                            },
                          ),
                          SizedBox(width: 100), // Reduced space between icons
                          IconButton(
                            icon: const Icon(
                              Icons.chat_bubble,
                              color: Color.fromARGB(255, 175, 76, 145), // Customize the color of the comment icon
                              size: 20.0, // Reduced size of the icon
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
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
