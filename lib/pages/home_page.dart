import 'package:flutter/material.dart';
import 'package:flutter_application_1/home/Chat.dart';
import 'package:flutter_application_1/home/feed.dart';
import 'package:flutter_application_1/pages/search/search_page.dart';
import 'package:flutter_application_1/my_components/drawer.dart';
import 'package:flutter_application_1/pages/events/event_page.dart';
import 'package:flutter_application_1/pages/notification/noty.dart';
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
    Chat(),
    NotificationPage(),
  ];

  void onTabPressed(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Color getIconColor(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hobby App'),
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
                  },
                  color: getIconColor(context),
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
            icon: Icon(Icons.home, color: getIconColor(context)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, color: getIconColor(context)),
            label: 'Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, color: getIconColor(context)),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: getIconColor(context)),
            label: 'Notification',
          ),
        ],
      ),
      body: _children[_currentIndex],
    );
  }
}