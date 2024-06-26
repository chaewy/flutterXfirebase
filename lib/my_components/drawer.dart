
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/main_page.dart';
import 'package:flutter_application_1/community/add_community.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/my_components/test.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/pages/setting_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/user.dart';

class MyDrawer extends StatelessWidget {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyDrawer({Key? key});

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

              // settings
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(Icons.wb_sunny),
                  title: Text('T H E M E'),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingPage()),
                    );
                  },
                ),
              ),

              //profile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('P R O F I L E'),
                  onTap: () async {
                    Navigator.pop(context); // Close the drawer
                    UserModel currentUser = await _getCurrentUser();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProfilePage(user: currentUser),
                    ));
                  }
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(Icons.group),
                  title: Text('CREATE COMMUNITY'),
                  onTap: () async {
                    Navigator.pop(context); // Close the drawer
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CreateCommunityPage(),
                    ));
                  }
                ),
              ),

            ],
          ),
          //logout
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25),
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: const Text('L O G O U T'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()));
              },
            ),
          )
        ],
      ),
    );
  }

 Future<UserModel> _getCurrentUser() async {
  try {
    // Get the current user's ID from wherever it's stored in your app
    String userId = FirebaseAuth.instance.currentUser!.uid; // Replace this with your actual method to get the user ID

    // Call the getUserInfo method with the user ID to retrieve the user's data
    Stream<UserModel> userDataStream = UserService().getUserInfo(userId);

    // Listen to the user data stream and await the first value
    UserModel currentUser = await userDataStream.first;

    return currentUser;
  } catch (e) {
    print('Error retrieving current user data: $e');
    throw e;
  }
}

}
