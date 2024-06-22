import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/user.dart';

class ParticipantsPage extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final UserService _userService = UserService();

  ParticipantsPage({required this.participants});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participants'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: participants.length,
        itemBuilder: (context, index) {
          final participant = participants[index];
          return FutureBuilder<UserModel>(
            future: _userService.getUserInfo(participant['userId']).first,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Card(
                  child: ListTile(
                    title: Text('Loading...'),
                  ),
                );
              } else if (snapshot.hasError) {
                return Card(
                  child: ListTile(
                    title: Text('Error: ${snapshot.error}'),
                  ),
                );
              } else if (!snapshot.hasData) {
                return Card(
                  child: ListTile(
                    title: Text('User not found'),
                  ),
                );
              } else {
                final user = snapshot.data!;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                  child: ListTile(
                    leading: user.profileImageUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user.profileImageUrl!),
                          )
                        : CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: Text(user.name ?? 'No Name'),
                    subtitle: Text(user.gender ?? 'No Location'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(user: user),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}