import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityCommentModel {
  final String id;
  final String text;
  final String creator;
  final Timestamp timestamp;
  final DocumentReference ref;

  CommunityCommentModel({
    required this.id,
    required this.text,
    required this.creator,
    required this.timestamp,
    required this.ref,
  });

  factory CommunityCommentModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic>
    return CommunityCommentModel(
      id: doc.id,
      text: data?['text'] ?? '',
      creator: data?['creator'] ?? '',
      timestamp: data?['timestamp'] ?? Timestamp.now(),
      ref: doc.reference,
    );
  }
}

