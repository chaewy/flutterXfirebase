import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home_page.dart';

import '../pages/profile_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //header
              DrawerHeader(
              child: Icon(
                Icons.favorite,
              ),
        ),

        const SizedBox(height: 25),


        //home titile
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: ListTile(
            leading: Icon(Icons.home),
            title: Text('H O M E'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ),


        //profile
        Padding(
          padding: const EdgeInsets.only(left: 25.0),
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('P R O f I L E'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                  maintainState: true, // Maintain the state of the screen
                ),
              );
            },
          ),
        )

      ],
    ),


        //logout
        Padding(
          padding: const EdgeInsets.only(left: 25.0, bottom: 25),
          child: ListTile(
            leading: Icon(Icons.home),
            title: const Text('L O G OU T'),
            onTap: (){
              //this already home screen so it just pop up the drawer
              Navigator.pop(context);
            },
          ),
        )


      ],),
    );
  }
}