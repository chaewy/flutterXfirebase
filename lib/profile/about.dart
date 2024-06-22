import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/user.dart';


class AboutPage extends StatelessWidget {
  final String uid;
  final UserService _userService = UserService();

  AboutPage({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<UserModel>(
        stream: _userService.getUserInfo(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Name'),
                _buildInfoText(user.name),
                SizedBox(height: 10),

                _buildSectionTitle('Bio'),
                _buildInfoText(user.bio),
                SizedBox(height: 10),

                _buildSectionTitle('Birthday'),
                _buildInfoText(user.birthday),
                SizedBox(height: 10),

                _buildSectionTitle('Gender'),
                _buildInfoText(user.gender),

                SizedBox(height: 16.0),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.0,
      ),
    );
  }
}
