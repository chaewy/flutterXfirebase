import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String creator;
  final String title; // Add title field
  final List<String> imageUrls; // Change imageUrl to List<String>
  final String description; // Add description field
  final Timestamp timestamp;
  int likeCount; // Field to store the number of likes
  DocumentReference ref;

  PostModel({
    required this.id,
    required this.creator,
    required this.title,
    required this.imageUrls,
    required this.description,
    required this.timestamp,
    this.likeCount = 0, // Initialize like count to 0
    required this.ref,
  });

  // Factory constructor to create a PostModel from a Firestore document.
  factory PostModel.fromDocument(DocumentSnapshot doc) {
    return PostModel(
      id: doc.id,
      creator: doc['creator'],
      title: doc['title'],
      imageUrls: (doc?['imageUrls'] as List<dynamic>).cast<String>(), // Cast dynamic to List<String>
      description: doc['description'],
      timestamp: doc['timestamp'],
      ref: doc.reference,
    );
  }
}
