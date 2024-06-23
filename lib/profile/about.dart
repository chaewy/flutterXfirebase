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

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  _buildSectionCard(
                    icon: Icons.person,
                    title: 'Name',
                    content: user.name,
                  ),
                  SizedBox(height: 10),
                  _buildSectionCard(
                    icon: Icons.info,
                    title: 'Bio',
                    content: user.bio,
                  ),
                  SizedBox(height: 10),
                  _buildSectionCard(
                    icon: Icons.cake,
                    title: 'Birthday',
                    content: user.birthday,
                  ),
                  SizedBox(height: 10),
                  _buildSectionCard(
                    icon: Icons.transgender,
                    title: 'Gender',
                    content: user.gender,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  user.bio,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: const Color.fromARGB(255, 245, 168, 35),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
