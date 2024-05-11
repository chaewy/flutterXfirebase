import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/main_page.dart';
import 'package:flutter_application_1/my_components/drawer.dart';
import 'package:flutter_application_1/pages/post/add_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

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
      
    );
  }
}


