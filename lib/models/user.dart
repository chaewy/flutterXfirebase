import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String profileImageUrl;
  final String bannerImageUrl;
  final String email;

  UserModel({
    required this.uid,
    required this.name,
    required this.profileImageUrl,
    required this.bannerImageUrl,
    required this.email,
  });

  // Factory constructor to create a UserModel from a DocumentSnapshot
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      uid: doc.id, // The document ID is likely the user's UID
      name: doc['name'],
      profileImageUrl: doc['profileImageUrl'],
      bannerImageUrl: doc['bannerImageUrl'],
      email: doc['email'],
    );
  }
}