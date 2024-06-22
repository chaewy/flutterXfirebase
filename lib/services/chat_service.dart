import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_api.dart';
import 'package:flutter_application_1/models/message.dart';
import 'package:flutter_application_1/pages/chat/chat_page.dart';
import 'package:image_picker/image_picker.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseApi _firebaseApi = FirebaseApi();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final ImagePicker _picker = ImagePicker();


  // retrieves a stream of user documents from the "Users" collection 
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = {
          'id': doc.id,
          ...doc.data(),
        };
        return user;
      }).toList();
    });
  }

  //  builds a list item widget for each user, displaying their email. 
  //  When a user is tapped, it navigates to the chat page with the selected user.
  Widget buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    return ListTile(
      title: Text(userData["name"]),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverName: userData["name"],
              receiverID: userData["uid"],
            ),
          ),
        );
      },
    );
  }

// ------------------------------------------------------------------------------------------------------------------------
//                                      PERSONAL MESSAGE
// ------------------------------------------------------------------------------------------------------------------------

    // Method to pick an image
  Future<void> pickImage(String receiverID) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String imageUrl = await _uploadFileToFirebase(File(pickedFile.path));
      await sendMessages(receiverID, '', imageUrl: imageUrl);
    }
  }

  // Method to pick a file
  Future<void> pickFile(String receiverID) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileUrl = await _uploadFileToFirebase(file);
      await sendMessages(receiverID, '', fileUrl: fileUrl);
    }
  }

  // Method to upload file to Firebase Storage
  Future<String> _uploadFileToFirebase(File file) async {
    String fileName = file.uri.pathSegments.last;
    Reference ref = _storage.ref().child('uploads').child(fileName);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }

  // Modified sendMessages method
  Future<void> sendMessages(String receiverID, String message, {String? imageUrl, String? fileUrl}) async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print("User not logged in");
      return;
    }

    final String currentUserID = currentUser.uid;
    final String currentEmail = currentUser.email ?? '';
    final Timestamp timestamp = Timestamp.now();

    // Create message map
    Map<String, dynamic> newMessage = {
      'senderID': currentUserID,
      'senderEmail': currentEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
    };

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage);

    // Send notification to the receiver
    _firebaseApi.sendMessage(currentUserID, receiverID, message, 'personal_chat');
  }

    Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

// ------------------------------------------------------------------------------------------------------------------------
//
// ------------------------------------------------------------------------------------------------------------------------

  Future<void> sendEventMessage(String eventID, String message) async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print("User not logged in");
      return;
    }

    final String currentUserID = currentUser.uid;
    final String currentEmail = currentUser.email ?? '';
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentEmail,
      message: message,
      receiverID: null, // Set receiverID to null for event messages
      timestamp: timestamp,
    );

    // Step 1: Save the message to the event's messages collection
    try {
      await _firestore
          .collection("event")
          .doc(eventID)
          .collection("messages")
          .add(newMessage.toMap());
    } catch (e) {
      print('Error saving event message: $e');
      return;
    }

    // Step 2: Retrieve participants of the event
    try {
      QuerySnapshot eventParticipantsSnapshot = await _firestore
          .collection('event')
          .doc(eventID)
          .collection('participants')
          .get();

      // Step 3: Send notification to each participant
      for (var participantDoc in eventParticipantsSnapshot.docs) {
        String userID = participantDoc.id;
        if (userID != currentUserID) {
          _firebaseApi.sendEventMessage(currentUserID, eventID, message);
        }
      }
    } catch (e) {
      print('Error sending notifications to event participants: $e');
    }
  }


  Stream<QuerySnapshot> getEventMessages(String eventID) {
    return _firestore
        .collection("event")
        .doc(eventID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
