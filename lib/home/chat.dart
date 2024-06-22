import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/my_components/user_tile.dart';
import 'package:flutter_application_1/pages/chat/chat_page.dart';
import 'package:flutter_application_1/pages/chat/event_chat_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/chat_service.dart';
import 'package:flutter_application_1/services/user.dart';

class Chat extends StatelessWidget {
  Chat({Key? key}) : super(key: key);

  final ChatService _chatService = ChatService();
  final PostService _postService = PostService();
  
  Future<UserModel> _getCurrentUser() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      Stream<UserModel> userDataStream = UserService().getUserInfo(userId);
      UserModel currentUser = await userDataStream.first;
      return currentUser;
    } catch (e) {
      print('Error retrieving current user data: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.primary,
              child: SafeArea(
                child: Column(
                  children: [
                    TabBar(
                      indicatorColor: Colors.white,
                      // indicatorSize: TabBarIndicatorSize.label, // Set indicator size to label
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      tabs: [
                        Tab(text: "Direct Message"),
                        Tab(text: "Event Chat"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDirectMessageList(),
                  _buildEventChat(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectMessageList() {
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
                List<Widget> userList = (snapshot.data as List<dynamic>)
                    .where((userData) => userData['email'] != currentUser.email)
                    .map((userData) => _buildUserListItem(userData, context))
                    .toList();
                return ListView(children: userList);
              }
            },
          );
        }
      },
    );
  }

  Widget _buildEventChat(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error retrieving user ID: ${snapshot.error}'));
        }

        final String userId = snapshot.data!.uid;

        return StreamBuilder<List<EventModel>>(
          stream: _postService.getEventList(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error fetching events: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            List<EventModel> events = snapshot.data ?? [];

            // Filter events asynchronously based on whether the user is a participant
            return FutureBuilder<List<EventModel>>(
              future: _filterEvents(events, userId),
              builder: (context, filteredSnapshot) {
                if (filteredSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<EventModel> filteredEvents = filteredSnapshot.data ?? [];

                if (filteredEvents.isEmpty) {
                  return const Center(child: Text('No events found for this user.'));
                }

                return ListView.builder(
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    EventModel event = filteredEvents[index];
                    return ListTile(
                      title: Text(event.title),
                      subtitle: Text(event.description),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventChatPage(
                              eventID: event.id,
                              eventName: event.title,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<EventModel>> _filterEvents(List<EventModel> events, String userId) async {
    List<EventModel> filteredEvents = [];
    for (var event in events) {
      bool isParticipant = await _isUserParticipant(event, userId);
      if (isParticipant) {
        filteredEvents.add(event);
      }
    }
    return filteredEvents;
  }

  Future<bool> _isUserParticipant(EventModel event, String userId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('event')
        .doc(event.id)
        .collection('participants')
        .doc(userId)
        .get();
    
    return doc.exists;
  }

  Widget _buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      text: userData["name"],
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
}
