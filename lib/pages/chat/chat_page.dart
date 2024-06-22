import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:flutter_application_1/my_components/chat_bubble.dart';
import 'package:flutter_application_1/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverName;
  final String receiverID;

  ChatPage({
    Key? key,
    required this.receiverName,
    required this.receiverID,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Get current user
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessages(widget.receiverID, _messageController.text);

      // Send notification to the receiver
      sendNotification(widget.receiverID, _messageController.text);

      _messageController.clear();
    }
  }

  Future<void> _sendImage() async {
    try {
      await _chatService.pickImage(widget.receiverID);
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _sendFile() async {
    try {
      await _chatService.pickFile(widget.receiverID);
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> sendNotification(String receiverID, String message) async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

    final Map<String, dynamic> data = {
      'senderId': FirebaseAuth.instance.currentUser!.uid,
      'senderName': _currentUser?.displayName ?? 'Unknown',
      'message': message,
      'type': 'personal_chat', // Add type to distinguish notification type
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.receiverName),
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

  Widget _buildMessageList() {
  String senderID = _currentUser != null ? _currentUser!.uid : '';

  return StreamBuilder(
    stream: _chatService.getMessages(widget.receiverID, senderID),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      return ListView(
        reverse: true,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        children: snapshot.data!.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          bool isCurrentUser = data['senderID'] == _currentUser!.uid;

          // Determine if the message has imageUrl or fileUrl
          bool hasImage = data.containsKey('imageUrl') && data['imageUrl'] != null;
          bool hasFile = data.containsKey('fileUrl') && data['fileUrl'] != null;

          return Column(
            crossAxisAlignment:
                isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (hasImage)
                Container(
                  width: 200, // Adjust width as needed
                  child: Image.network(data['imageUrl']),
                ),
              if (hasFile)
                InkWell(
                  onTap: () {
                    // Handle file tap action (open or view the file)
                    // Example: openUrlInBrowser(data['fileUrl']);
                    print('Opening file: ${data['fileUrl']}');
                  },
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_file),
                          SizedBox(width: 10),
                          Text(
                            'File: ${data['fileName']}', // Assuming you have 'fileName' in Firestore
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ChatBubble(
                message: data['message'],
                isCurrentUser: isCurrentUser,
                imageUrl: hasImage ? data['imageUrl'] : null,
                fileUrl: hasFile ? data['fileUrl'] : null,
              ),
            ],
          );
        }).toList(),
      );
    },
  );
}


  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sendImage,
                    icon: Icon(Icons.image),
                    color: Colors.blue,
                  ),
                  IconButton(
                    onPressed: _sendFile,
                    icon: Icon(Icons.attach_file),
                    color: Colors.blue,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Type a message...',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            color: Colors.blue,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
