import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/search/list/list_user.dart';
import 'package:flutter_application_1/pages/search/list/list_post.dart';
import 'package:flutter_application_1/pages/search/list/list_event.dart';

class MainList extends StatefulWidget {
  final String searchText;

  MainList(this.searchText);

  @override
  _MainListState createState() => _MainListState();
}

class _MainListState extends State<MainList> {
  int _selectedIndex = 0; // 0 for Users, 1 for Posts, 2 for Events

  @override
  Widget build(BuildContext context) {
    Widget listWidget;

    switch (_selectedIndex) {
      case 0:
        listWidget = ListUser(widget.searchText);
        break;
      case 1:
        listWidget = ListPosts(widget.searchText);
        break;
      case 2:
        listWidget = ListEvents(widget.searchText);
        break;
      default:
        listWidget = ListUser(widget.searchText); // Default to Users
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upper navigation bar
          Container(
            color: Color.fromARGB(255, 245, 168, 35),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0; // Switch to Users
                    });
                  },
                  child: Text(
                    'Users',
                    style: TextStyle(
                      color: _selectedIndex == 0 ? Colors.white : Colors.white54,
                      fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1; // Switch to Posts
                    });
                  },
                  child: Text(
                    'Posts',
                    style: TextStyle(
                      color: _selectedIndex == 1 ? Colors.white : Colors.white54,
                      fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2; // Switch to Events
                    });
                  },
                  child: Text(
                    'Events',
                    style: TextStyle(
                      color: _selectedIndex == 2 ? Colors.white : Colors.white54,
                      fontWeight: _selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Display selected list widget
          Expanded(
            child: listWidget,
          ),
        ],
      ),
    );
  }
}
