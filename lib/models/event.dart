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
  final List<String> imageUrl;
  final String creator;
  final Timestamp timestamp;
  final int day; // Added day property
  final int month; // Added month property
  final int year; // Added year property
  int participantCount;

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
    required this.day, // Initialize with 0
    required this.month, // Initialize with 0
    required this.year, // Initialize with 0
    this.participantCount = 0,
  });

  factory EventModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<String> imageUrl = [];
    final dynamic imageUrlData = data['imageUrl'];
    if (imageUrlData != null) {
      if (imageUrlData is List) {
        imageUrl = List<String>.from(imageUrlData);
      } else if (imageUrlData is String) {
        imageUrl = [imageUrlData];
      }
    }
    return EventModel(
      id: doc.id,
      title: data['title'],
      description: data['description'],
      category: data['category'],
      streetName: data['streetName'],
      town: data['town'],
      region: data['region'],
      state: data['state'],
      imageUrl: imageUrl,
      creator: data['creator'],
      timestamp: data['timestamp'],
      day: data['day'],
      month: data['month'],
      year: data['year'],
      participantCount: data['participantCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'day': day,
      'month': month,
      'year': year,
      'participantCount': participantCount,
    };
  }
}
