

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/comment.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/events/eventDetails_page.dart';
import 'package:flutter_application_1/pages/post/comment.dart';
import 'package:flutter_application_1/services/user.dart';

// FOR ADD POST

class PostService with ChangeNotifier{

  List<PostModel> _posts = []; // Internal list of posts

  List<PostModel> get posts => _posts; // Getter for accessing the posts

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance; // Add this line

  String userId = FirebaseAuth.instance.currentUser!.uid;

List<PostModel> _postListFromSnapshot(QuerySnapshot snapshot) {
  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic>
    if (data != null) {
      // Parse imageUrls as List<String>
      List<String> imageUrls = (data['imageUrls'] as List<dynamic>).cast<String>();
      
      return PostModel(
        id: doc.id,
        creator: data['creator'] ?? '',
        title: data['title'] ?? '',
        imageUrls: imageUrls, // Assign parsed list of strings to imageUrls
        description: data['description'] ?? '',
        timestamp: data['timestamp'] != null ? data['timestamp'] : Timestamp.now(),
        ref: doc.reference,
      );
    } else {
      // Handle the case where data is null
      // You might want to throw an error, return a default value, or handle it based on your application logic.
      return PostModel(
        id: doc.id,
        creator: '',
        title: '',
        imageUrls: [],
        description: '',
        timestamp: Timestamp.now(), // or any other default value you prefer
        ref: doc.reference,
      );
    }
  }).toList();
}


// ------------------------------------------------------------------------------------------------
// save post
  Future<void> savePost(String title, String description, List<File> images, String category) async {
  try {
    List<String> imageUrls = [];

    for (File image in images) {
      final storageRef = FirebaseStorage.instance.ref().child('post_images/${DateTime.now().toIso8601String()}');
      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    await FirebaseFirestore.instance.collection("post").add({
      'title': title,
      'description': description,
      'imageUrls': imageUrls, // Use 'imageUrls' instead of 'imageUrl'
      'category': category, 
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Error saving post: $e');
  }
}

// ------------------------------------------------------------------------------------------------
//                             Comment


  Future<void>comment(PostModel post, String commentText) async {
  try {
    print("Attempting to add comment: $commentText");
    await FirebaseFirestore.instance
        .collection('post')
        .doc(post.id)
        .collection('comments')
        .add({
      'text': commentText,
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print("Comment added successfully");
  } catch (e) {
    print('Error adding comment: ${e.toString()}');
    // Handle error appropriately (display a message to the user)
  }
}


// ------------------------------------------------------------------------------------------------
//                             LIKE

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

//---------------------------------------------------------------------------------------------------------------

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

// ------------------------------------------------------------------------------------------------

   // Method to convert Firestore snapshot to list of CommentModel
  List<CommentModel> _commentListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return CommentModel.fromDocument(doc);
    }).toList();
  }

  // Method to get comments as a stream of List<CommentModel>
  Stream<List<CommentModel>> getComments(PostModel post) {
    return post.ref
        .collection("comments")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .map(_commentListFromSnapshot);
  }


  Future<UserModel> getUserInfoOnce(String userId) async {
  try {
    DocumentSnapshot userDoc = await _db.collection('Users').doc(userId).get();
    if (userDoc.exists) {
      return UserModel.fromDocument(userDoc);
    } else {
      return Future.value(null); // Return null wrapped in a Future
    }
  } catch (e) {
    print('Error getting user info: ${e.toString()}');
    rethrow; 
  }
}

  // ------------------------------------------------------------------------------------------------
  // Delete a comment from a post

  Future<void> deleteComment(DocumentReference commentRef) async {
    try {
      if (_auth.currentUser != null) {
        await commentRef.delete();
      } else {
        print('User not authenticated');
      }
    } catch (e) {
      print('Error deleting comment: ${e.toString()}');
    }
  }
// ------------------------------------------------------------------------------------------------
  // save events post

 Future<void> saveEventPost({
  required String title,
  required String description,
  required String category,
  required String streetName,
  required String town,
  required String region,
  required String state,
  required List<File> images,
}) async {
  try {
    List<String> imageUrls = [];

    // Upload images to Firebase Storage
    for (var imageFile in images) {
      final storageRef = FirebaseStorage.instance.ref().child('event_images/${DateTime.now().toIso8601String()}');
      await storageRef.putFile(imageFile);
      final url = await storageRef.getDownloadURL();
      imageUrls.add(url);
    }

    // Save event data to Firestore
    await FirebaseFirestore.instance.collection("event").add({
      'title': title,
      'description': description,
      'category': category,
      'streetName': streetName,
      'town': town,
      'region': region,
      'state': state,
      'imageUrl': imageUrls, // Store list of image URLs
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Error saving event post: $e');
    // You can handle errors here, such as showing an error message to the user
  }
}

// ------------------------------------------------------------------------------------------------
  //get save events post
  Stream<List<EventModel>> getEventPosts() {
    return FirebaseFirestore.instance
        .collection('event')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return EventModel.fromDocument(doc);
      }).toList();
    });
  }

  //------------------------------------------------------------------------------------

  //                           EVENT

  // Add the following method to the PostService class

  Future<bool> joinEvent(EventModel event) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot participantDoc = await FirebaseFirestore.instance
          .collection('event')
          .doc(event.id)
          .collection('participants')
          .doc(userId)
          .get();

      if (participantDoc.exists) {
        return true; // User has already joined the event
      } else {
        await FirebaseFirestore.instance
            .collection('event')
            .doc(event.id)
            .collection('participants')
            .doc(userId)
            .set({
              'userId': userId,
              'joinedAt': FieldValue.serverTimestamp(),
            });
        return false; // User successfully joined the event
      }
    } catch (e) {
      print('Error joining event: $e');
      return false; // Return false if an error occurs
    }
  }

   Future<void> leaveEvent(EventModel event, String userId) async {
    try {
      DocumentReference participantDoc = _db
          .collection('event')
          .doc(event.id)
          .collection('participants')
          .doc(userId);
      await participantDoc.delete();
    } catch (e) {
      print('Error leaving event: $e');
    }
  }

  



}