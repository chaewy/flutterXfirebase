// event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String state;
  final String city;
  final String imageUrl;
  final String creator;
  final Timestamp timestamp;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.state,
    required this.city,
    required this.imageUrl,
    required this.creator,
    required this.timestamp,
  });

  factory EventModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      category: data['category'],
      state: data['state'],
      city: data['city'],
      imageUrl: data['imageUrl'],
      creator: data['creator'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'state': state,
      'city': city,
      'imageUrl': imageUrl,
      'creator': creator,
      'timestamp': timestamp,
    };
  }
}
