import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/utils.dart';


class UserService {

  UtilsService _utilsService = UtilsService();

  String? uid = FirebaseAuth.instance.currentUser?.uid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _userListFromQuerySnapshot(QuerySnapshot snapshot){
    return snapshot.docs.map((doc){
      return UserModel(
        uid: doc.id,
        name: doc['name'] ?? '',
        profileImageUrl: doc['profileImageUrl'] ?? '',
        bannerImageUrl: doc['bannerImageUrl'] ?? '',
        email: doc['email'] ?? '',
        gender: doc['gender'] ?? '',
        streetName: doc['streetName'] ?? '',
        town: doc['town'] ?? '',
        region: doc['region'] ?? '',
        state: doc['state'] ?? '',

  //         String streetName;
  // String town;
  // String region;
  // String state;
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
      gender: data['gender'] ?? '',
      streetName: data['streetName'] ?? '',
      town: data['town'] ?? '',
      region: data['region'] ?? '',
      state: data['state'] ?? '',
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
      .where('name', isGreaterThanOrEqualTo: search)
      .where('name', isLessThanOrEqualTo: search + '\uf8ff')
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
  String? gender,
  String? streetName,
  String? town,
  String? region,
  String? state,

  // streetName town region state
}) async {
  final userCollection = FirebaseFirestore.instance.collection("Users");
  final currentUser = FirebaseAuth.instance.currentUser;

  DocumentSnapshot snapshot = await userCollection.doc(currentUser!.uid).get();
  Map<String, dynamic> existingData = snapshot.data() as Map<String, dynamic>;

  // Pre-populate form fields with existing data if not provided
  name ??= existingData['name'];
  bio ??= existingData['bio'];
  birthday ??= existingData['birthday'];
  gender ??= existingData['gender'];
  streetName ??= existingData['streetName'];
  town ??= existingData['town'];
  region ??= existingData['region'];
  state ??= existingData['state'];

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
    'gender': gender,
    'streetName': streetName,
    'town': town,
    'region': region,
    'state': state,


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


  // ------------------------------------------------------------------
  Future<List<UserModel>> getEventParticipants(String eventId) async {
    List<UserModel> participants = [];

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('event')
          .doc(eventId)
          .collection('participants')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (DocumentSnapshot doc in querySnapshot.docs) {
          DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
              .collection('Users')
              .doc(doc.id)
              .get();

          if (userDoc.exists) {
            participants.add(UserModel.fromDocument(userDoc));
          }
        }
      }

      return participants;
    } catch (e) {
      // Handle any potential errors
      print('Error fetching event participants: $e');
      return [];
    }
  }
}
