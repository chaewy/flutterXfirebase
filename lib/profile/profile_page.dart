import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/chat/chat_page.dart';
import 'package:flutter_application_1/pages/post/follow_unfollow.dart';
import 'package:flutter_application_1/profile/about.dart';
import 'package:flutter_application_1/profile/list.dart';
import 'package:flutter_application_1/profile/list_com_post.dart';
import 'package:flutter_application_1/profile/list_event.dart';
import 'package:flutter_application_1/profile/profile_edit_page.dart';
import 'package:flutter_application_1/services/user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;

  ProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
    UserService _userService = UserService();

    print('Current User ID: $currentUserId');
    print('Profile User ID: ${user.uid}');

    return Scaffold(
      body: StreamBuilder<UserModel>(
        stream: UserService().getUserInfo(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            UserModel? userProfile = snapshot.data;
            if (userProfile == null) {
              return Center(child: Text('User data is null'));
            }

            print('User Profile: ${userProfile.name}');

            return DefaultTabController(
              length: 4, // Number of tabs
              child: NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverAppBar(
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      floating: false,
                      pinned: true,
                      expandedHeight: 80,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.network(
                          userProfile.bannerImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ];
                },
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: NetworkImage(userProfile.profileImageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        height: 60,
                                        width: 60,
                                      ),
                                      SizedBox(width: 20),

                                      Container(
                                        height: 40,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20), // Adjust the value to change the oval shape
  ),
  child: TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            receiverName: userProfile.name,
            receiverID: userProfile.uid,
          ),
        ),
      );
    },
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 255, 187, 0)), // Make button transparent
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Same value as Container's borderRadius
        ),
      ),
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 14.0),
      child: Text(
        'Chat',
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255), // Text color
          fontWeight: FontWeight.bold, // Make the text bold
          fontSize: 14, // Optional: Adjust font size if needed
        ),
      ),
    ),
  ),
),



                                    ],
                                  ),
                                  if (currentUserId == user.uid)
                                    Padding(
                                      padding: EdgeInsets.only(right: 20),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.secondary,
                                          side: BorderSide(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => Edit()),
                                          );
                                        },
                                        child: Text('Edit profile'),
                                      ),
                                    ),
                                  if (currentUserId != user.uid)
                                    FollowStatusWidget(
                                      currentUserId: currentUserId!,
                                      profileUserId: user.uid,
                                    ),
                                ],
                              ),
                            ),
                            Align(
                              child: Container(
                                padding: EdgeInsets.only(left: 20),
                                child: Row(
                                  children: [
                                    SizedBox(height: 50),
                                    Text(
                                      userProfile.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Row(
                                children: [
                                  Icon(Icons.location_on),
                                  SizedBox(width: 5),
                                  Text(
                                    userProfile.region,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    userProfile.state,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 40),
                                  Icon(
                                    FontAwesomeIcons.cake,
                                    size: 18.0,
                                    color: Theme.of(context).colorScheme.onSecondary,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    userProfile.birthday,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            Container(
                              color: Theme.of(context).colorScheme.secondary,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    color: Colors.orange,
                                    child: TabBar(
                                      labelColor: Colors.white,
                                      unselectedLabelColor: Colors.black,
                                      tabs: [
                                        Tab(text: 'Post'),
                                        Tab(text: 'Event'),
                                        Tab(text: 'Community'),
                                        Tab(text: 'About'),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: TabBarView(
                                      children: [
                                        PostListByUser(uid: user.uid),
                                        EventListByUser(uid: user.uid),
                                        ComPostListByUser(uid: user.uid),
                                        AboutPage(uid: user.uid),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
