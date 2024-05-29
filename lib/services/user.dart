import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/utils.dart';


class UserService {

  UtilsService _utilsService = UtilsService();

  String? uid = FirebaseAuth.instance.currentUser?.uid;

  List<UserModel> _userListFromQuerySnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return UserModel(
        uid: doc.id,
        name: doc['name'] ?? '',
        profileImageUrl: doc['profileImageUrl'] ?? '',
        bannerImageUrl: doc['bannerImageUrl'] ?? '',
        email: doc['email'] ?? '',
      );
    }).toList();

  }


  // fetch data for display at profile page

 UserModel _userFromFirebaseSnapshot(DocumentSnapshot snapshot) {
  if (snapshot.exists) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      uid: snapshot.id,
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
  } else {
    throw Exception('User document does not exist');
  }
}




//-----------------------------------------------------------------------------------------------------
// for display at profile page

Stream<UserModel> getUserInfo(uid){
  return FirebaseFirestore.instance
  .collection("Users")
  .doc(uid).snapshots()
  //.map(_userFromFirebaseSnapshot);
  .map((snapshot) => _userFromFirebaseSnapshot(snapshot));
}


//-----------------------------------------------------------------------------------------------------
// for get user following to display at home page
//  retrieves a list of user IDs that the current logged in user is following:

 Future<List<String>> getUserFollowing(uid) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
    .collection("Users")
    .doc(uid)
    .collection("following")
    .get();
  
  final users = querySnapshot.docs.map((doc) => doc.id).toList();
  return users;
 }


//-----------------------------------------------------------------------------------------------------
// for search 

Stream<List<UserModel>> queryByName(String search) {
  return FirebaseFirestore.instance
      .collection("Users")
        .where('name', isEqualTo: search.toLowerCase())
        .limit(10)
        .snapshots()
        .map((snapshot) => _userListFromQuerySnapshot(snapshot));
}

//---------------------------------------------------------------------------------------------------

Stream<bool> isFollowing(uid, otherId){
  return FirebaseFirestore.instance
  .collection("Users")
  .doc(uid)
  .collection("following")
  .doc(otherId)
  .snapshots()
  .map((snapshot) {
  return snapshot.exists;
  });
}

Future<void> followUser(uid) async {
  await FirebaseFirestore.instance
  .collection("Users")
  .doc(FirebaseAuth.instance.currentUser?.uid)
  .collection("following")
  .doc(uid)
  .set({});

  await FirebaseFirestore.instance
  .collection("Users")
  .doc(uid)
  .collection("followers")
  .doc(FirebaseAuth.instance.currentUser?.uid)
  .set({});

}

Future<void> unfollowUser(uid) async {
  await FirebaseFirestore.instance
  .collection("Users")
  .doc(FirebaseAuth.instance.currentUser?.uid)
  .collection("following")
  .doc(uid)
  .delete();

  await FirebaseFirestore.instance
  .collection("Users")
  .doc(uid)
  .collection("followers")
  .doc(FirebaseAuth.instance.currentUser?.uid)
  .delete();

}


//---------------------------------------------------------------------------------------------------


  // POST IMAGE TO STORAGE AND FIRESTORE

Future<void> updateProfile({
  File? bannerImage,
  File? profileImage,
  String? name,
  String? bio,
  String? birthday,
  String? location,
  String? education,
  String? hobby,
}) async {
  final userCollection = FirebaseFirestore.instance.collection("Users");
  final currentUser = FirebaseAuth.instance.currentUser;

  DocumentSnapshot snapshot = await userCollection.doc(currentUser!.uid).get();
  Map<String, dynamic> existingData = snapshot.data() as Map<String, dynamic>;

  // Pre-populate form fields with existing data if not provided
  name ??= existingData['name'];
  bio ??= existingData['bio'];
  birthday ??= existingData['birthday'];
  location ??= existingData['location'];
  education ??= existingData['education'];
  hobby ??= existingData['hobby'];

  String? bannerImageUrl;
  String? profileImageUrl;

  if (bannerImage != null) {
    bannerImageUrl = await _utilsService.uploadFile(
      bannerImage, 
      'user/profile/${currentUser.uid}/banner',
    );
  }

  if (profileImage != null) {
    profileImageUrl = await _utilsService.uploadFile(
      profileImage, 
      'user/profile/${currentUser.uid}/profile',
    );
  }

  Map<String, dynamic> data = {
    'name': name,
    'bio': bio,
    'birthday': birthday,
    'location': location,
    'education': education,
    'hobby': hobby,
  };

  if (bannerImageUrl != null) data['bannerImageUrl'] = bannerImageUrl;
  if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;

  try {
    DocumentReference userDocRef = userCollection.doc(currentUser.uid);
    await userDocRef.update(data);
    print('Profile updated successfully.');
  } catch (e) {
    print('Error updating profile: $e');
  }
}


  getCurrentUserSnapshot(String uid) {}
}
