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
}