import 'package:flutter/material.dart';
import 'package:flutter_application_1/community/post_com_details.dart';
import 'package:flutter_application_1/models/community.dart';
import 'package:flutter_application_1/models/communityPost.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';


class ComPostListByUser extends StatelessWidget {
  final String uid;

  ComPostListByUser({required this.uid});

  final PostService _postService = PostService();
  final UserService _userService = UserService();

 
 Widget _buildImages(BuildContext context, List<String> imageUrls) {
  return Container(
    height: 200, // Adjust the height of the image container as needed
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullImagePage(imageUrl: imageUrls[index]),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrls[index],
                width: MediaQuery.of(context).size.width, // Adjust width to fill the card
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommunityModel>>(
      stream: _postService.getComPostByCreatorId(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<CommunityModel> posts = snapshot.data ?? [];
          print('Number of post retrieved: ${posts.length}');
          print('Events: $posts');

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return StreamBuilder<Community?>(
                stream: _postService.getCommunityById(post.communityId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  Community? community = snapshot.data;

                  if (community == null) {
                    return Text('Community not found.');
                  }

                  return StreamBuilder<UserModel>(
                    stream: _userService.getUserInfo(post.creator),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (userSnapshot.hasError || !userSnapshot.hasData) {
                        return ListTile(
                          title: Text('Error loading user info'),
                          subtitle: Text(post.title),
                        );
                      } else {
                        final user = userSnapshot.data!;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ComPostDetails(communitypost: post, community: community),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Card(
                              elevation: 2.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ProfilePage(user: user),
                                              ),
                                            );
                                          },
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(community.iconImage),
                                            radius: 16,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          community.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text(
                                      post.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  _buildImages(context, post.imageUrls),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}