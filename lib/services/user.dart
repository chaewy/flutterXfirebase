import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/services/utils.dart';

class UserService {

  UtilsService _utilsService = UtilsService();

  Future<void> updateProfile(
    File bannerImage, File profileImage, String name) async {
    
    String bannerImageUrl = ''; // Initialize with default value
    String profileImageUrl = ''; // Initialize with default value

    //all user doc
    final userCollection = FirebaseFirestore.instance.collection("Users");
    final currentUser = FirebaseAuth.instance.currentUser!;

    


    if (bannerImage != null) {

      // save the banner image to storage
      bannerImageUrl = await _utilsService.uploadFile(bannerImage, 
      'user/profile/${FirebaseAuth.instance.currentUser!.uid}/banner');

    }

    if (profileImage != null) {

      // save the profile image to storage
      profileImageUrl = await _utilsService.uploadFile(profileImage, 
      'user/profile/${FirebaseAuth.instance.currentUser!.uid}/profile');

      
    }

   // Create a map to store the updated data
    Map<String, dynamic> data = {};

    if (name.isNotEmpty) data['name'] = name;
    if (bannerImageUrl.isNotEmpty) data['bannerImageUrl'] = bannerImageUrl;
    if (profileImageUrl.isNotEmpty) data['profileImageUrl'] = profileImageUrl;

  try {
      // Reference the 'Users' collection and the specific document
      DocumentReference userDocRef = userCollection.doc(currentUser.email);

      // Update the document with the new data
      await userDocRef.update(data);

      print('Profile updated successfully.');
    } catch (e) {
      print('Error updating profile: $e');
    }

  }
}
