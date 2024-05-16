import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/main_page.dart';
import 'package:flutter_application_1/home/Chat.dart';
import 'package:flutter_application_1/home/feed.dart';
import 'package:flutter_application_1/home/search.dart';
import 'package:flutter_application_1/my_components/drawer.dart';
import 'package:flutter_application_1/pages/post/add_post_page.dart';


///////////////////////////////////////////////// 


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

// for navbar
  int _currentIndex = 0;
  final List<Widget> _children= [Feed(), Search(), Chat()];

  void onTabPressed(int index){
    setState(() {
      _currentIndex = index;
    });
  }


final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        elevation: 0,
        actions: [
          //logout button
          Padding(
            padding: EdgeInsets.only(right: 25), // Padding on the right side
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align button to the right
              children: [
                MaterialButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
                  },
                  color: Colors.yellow,
                  //backgroundColor: Color.fromARGB(255, 255, 244, 93),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Logout'),
                ),
              ],
            ),
          )

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Add()));
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.group),
          //   label: 'group',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.add),
          //   label: 'add',
          // ),
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


