import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/services/add_post.dart';



class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();
  List<PostModel> _postList = [];

  List<PostModel> get postList => _postList;

  // Method to fetch posts by the current user
  void fetchUserPosts(String uid) {
    _postService.getPostByUser(uid).listen((posts) {
      _postList = posts;
      notifyListeners();
    });
  }
  }
