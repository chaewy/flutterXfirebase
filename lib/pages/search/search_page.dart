import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/search/main_list.dart';
import 'package:flutter_application_1/pages/search/list/list_auto.dart';
import 'package:flutter_application_1/pages/search/list/list_trending_event.dart';
import 'package:flutter_application_1/services/user.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final UserService _userService = UserService();
  late TextEditingController _searchController;
  bool _showMainList = false; // Track whether to show MainList

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(hintText: 'Search...'),
                onChanged: (text) {
                  setState(() {
                    // Perform search logic here based on the input text
                    _showMainList = false; // Reset when text changes
                  });
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  setState(() {
                    _showMainList = true; // Show MainList on icon press
                  });
                } else {
                  // Handle empty search text scenario
                }
              },
            ),
          ],
        ),
        elevation: 0,
      ),
      body: _searchController.text.isNotEmpty
          ? _showMainList
              ? MainList(_searchController.text) // Pass searchText to MainList
              : StreamProvider<List<UserModel>>.value(
                  value: _userService.queryByName(_searchController.text),
                  initialData: [],
                  child: ListUsersAuto(), // Show existing user list
                )
          : Center(
              child: ListTrendingEvent(), // Show trending events when search text is empty
            ),

    );
  }
}
