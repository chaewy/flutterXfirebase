

// display to user to search function use fetched data kut from list 

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:provider/provider.dart';

class ListUsersAuto extends StatefulWidget {
  const ListUsersAuto({Key? key});

  @override
  _ListUsersState createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsersAuto> {
  @override
  Widget build(BuildContext context) {

    
    final users = Provider.of<List<UserModel>>(context) ?? [];

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(user: user),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    user.profileImageUrl != ''
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(user.profileImageUrl),
                          )
                        : Icon(Icons.person, size: 40),
                    SizedBox(width: 10),
                    Text(user.name),
                  ],
                ),
              ),
              const Divider(thickness: 1),
            ],
          ),
        );
      },
    );
  }
}