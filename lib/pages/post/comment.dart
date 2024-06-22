import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/pages/post/comment_page.dart';

class Comment extends StatefulWidget {
  final PostModel post;

  Comment({Key? key, required this.post}) : super(key: key);

  @override
  FeedState createState() => FeedState(post: post);
}

class FeedState extends State<Comment> {
  late PostModel post;

  FeedState({required this.post});

  @override
  void initState() {
    super.initState();
    post = widget.post; // Initialize the post object in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommentPage(post: post),
      
    );
  }
}