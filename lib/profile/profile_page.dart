
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/post/list.dart';
import 'package:flutter_application_1/profile/profile_edit_page.dart';
import 'package:flutter_application_1/provider.dart';
import 'package:flutter_application_1/services/user.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final UserModel user;

  ProfilePage({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                                  ],
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
                    // Display user posts using PostProvider
                    Consumer<PostProvider>(
                      builder: (context, postProvider, _) {
                        postProvider.fetchUserPosts(user.uid); // Fetch user posts using PostProvider
                        List<PostModel> userPosts = postProvider.postList;

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              if (index < userPosts.length) {
                                return ListPost(); // Pass each post to ListPost widget
                              }
                              return SizedBox(); // Return a sized box for empty space
                            },
                            childCount: userPosts.length,
                          ),
                        );
                      },
                    ),
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