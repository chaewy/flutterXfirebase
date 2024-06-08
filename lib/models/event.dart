// event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String streetName;
  final String town;
  final String region;
  final String state;
  final String imageUrl;
  final String creator;
  final Timestamp timestamp;
  //streetName , town, region and state 

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.streetName,
    required this.town,
    required this.region,
    required this.state,
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
      streetName: data['streetName'],
      town: data['town'],
      region: data['region'],
      state: data['state'],
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
      'streetName': streetName,
      'town': town,
      'region': region,
      'state': state,
      'imageUrl': imageUrl,
      'creator': creator,
      'timestamp': timestamp,
    };
  }
}
