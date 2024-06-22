import 'package:cloud_firestore/cloud_firestore.dart';

class ReplyComCommentModel {
  final String id;
  final String author;
  final String text;

  ReplyComCommentModel({required this.id, required this.author, required this.text});

  // Create an instance from a Firestore document
  factory ReplyComCommentModel.fromDocument(DocumentSnapshot doc) {
    return ReplyComCommentModel(
      id: doc['id'],
      author: doc['author'],
      text: doc['text'],
    );
  }

  // Create an instance from a map (for example, from JSON)
  factory ReplyComCommentModel.fromMap(Map<String, dynamic> map) {
    return ReplyComCommentModel(
      id: map['id'],
      author: map['author'],
      text: map['text'],
    );
  }

  // Convert an instance to a map (for example, for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'text': text,
    };
  }
}
