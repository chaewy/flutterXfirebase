

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/services/user.dart';

// FOR ADD POST

class PostService with ChangeNotifier{

  List<PostModel> _posts = []; // Internal list of posts

  List<PostModel> get posts => _posts; // Getter for accessing the posts

   final FirebaseFirestore _db = FirebaseFirestore.instance;

List<PostModel> _postListFromSnapshot(QuerySnapshot snapshot) {
  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic>
    if (data != null) {
      return PostModel(
        id: doc.id,
        text: data['text'] ?? '',
        creator: data['creator'] ?? '',
        timestamp: data['timestamp'] != null ? data['timestamp'] : Timestamp.now(),

      );
    } else {
      // Handle the case where data is null
      // You might want to throw an error, return a default value, or handle it based on your application logic.
      return PostModel(
        id: doc.id,
        text: '',
        creator: '',
        timestamp: Timestamp.now(), // or any other default value you prefer
      );
    }
  }).toList();
}


  Future savePost(text) async{
    await FirebaseFirestore.instance.collection("post").add({
      'text': text,
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),

    });
  }

// ------------------------------------------------------------------------------------------------

  Stream<bool> getCurrentUserLike(PostModel post){
    return FirebaseFirestore.instance
        .collection("post")
        .doc(post.id)
        .collection("likes")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .map((snapshot){
          return snapshot.exists; 
        });
  }


  Future likePost(PostModel post, bool current) async{
    print(post.id);
    if(current){
      await FirebaseFirestore.instance
        .collection("post")
        .doc(post.id)
        .collection("likes")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .delete();
    }

    if(!current){
      await FirebaseFirestore.instance
        .collection("post")
        .doc(post.id)
        .collection("likes")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set({});
    }
  }

  //StreamController<int> _likeCountController = StreamController<int>();

  Stream<int> getLikeCount(PostModel post) {
    return FirebaseFirestore.instance
      .collection('post')
      .doc(post.id)
      .collection('likes')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}

Future<void> updateLikeCount(PostModel post) async {
  try {
    DocumentReference postRef = _db.collection('post').doc(post.id);
    CollectionReference likesRef = postRef.collection('likes');
    
    QuerySnapshot snapshot = await likesRef.get();
    int likeCount = snapshot.size;
    
    // Update the like count in the post document
    await postRef.update({'likeCount': likeCount});
  } catch (e) {
    print('Error updating like count: $e');
    // Handle any errors that may occur during the update process
  }
}

// ------------------------------------------------------------------------------------------------

  //just display post by the user , if want to show all post , change the uid to all uid
  Stream<List<PostModel>> getPostByUser(uid){
    return FirebaseFirestore.instance
    .collection("post")
    .where('creator', isEqualTo: uid)
    .snapshots()
    .map(_postListFromSnapshot);
  }


  // Future<List<PostModel>> getFeed() async{
  //   List<String> usersFollowing = await UserService()
  //     .getUserFollowing(FirebaseAuth.instance.currentUser?.uid);


  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection("posts")
  //       .where("creator", whereIn: usersFollowing)
  //       .orderBy('timestamp', descending: true)
  //       .get();


  //     return _postListFromSnapshot(querySnapshot);


  // }


  // In the getFeed method:
  // We accept two optional parameters: limit to specify the maximum number of documents to fetch per page, 
  // and startAfterDocument to specify the document from which to start fetching the next page of documents.
  // We create a Query to retrieve documents from the Firestore collection 'post', ordered by 'timestamp' in descending order, 
  // and limited by the specified limit.
  // If startAfterDocument is provided, we use the startAfterDocument method on the query to start fetching documents after the specified document.
  // We then return a stream of List<PostModel> where each element represents a page of posts.
  // With this implementation, the getFeed method now supports pagination by allowing you to specify the limit and startAfterDocument parameters.
  //  This enables you to fetch posts in pages, improving performance and providing a better user experience when displaying large datasets

  // This method returns a stream of List<PostModel> which contains the posts from Firestore.
  Stream<List<PostModel>> getFeed({int limit = 10, DocumentSnapshot? startAfterDocument}) {
    Query query = FirebaseFirestore.instance
        .collection('post')
        .orderBy('timestamp', descending: true)
        .limit(limit); // Limit the number of documents fetched

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    return query.snapshots().map((querySnapshot) {
      // Map querySnapshot.docs to List<PostModel>
      List<PostModel> posts = querySnapshot.docs.map((doc) {
        return PostModel.fromDocument(doc);
      }).toList();

      return posts;
    });
  }






}