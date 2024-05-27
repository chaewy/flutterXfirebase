import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
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
  final UserService _userService = UserService();
  final PostService _postService = PostService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comment Page'),
      ),
      body: user != null
          ? Padding(
          padding: EdgeInsets.fromLTRB(3.0, 8.0, 16.0, 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  leading: user!.profileImageUrl.isNotEmpty
                      ? CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(user!.profileImageUrl),
                    )
                      : Icon(Icons.person, size: 60),
                  title: Text(
                    user!.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.0),
                      Text(post.text),
                      SizedBox(height: 8.0),
                      Text(
                        post.timestamp.toDate().toString(),
                        style: TextStyle(color: Colors.grey, fontSize: 12.0),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<bool>(
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
                            final likeCount = likeCountSnapshot.data ?? 0;

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
                                      onPressed: () {
                                        _postService.likePost(post, isLiked);
                                        _postService.updateLikeCount(post);
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