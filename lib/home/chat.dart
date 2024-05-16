import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/my_components/drawer.dart';
import 'package:flutter_application_1/my_components/user_tile.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/services/chat_service.dart';
import 'package:flutter_application_1/services/user.dart';

class Chat extends StatelessWidget {
  Chat({Key? key});

  final ChatService _chatService = ChatService();

  Future<UserModel> _getCurrentUser() async {
    try {
      // Get the current user's ID from FirebaseAuth
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Call the getUserInfo method with the user ID to retrieve the user's data
      Stream<UserModel> userDataStream = UserService().getUserInfo(userId);

      // Listen to the user data stream and await the first value
      UserModel currentUser = await userDataStream.first;

      return currentUser;
    } catch (e) {
      print('Error retrieving current user data: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,

      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return FutureBuilder<UserModel>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error');
        } else {
          UserModel currentUser = snapshot.data!;
          return StreamBuilder(
            stream: _chatService.getUserStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading...");
              } else {
                List<Widget> userList = [];
                for (var userData in snapshot.data as List<dynamic>) {
                  if (userData['email'] != currentUser.email) {
                    userList.add(_buildUserListItem(userData, context));
                  }
                }
                return ListView(children: userList);
              }
            },
          );
        }
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      text: userData["email"],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: userData["email"],
              receiverID: userData["uid"],
            ),
          ),
        );
      },
    );
  }
}
