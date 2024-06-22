import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String profileImageUrl;
  final String bannerImageUrl;
  final String email;
  final String bio;
  final String birthday;
  final String fcmToken; // New field to store FCM token
  String gender; // Add gender field
  String streetName;
  String town;
  String region;
  String state;
 
  

  UserModel({
    required this.uid,
    required this.name,
    required this.profileImageUrl,
    required this.bannerImageUrl,
    required this.email,
    this.bio = '',
    this.birthday = '',
    this.fcmToken = '', // Initialize with empty string
    required this.gender,
    required this.streetName,
    required this.town,
    required this.region,
    required this.state,
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
      gender: data['gender'] ?? '',
      fcmToken: data['fcmToken'] ?? '', // Populate FCM token from data
      streetName: data['streetName'] ?? '',
      town: data['town'] ?? '',
      region: data['region'] ?? '',
      state: data['state'] ?? '',
    );
  }
}
