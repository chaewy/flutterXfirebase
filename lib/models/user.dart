import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String profileImageUrl;
  final String bannerImageUrl;
  final String email;
  final String bio;
  final String birthday;
  final String location;
  final String education;
  final String hobby;

  UserModel({
    required this.uid,
    required this.name,
    required this.profileImageUrl,
    required this.bannerImageUrl,
    required this.email,
    this.bio = '',
    this.birthday = '',
    this.location = '',
    this.education = '',
    this.hobby = '',
  });

  // Factory constructor to create a UserModel from a DocumentSnapshot
    
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id, // The document ID is likely the user's UID
      name: data['name'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      bannerImageUrl: data['bannerImageUrl'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      birthday: data['birthday'] ?? '',
      location: data['location'] ?? '',
      education: data['education'] ?? '',
      hobby: data['hobby'] ?? '',
    );
  }
}
