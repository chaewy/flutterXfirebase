import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_api.dart';
import 'package:flutter_application_1/models/message.dart';
import 'package:flutter_application_1/pages/chat/chat_page.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseApi _firebaseApi = FirebaseApi();

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
      title: Text(userData["email"]),
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

   Future<void> sendMessages(String receiverID, String message) async {
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
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // Send notification to the receiver
    _firebaseApi.sendMessage(currentUserID, receiverID, message, 'personal_chat');
  }

  

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

// ------------------------------------------------------------------------------------------------------------------------

  // Retrieves a stream of messages between two users from the messages subcollection ordered by timestamp.
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

  Stream<QuerySnapshot> getEventMessages(String eventID) {
    return _firestore
        .collection("event")
        .doc(eventID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
