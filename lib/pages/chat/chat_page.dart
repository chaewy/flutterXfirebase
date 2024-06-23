import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      List<DocumentSnapshot> reversedMessages = snapshot.data!.docs.reversed.toList();

      return ListView.builder(
        reverse: true, // Reverse to show new messages at the bottom
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        itemCount: reversedMessages.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> data = reversedMessages[index].data() as Map<String, dynamic>;
          bool isCurrentUser = data['senderID'] == _currentUser!.uid;

          // Determine if the message has imageUrl or fileUrl
          bool hasImage = data.containsKey('imageUrl') && data['imageUrl'] != null;
          bool hasFile = data.containsKey('fileUrl') && data['fileUrl'] != null;

          return Column(
            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (hasImage && !hasFile) // Display image if it exists and there's no file
                Container(
                  width: 200, // Adjust width as needed
                  child: Image.network(data['imageUrl']),
                ),
              if (hasFile) // Display file if it exists
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
              if (!hasImage && !hasFile) // Display text message if no image or file
                ChatBubble(
                  message: data['message'],
                  isCurrentUser: isCurrentUser,
                ),
            ],
          );
        },
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
