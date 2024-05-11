

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/post.dart';

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
}