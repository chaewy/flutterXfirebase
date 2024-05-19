import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/post/follow_unfollow.dart';
import 'package:flutter_application_1/pages/post/list.dart';
import 'package:flutter_application_1/profile/profile_edit_page.dart';
import 'package:flutter_application_1/services/user.dart';


class ProfilePage extends StatelessWidget {
  final UserModel user;

  ProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // to get current user logged in?
    String? uid = FirebaseAuth.instance.currentUser?.uid; // Define the uid variabl
    UserService _userService = UserService();

    return Scaffold(

//------------------------------------------------------------------------------

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


//------------------------------------------------------------------------------

            return DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverAppBar(
                      floating: false,
                      pinned: true,
                      expandedHeight: 130,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Image.network(
                          userProfile.bannerImageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ];
                },
                body: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                                    // StreamBuilder for following status

                                    if (FirebaseAuth.instance.currentUser!.uid == user.uid)
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => Edit()),
                                          );
                                        },
                                        child: Text('Edit profile'),
                                      ),


                                    if (FirebaseAuth.instance.currentUser?.uid != user.uid)
                                      FollowStatusWidget(
                                        currentUserId: FirebaseAuth.instance.currentUser!.uid,
                                        profileUserId: user.uid,
                                      ),
                                  ]
                              ),




                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(
                                      ' ${userProfile.name}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),


//------------------------------------------------------------------------------


                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return PostListByUser(uid: user.uid);
                          }
                          // Add other items as needed
                          return SizedBox.shrink(); // Placeholder for now
                        },
                        childCount: 2, // Number of items including the PostListByUser widget
                      ),
                    ),

//------------------------------------------------------------------------------

                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}