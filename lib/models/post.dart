import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String creator;
  final String text;
  final Timestamp timestamp;

  PostModel({
    required this.id,
    required this.text,
    required this.creator,
    required this.timestamp,
  });


  // Factory constructor to create a PostModel from a Firestore document.
  factory PostModel.fromDocument(DocumentSnapshot doc) {
    return PostModel(
      id: doc.id,
      creator: doc['creator'],
      text: doc['text'],
      timestamp: doc['timestamp'],
    );
  }
}
