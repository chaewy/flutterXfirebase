import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_api.dart';
import 'package:flutter_application_1/my_components/chat_bubble.dart';
import 'package:flutter_application_1/services/chat_service.dart';

class EventChatPage extends StatefulWidget {
  final String eventID;
  final String eventName;

  EventChatPage({
    Key? key,
    required this.eventID,
    required this.eventName,
  }) : super(key: key);

  @override
  _EventChatPageState createState() => _EventChatPageState();
}

class _EventChatPageState extends State<EventChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

// ------------------------------------------------------------------------------------------------------------------------
   // Function to send messages
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendEventMessage(widget.eventID, _messageController.text);

      // Fetch participants of the event
      try {
        final participantsSnapshot = await FirebaseFirestore.instance
            .collection('event')
            .doc(widget.eventID)
            .collection('participants')
            .get();

        final participants = participantsSnapshot.docs;

        // Send notification to each participant
        for (var participant in participants) {
          String participantID = participant.id;
          if (participantID != _currentUser!.uid) {
            sendNotification(participantID, _messageController.text);
          }
        }

        _messageController.clear();
      } catch (e) {
        print('Error sending message or fetching participants: $e');
      }
    }
  }

  // Function to send notification to a participant
  Future<void> sendNotification(String receiverID, String message) async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    final Map<String, dynamic> data = {
      'senderId': FirebaseAuth.instance.currentUser!.uid,
      'senderName': _currentUser?.displayName ?? 'Unknown',
      'message': message,
      'type': 'event_chat', // Add type to distinguish notification type
      'notificationId': DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID for each notification
    };

    // Convert data map to Map<String, String>
    Map<String, String> stringData = data.map((key, value) => MapEntry(key, value.toString()));

    try {
      await _firebaseMessaging.sendMessage(
        to: receiverID,
        data: stringData,
      );
      print('Notification sent successfully to receiver with ID: $receiverID');
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

// ------------------------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.eventName),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildUserInput(),
        ],
      ),
    );
  }

  // Builds the message list using a StreamBuilder
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getEventMessages(widget.eventID),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // Builds each message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    bool isCurrentUser = data['senderID'] == _currentUser!.uid;
    var alignment = isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    // Use senderEmail instead of senderName for clarity
    String senderEmail = data['senderEmail'] ?? "Unknown";

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            senderEmail,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        ChatBubble(
          message: data["message"],
          isCurrentUser: isCurrentUser,
        ),
      ],
    );
  }

  // Builds the user input area
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(
                Icons.send,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
