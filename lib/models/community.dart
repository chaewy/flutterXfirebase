import 'package:cloud_firestore/cloud_firestore.dart';

// for community

import 'package:cloud_firestore/cloud_firestore.dart';

class Community {
  final String id; // Document ID (comID) in Firestore
  final String name;
  final String description;
  final Timestamp createdAt;
  String creatorId; // Creator's user ID
  String iconImage; // URL or path to icon image
  String bannerImage; // URL or path to banner image  
  final String topics;
  DocumentReference ref; // Firestore document reference

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.creatorId,
    required this.iconImage,
    required this.bannerImage,
    required this.topics,
    required this.ref, // Include ref in the constructor
  });

  // Factory constructor to create Community object from Firestore document snapshot
  factory Community.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Community(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      creatorId: data['creatorId'] ?? '',
      iconImage: data['iconImage'] ?? '', // Ensure to fetch iconImage from Firestore
      bannerImage: data['bannerImage'] ?? '', // Ensure to fetch bannerImage from Firestore
      topics: data['topics'] ?? '',
      ref: doc.reference, // Initialize ref with document reference
    );
  }

  // Convert Community object to a map (Firestore format)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'creatorId': creatorId,
      'iconImage': iconImage,
      'bannerImage': bannerImage,
      'topics': topics,
    };
  }
}



class Member {
  final String userId; // Unique identifier of the member

  Member({
    required this.userId,
  });

  // Convert Member object to a map (Firestore format)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
    };
  }
}
