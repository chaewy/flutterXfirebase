import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/comment.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
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

  _CommentState({required this.post});

  @override
  void initState() {
    super.initState();

    _userService.getUserInfo(post.creator).listen((userData) {
      setState(() {
        user = userData;
      });
    });
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
                        user!.profileImageUrl.isNotEmpty
                            ? CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    NetworkImage(user!.profileImageUrl),
                              )
                            : Icon(Icons.person, size: 60),
                        SizedBox(width: 10),
                        Text(
                          user!.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
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


                    if (post.imageUrls.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.0),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: post.imageUrls.map((imageUrl) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullImagePage(imageUrl: imageUrl),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    imageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),




                    SizedBox(height: 8.0),
                    Text(
                      post.description,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      post.timestamp.toDate().toString(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                    StreamBuilder<bool>(
                      stream: _postService.getCurrentUserLike(post),
                      builder: (context, likeSnapshot) {
                        if (likeSnapshot.connectionState ==
                            ConnectionState.waiting) {
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
                              if (likeCountSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (likeCountSnapshot.hasError) {
                                return ListTile(
                                  title: Text('Error loading like count'),
                                  subtitle: Text(post.title),
                                );
                              } else {
                                final likeCount =
                                    likeCountSnapshot.data ?? 0;
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 20),
                                        IconButton(
                                          icon: Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isLiked
                                                ? Colors.red
                                                : Colors.blue,
                                            size: 30.0,
                                          ),
                                          onPressed: () {
                                            _postService.likePost(
                                                post, isLiked);
                                            _postService.updateLikeCount(post);
                                          },
                                        ),
                                        Text('$likeCount Likes'),
                                        SizedBox(width: 50),
                                        IconButton(
                                          icon: Icon(
                                            Icons.chat_bubble,
                                            color: Colors
                                                .green, // Customize the color of the comment icon
                                            size: 30.0,
                                          ),
                                          onPressed: () {
                                            // Add your comment logic here
                                          },
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Form(
                                            child: TextField(
                                              controller: _textController,
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Write a comment...',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
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
                                              textInputAction:
                                                  TextInputAction.send,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          TextButton(
                                            style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors
                                                          .white), // Sets text color to white
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors
                                                          .blue), // Sets background color to blue
                                            ),
                                            onPressed: () async {
                                              if (_textController
                                                  .text.isNotEmpty) {
                                                await _postService.comment(
                                                    post,
                                                    _textController.text);
                                                _textController.clear();
                                                setState(() {
                                                  text = '';
                                                });
                                              } else {
                                                print(
                                                    "Comment text is empty");
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
                                                              radius: 20,
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
                              }
                            },
                          );
                        }
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
