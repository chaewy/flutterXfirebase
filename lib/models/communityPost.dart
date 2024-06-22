import 'package:cloud_firestore/cloud_firestore.dart';


//    FOR COMMUNITY POST

class CommunityModel {
  final String id;
  final String communityId; // New field for the community ID
  final String creator;
  final String title;
  final List<String> imageUrls;
  final String description;
  final Timestamp timestamp;
  int likeCount;
  DocumentReference ref;

  CommunityModel({
    required this.id,
    required this.communityId,
    required this.creator,
    required this.title,
    required this.imageUrls,
    required this.description,
    required this.timestamp,
    this.likeCount = 0,
    required this.ref,
  });

  factory CommunityModel.fromDocument(DocumentSnapshot doc) {
    return CommunityModel(
      id: doc.id,
      communityId: doc.get('communityId'), // Retrieve communityId from Firestore document
      creator: doc.get('creator'),
      title: doc.get('title'),
      imageUrls: (doc.get('imageUrls') as List<dynamic>).cast<String>(),
      description: doc.get('description'),
      timestamp: doc.get('timestamp'),
      likeCount: doc.get('likeCount') ?? 0,
      ref: doc.reference,
    );
  }
}
