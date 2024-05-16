import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/profile/list.dart';
import 'package:flutter_application_1/services/user.dart';
import 'package:provider/provider.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  UserService _userService = UserService();
  String search = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: TextField(
            onChanged: (text) {
              setState(() {
                search = text;
              });
            },
            decoration: InputDecoration(hintText: 'Search..'),
          ),
        ),
        StreamProvider<List<UserModel>>.value(
          value: _userService.queryByName(search),
          initialData: [],
          child: Expanded(
            child: ListUsers(),
          ),
        ),
      ],
    );
  }
}
