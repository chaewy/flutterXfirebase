import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/comment.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/reply.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart'; // Adjust import path as per your project structure
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';

class CommentPage extends StatefulWidget {
  final PostModel post;

  const CommentPage({Key? key, required this.post}) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentState(post: post);
}

class _CommentState extends State<CommentPage> {
  final PostModel post;
  final UserService _userService = UserService(); // Your user service instance
  final PostService _postService = PostService(); // Your post service instance
  TextEditingController _replyController = TextEditingController();
   UserModel? _user; // Initialize user variable
    String? expandedCommentId; // Track expanded comment for replies

  UserModel? user;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comment Page'),
      ),
      body: user != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User information and post details
                    _buildPostHeader(),
                    SizedBox(height: 16.0),
                    Text(
                      post.title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(height: 8.0),
                    if (post.imageUrls.isNotEmpty) _buildImages(context, post.imageUrls),
                    SizedBox(height: 8.0),
                    Text(
                      post.description,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      post.timestamp.toDate().toString(),
                      style: TextStyle(color: Colors.grey, fontSize: 12.0),
                    ),
                    SizedBox(height: 16.0),
                    // Comment section
                    _buildCommentSection(),
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildPostHeader() {
    return Row(
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ],
    );
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
            height: 200, // Fixed height example (adjust as needed)
          ),
        ),
      );
    } else {
      return Container(
        height: 200, // Fixed height example (adjust as needed)
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

    Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comment input field
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _replyController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    onPressed: () async {
                      await _handleCommentSubmission();
                    },
                    child: Text("Comment"),
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (val) {
                  _handleCommentSubmission();
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        // StreamBuilder for comments
        StreamBuilder<List<CommentModel>>(
          stream: _postService.getComments(post), // Assuming getComments returns Stream<List<CommentModel>>
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
                    future: _postService.getUserInfoOnce(comment.creator), // Assuming getUserInfoOnce returns Future<UserModel>
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
                        return _buildCommentItem(comment, commentUser, isCommentCreator);
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

Widget _buildCommentItem(CommentModel comment, UserModel? commentUser, bool isCommentCreator) {
  TextEditingController replyController = TextEditingController(); // Controller for reply text field
  bool isExpanded = expandedCommentId == comment.id;

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
  Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 40,
        height: 40,
        child: commentUser?.profileImageUrl != null && commentUser!.profileImageUrl.isNotEmpty
            ? CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(commentUser.profileImageUrl),
              )
            : Icon(Icons.person),
      ),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              commentUser != null ? commentUser.name : 'User',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              comment.text,
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
      // Popup menu for delete option (shown conditionally)
      if (isCommentCreator)
        PopupMenuButton(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              onDeleteComment(comment.ref); // Call delete function when selected
            }
          },
        ),
    ],
  ),

        SizedBox(width: 8),
        // Dropdown for replies
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle button for expanding/collapsing replies
            GestureDetector(
              onTap: () {
                setState(() {
                  expandedCommentId = isExpanded ? null : comment.id; // Toggle expansion
                });
              },
              child: Row(
                children: [
                  SizedBox(width: 50), // Adjust the width as needed
                  Text(
                    isExpanded ? 'Close Replies' : 'Reply',
                    style: TextStyle(color: Colors.blue), // Apply blue color to the text
                  ),
                ],
              ),

            ),
            if (isExpanded) // Show replies if expanded
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // StreamBuilder for replies
                  StreamBuilder<List<ReplyCommentModel>>(
                    stream: _postService.getReplies(post.id, comment.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error loading replies: ${snapshot.error}');
                      } else {
                        List<ReplyCommentModel> replies = snapshot.data ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: replies.map((reply) {
                            return StreamBuilder<UserModel>(
                              stream: _userService.getUserInfo(reply.author),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState == ConnectionState.waiting) {
                                  return ListTile(
                                    title: Text('Loading...'),
                                  );
                                } else if (userSnapshot.hasError) {
                                  return ListTile(
                                    title: Text('Error loading user: ${userSnapshot.error}'),
                                  );
                                } else {
                                  UserModel? user = userSnapshot.data;
                                  bool isCurrentUser = user != null && user.uid == currentUserId;

                                  return ListTile(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    leading: user != null && user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 18,
                                            backgroundImage: NetworkImage(user.profileImageUrl!),
                                          )
                                        : Icon(Icons.person, size: 36), // Adjust size as needed
                                    title: Text(
                                      reply.text ?? '',
                                      style: TextStyle(fontSize: 14),  // Adjust the font size as needed
                                    ),
                                    subtitle: Text(
                                      'Reply by ${user?.name ?? 'Unknown'}',
                                      style: TextStyle(fontSize: 12),  // Adjust the font size as needed
                                    ),
                                    trailing: isCurrentUser
                                        ? PopupMenuButton(
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete Reply'),
                                              ),
                                            ],
                                            onSelected: (value) async {
                                              if (value == 'delete') {
                                                try {
                                                  await _postService.deleteReply(post.id, comment.id, reply.author); // Ensure you pass reply.id for deletion
                                                  // Optional: Show a success message or update the UI
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Reply deleted'),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  // Handle error
                                                  print('Failed to delete reply: $e');
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Failed to delete reply'),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          )
                                        : null,
                                  );
                                }
                              },
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),





                  SizedBox(height: 8),
                  // Text field and reply button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: replyController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12), // Adjust padding
                            hintText: 'Reply to this comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0), // Adjust border radius
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Spacer between TextField and button
                      TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 16)), // Adjust button padding
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          backgroundColor: MaterialStateProperty.all(Colors.blue),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0), // Adjust button border radius
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await _handleReplySubmission(comment, replyController.text);
                          replyController.clear();
                        },
                        child: Text("Reply"),
                      ),
                    ],
                  ),
                ],
              ),


          ],
        ),
        SizedBox(width: 8),
            Container(),
      ],
    ),
  );
}





Future<void> _handleReplySubmission(CommentModel comment, String text) async {
  if (text.isNotEmpty) {
    String postId = post.id; // Assuming post.id is the postId needed
    String commentId = comment.id; // Assuming comment.id is the commentId needed
    String author = currentUserId; // Assuming currentUserId is the author

    await _postService.replyToComment(
      postId: postId,
      commentId: commentId,
      text: text,
      author: author,
    );

    // Optionally, update UI after submitting reply
    setState(() {
      // Update state or perform any UI-related tasks
    });
  } else {
    print("Reply text is empty");
  }
}





  Future<void> _handleCommentSubmission() async {
    String text = _replyController.text.trim();
    if (text.isNotEmpty) {
      await _postService.comment(post, text);
      _replyController.clear();
    } else {
      print("Comment text is empty");
    }
  }

  Future<void> onDeleteComment(DocumentReference commentRef) async {
    try {
      await _postService.deleteComment(commentRef);
    } catch (e) {
      print('Error deleting comment: ${e.toString()}');
      // Handle the error appropriately (e.g., show an error message)
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }
}
