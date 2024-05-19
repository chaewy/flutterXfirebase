import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/user.dart';

class FollowStatusWidget extends StatelessWidget {
  final String currentUserId;
  final String profileUserId;
  UserService _userService = UserService();

  FollowStatusWidget({required this.currentUserId, required this.profileUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: UserService().isFollowing(currentUserId, profileUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          bool isFollowing = snapshot.data ?? false;
          return TextButton(
            onPressed: () {
              if (isFollowing) {
                _userService.unfollowUser(profileUserId);
              } else {
                _userService.followUser(profileUserId);
              }
            },
            child: Text(isFollowing ? 'Unfollow' : 'Follow'),
          );
        }
      },
    );
  }
}