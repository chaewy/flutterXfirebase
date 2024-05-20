

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/services/user.dart';

// FOR ADD POST

class PostService{

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

  // This method returns a stream of List<PostModel> which contains the posts from Firestore.
  Stream<List<PostModel>> getFeed() {
    // Create a query to the 'post' collection, ordering by 'timestamp' in descending order.
    return FirebaseFirestore.instance
        .collection('post') // Collection name should match your Firestore structure
        .orderBy('timestamp', descending: true) // Order by timestamp, newest first
        .snapshots() // Listen to real-time updates
        .map((querySnapshot) {
          // Debugging: Print the number of documents received
          print('QuerySnapshot received: ${querySnapshot.docs.length} documents');
          
          // Map each document to a PostModel and collect them into a list
          return querySnapshot.docs.map((doc) {
            // Debugging: Print each document's ID and data
            print('Processing document: ${doc.id}');
            print('Document Data: ${doc.data()}');
            
            // Convert Firestore document to PostModel
            return PostModel.fromDocument(doc);
          }).toList(); // Return the list of PostModels
        });
  }








}