import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/main_page.dart';
import 'package:flutter_application_1/home/Chat.dart';
import 'package:flutter_application_1/home/feed.dart';
import 'package:flutter_application_1/home/search.dart';
import 'package:flutter_application_1/my_components/drawer.dart';
import 'package:flutter_application_1/pages/events/addEvent_page.dart';
import 'package:flutter_application_1/pages/events/event_page.dart';
import 'package:flutter_application_1/pages/post/add_post.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    Feed(),
    EventPage(),
    Search(),
    Chat(),
  ];

  void onTabPressed(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
                  },
                  color: Colors.yellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.post_add),
                      title: Text('Create Post'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Add(isEvent: false)));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.event),
                      title: Text('Create Event Post'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Add(isEvent: true)));
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      drawer: MyDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabPressed,
        currentIndex: _currentIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chat',
          ),
        ],
      ),
      body: _children[_currentIndex],
    );
  }
}
