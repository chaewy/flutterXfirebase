import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/comment.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentPage extends StatefulWidget {
  final PostModel post;

  const CommentPage({Key? key, required this.post}) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentState(post: post);
}

class _CommentState extends State<CommentPage> {
  final PostModel post;
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  String text = '';
  TextEditingController _textController = TextEditingController();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  UserModel? user;

  late ValueNotifier<bool> isLikedNotifier;
  late ValueNotifier<int> likeCountNotifier;

  _CommentState({required this.post});

  @override
  void initState() {
    super.initState();

    isLikedNotifier = ValueNotifier<bool>(false);
    likeCountNotifier = ValueNotifier<int>(0);

    _initializeLikeStatus();

    _userService.getUserInfo(post.creator).listen((userData) {
      setState(() {
        user = userData;
      });
    });
  }

  Future<void> _initializeLikeStatus() async {
    try {
      final currentUserLike = await _postService.getCurrentUserLike(post).first;
      final currentLikeCount = await _postService.getLikeCount(post).first;

      if (mounted) {
        isLikedNotifier.value = currentUserLike;
        likeCountNotifier.value = currentLikeCount;
      }
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

  // Function to delete a comment
  Future<void> onDeleteComment(DocumentReference commentRef) async {
    try {
      await _postService.deleteComment(commentRef);
    } catch (e) {
      print('Error deleting comment: ${e.toString()}');
      // Handle the error appropriately (e.g., show an error message)
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Comment Page'),
      ),
      body: user != null
          ? Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                      onTap: () {
                        if (user != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(user: user!),
                            ),
                          );
                        }
                      },
                      child: user!.profileImageUrl.isNotEmpty
                          ? CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(user!.profileImageUrl),
                            )
                          : Icon(Icons.person, size: 60),
                    ),

                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(user: user!),
                              ),
                            );
                          },
                          child: Text(
                            user!.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.0),
                    Text(
                      post.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      post.description,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    if (post.imageUrls.isNotEmpty) _buildImages(context, post.imageUrls),
                    SizedBox(height: 8.0),
                    SizedBox(height: 8.0),
                    Text(
                      post.timestamp.toDate().toString(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: isLikedNotifier,
                      builder: (context, isLiked, child) {
                        return ValueListenableBuilder<int>(
                          valueListenable: likeCountNotifier,
                          builder: (context, likeCount, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 20),
                                    IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: isLiked ? Colors.red : Colors.blue,
                                        size: 30.0,
                                      ),
                                      onPressed: () async {
                                        await _postService.likePost(post, isLiked);
                                        final updatedLikeCount = isLiked ? likeCount - 1 : likeCount + 1;
                                        isLikedNotifier.value = !isLiked;
                                        likeCountNotifier.value = updatedLikeCount;
                                      },
                                    ),
                                    Text('$likeCount Likes'),
                                    SizedBox(width: 50),
                                    IconButton(
                                      icon: Icon(
                                        Icons.chat_bubble,
                                        color: Colors.green, // Customize the color of the comment icon
                                        size: 30.0,
                                      ),
                                      onPressed: () {
                                        // Add your comment logic here
                                      },
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Form(
                                        child: TextField(
                                          controller: _textController,
                                          decoration: InputDecoration(
                                            hintText: 'Write a comment...',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            // Update the comment text when typing
                                            // Commenting out this part to avoid continuous updates while typing
                                            // setState(() {
                                            //   text = val;
                                            // });
                                          },
                                          onSubmitted: (val) {
                                            // Update the comment text when submitting the comment
                                            setState(() {
                                              text = val;
                                            });
                                          },
                                          textInputAction: TextInputAction.send,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      TextButton(
                                        style: ButtonStyle(
                                          foregroundColor: MaterialStateProperty.all(Colors.white), // Sets text color to white
                                          backgroundColor: MaterialStateProperty.all(Colors.blue), // Sets background color to blue
                                        ),
                                        onPressed: () async {
                                          if (_textController.text.isNotEmpty) {
                                            await _postService.comment(post, _textController.text);
                                            _textController.clear();
                                            setState(() {
                                              text = '';
                                            });
                                          } else {
                                            print("Comment text is empty");
                                          }
                                        },
                                        child: Text("Comment"),
                                      ),
                                    ],
                                  ),
                                ),
                                StreamBuilder<List<CommentModel>>(
                                  stream: _postService.getComments(post),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(child: Text('Error: ${snapshot.error}'));
                                    } else {
                                      List<CommentModel> comments = snapshot.data ?? [];
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: comments.length,
                                        itemBuilder: (context, index) {
                                          CommentModel comment = comments[index];
                                          return FutureBuilder<UserModel>(
                                            future: _postService.getUserInfoOnce(comment.creator),
                                            builder: (context, userSnapshot) {
                                              if (userSnapshot.connectionState == ConnectionState.waiting) {
                                                return Center(child: CircularProgressIndicator());
                                              } else if (userSnapshot.hasError) {
                                                return ListTile(
                                                  title: Text('Error loading user'),
                                                  subtitle: Text(comment.text),
                                                );
                                              } else {
                                                UserModel? commentUser = userSnapshot.data;
                                                bool isCommentCreator = comment.creator == currentUserId;
                                                return ListTile(
                                                  leading: commentUser?.profileImageUrl != null && commentUser!.profileImageUrl.isNotEmpty
                                                      ? CircleAvatar(
                                                          radius: 15,
                                                          backgroundImage: NetworkImage(commentUser.profileImageUrl),
                                                        )
                                                      : Icon(Icons.person),
                                                  title: Text(commentUser != null ? commentUser.name : 'User'),
                                                  subtitle: Text(comment.text),
                                                  trailing: isCommentCreator
                                                      ? IconButton(
                                                          icon: Icon(Icons.delete),
                                                          onPressed: () {
                                                            onDeleteComment(comment.ref);
                                                          },
                                                        )
                                                      : null,
                                                );
                                              }
                                            },
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
