import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/com_comment.dart';
import 'package:flutter_application_1/models/com_reply.dart';
import 'package:flutter_application_1/models/community.dart';
import 'package:flutter_application_1/models/communityPost.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/community_service.dart';
import 'package:flutter_application_1/services/user.dart';

class ComPostDetails extends StatefulWidget {
  final CommunityModel communitypost; //    FOR COMMUNITY POST
  final Community community; // for community
 

  ComPostDetails({Key? key, required this.communitypost, required this.community}) : super(key: key);

  @override
  _ComPostDetailsState createState() => _ComPostDetailsState();
}

class _ComPostDetailsState extends State<ComPostDetails> {
  bool _isLiked = false;
  late Stream<bool> _currentUserLikeStream;
  late String _creatorUsername = '';
  late String _creatorProfileImageUrl = '';

  UserModel? _user;
  String? expandedCommentId;

  final CommunityService _communityService = CommunityService();
  final PostService _postService = PostService();
  final UserService _userService = UserService();

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initPostDetails();
  }

  void _initPostDetails() async {
    // Initialize like status
    _currentUserLikeStream = _communityService.getCurrentUserLike(widget.communitypost);
    _currentUserLikeStream.listen((isLiked) {
      setState(() {
        _isLiked = isLiked;
      });
    });

    // Fetch creator's username and profile image URL
    try {
      UserModel creator = await _communityService.getUser(widget.communitypost.creator);
      setState(() {
        _creatorUsername = creator.name;
        _creatorProfileImageUrl = creator.profileImageUrl;
      });
    } catch (e) {
      print('Error fetching creator details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: _creatorProfileImageUrl.isNotEmpty
                      ? NetworkImage(_creatorProfileImageUrl)
                      : AssetImage('assets/images/default_profile_image.jpg') as ImageProvider,
                  radius: 16,
                ),
                SizedBox(width: 8),
                Text(
                  _creatorUsername,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              widget.communitypost.title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            if (widget.communitypost.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: widget.communitypost.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      widget.communitypost.imageUrls[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            SizedBox(height: 8),
            Text(
              widget.communitypost.description,
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 8),
            Text(
              widget.communitypost.timestamp.toDate().toString(),
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    _handleLikeUnlike();
                  },
                ),
                SizedBox(width: 8),
                StreamBuilder<int>(
                  stream: _communityService.getLikeCount(widget.communitypost),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      print('Error: ${snapshot.error}');
                      return Text('Error');
                    }
                    int likeCount = snapshot.data ?? 0;
                    return Text(
                      '$likeCount Likes',
                      style: TextStyle(fontSize: 16),
                    );
                  },
                ),
                // _buildCommentSection(),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _buildCommentSection(),
            ),
          ],
        ),
      ),
    );
  }


 //-------------------------------------------------------------------------------------------------------------------------------------------

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
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Adjust the value as needed
                        ),
                      ),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 245, 168, 35)),
                    ),
                    onPressed: () async {
                      // CommunityCommentModel comment, String text
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
        StreamBuilder<List<CommunityCommentModel>>(
          // Community community, CommunityModel communityPost
          stream: _communityService.getCommentsStream(widget.community,widget.communitypost), // Assuming getComments returns Stream<List<CommentModel>>
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<CommunityCommentModel> comments = snapshot.data ?? [];
              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  CommunityCommentModel comment = comments[index];
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

  //-------------------------------------------------------------------------------------------------------------------------------------------

Widget _buildCommentItem(CommunityCommentModel comment, UserModel? commentUser, bool isCommentCreator) {
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
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              onDeleteComment(comment.id); // Pass the comment id or necessary parameters
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
                  // String communityId, String postId, String commentId
                  StreamBuilder<List<ReplyComCommentModel>>(
                    stream: _communityService.getRepliesStream(widget.community.id, widget.communitypost.id,  comment.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error loading replies: ${snapshot.error}');
                      } else {
                        List<ReplyComCommentModel> replies = snapshot.data ?? [];
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
                                                  //String communityId, String postId, String commentId, String replyId
                                                  await _communityService.deleteReply(widget.community.id,widget.communitypost.id, comment.id, reply.id); // Ensure you pass reply.id for deletion
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
                          backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 245, 168, 35)),
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


 //-------------------------------------------------------------------------------------------------------------------------------------------

void _handleLikeUnlike() async {
  try {
    // Perform like/unlike operation
    await _communityService.likePost(widget.communitypost, _isLiked);

    // Update _isLiked based on the current state in Firestore
    bool isCurrentlyLiked = await _communityService.getCurrentUserLike(widget.communitypost).first;
    
    setState(() {
      _isLiked = isCurrentlyLiked;
      print('Updated _isLiked value: $_isLiked');
    });
  } catch (e) {
    print('Error liking/unliking post: $e');
    // Handle error as needed
  }
}

    Future<void> _handleReplySubmission(CommunityCommentModel comment, String text) async {
      //String communityId, String postId, String commentId, String replyText
      if (text.isNotEmpty) {
        try {
          await  _communityService.replyToComment(
            widget.community.id,
            widget.communitypost.id,
            comment.id,
            text,
          );

          // Optionally, update UI after submitting reply
          setState(() {
            // Update state or perform any UI-related tasks
          });
        } catch (e) {
          print('Error adding reply: ${e.toString()}');
          // Handle the error appropriately (e.g., show an error message)
        }
      } else {
        print("Reply text is empty");
      }
    }



    Future<void> _handleCommentSubmission() async {
    String text = _replyController.text.trim();
    if (text.isNotEmpty) {
      await _communityService.comment(
            widget.community, 
            text,
            widget.communitypost,
            );
      _replyController.clear();
    } else {
      print("Comment text is empty");
    }
  }


      Future<void> onDeleteComment(String commentId) async {
  try {
    await _communityService.deleteComment(
      widget.community,
      widget.communitypost,
      commentId,
    );
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




