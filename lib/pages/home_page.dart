import 'package:flutter/material.dart';
import 'package:flutter_application_1/community/add_communityPost.dart';
import 'package:flutter_application_1/community/communitiy.dart';
import 'package:flutter_application_1/home/Chat.dart';
import 'package:flutter_application_1/home/feed.dart';
import 'package:flutter_application_1/pages/search/search_page.dart';
import 'package:flutter_application_1/my_components/drawer.dart';
import 'package:flutter_application_1/pages/events/event_page.dart';
import 'package:flutter_application_1/pages/upcomingEvent/upcoming_event.dart';
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
    Communitiy(),
    EventPage(),
    Chat(),
    UpcomingEvent(),
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
      title: Padding(
        padding: EdgeInsets.only(left: 50), // Adjust left padding as needed
        child: Image.asset(
          'assets/images/logo.png', // Replace with your image path
          width: 130,
          height: 60, // Adjust width as needed
        ),
      ),
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
                    ListTile(
                        leading: Icon(Icons.group),
                        title: Text('Create Community Post'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AddCommunityPostPage()));
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
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: Colors.black,  // Adjust color as needed
      unselectedItemColor: Colors.grey,  // Adjust color as needed
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Upcoming Event',
        ),
      ],
    ),

      body: _children[_currentIndex],
    );
  }
}