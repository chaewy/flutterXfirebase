import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/community/editCommunity.dart';
import 'package:flutter_application_1/community/post_com_details.dart';
import 'package:flutter_application_1/models/community.dart';
import 'package:flutter_application_1/models/communityPost.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/community_service.dart';

class CommunityPage extends StatefulWidget {
  final Community community;
  final CommunityService _communityService = CommunityService();

  CommunityPage({Key? key, required this.community}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  bool isMember = false;

  @override
  void initState() {
    super.initState();
    _checkMembership();
  }

  Future<void> _checkMembership() async {
    try {
      bool memberStatus = await widget._communityService.isCommunityMember(widget.community.id, userId);
      setState(() {
        isMember = memberStatus;
      });
    } catch (e) {
      print('Error checking membership status: $e');
      // Handle error as needed
    }
  }

  void _handleJoinLeave() async {
    try {
      if (isMember) {
        await widget._communityService.leaveCommunity(widget.community.id, userId);
      } else {
        await widget._communityService.joinCommunity(widget.community.id, userId);
      }
      // Toggle membership status after successful join/leave
      setState(() {
        isMember = !isMember;
      });
    } catch (e) {
      print('Error joining/leaving community: $e');
      // Handle error as needed
    }
  }

  Stream<QuerySnapshot> _getCommunityPosts() {
    return FirebaseFirestore.instance
        .collection('communities')
        .doc(widget.community.id)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _handleMenuSelection(BuildContext context, String choice) {
    switch (choice) {
      case 'Edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCommunityPage(communityId: widget.community.id),
          ),
        );
        break;
      case 'Delete':
        _showConfirmationDialog(context);
        break;
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this community?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                try {
                  await widget._communityService.deleteCommunity(widget.community.id);
                  Navigator.of(context).pop(); // Navigate back after deletion
                } catch (e) {
                  print('Error deleting community: $e');
                  // Handle error as needed
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current logged-in user ID (replace with your actual implementation)
    String currentUserId = userId; // Replace with your actual logic to get current user ID

    // Determine if the current user is the creator of the community
    bool isCreator = widget.community.creatorId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.community.name),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.community.bannerImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        actions: [
          if (isCreator) // Show the menu button only if the current user is the creator
            PopupMenuButton<String>(
              onSelected: (choice) => _handleMenuSelection(context, choice),
              itemBuilder: (BuildContext context) {
                return {'Edit', 'Delete'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Image.network(
                    widget.community.iconImage,
                    width: 40, // Adjust the size here
                    height: 40, // Adjust the size here
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.community.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.community.description,
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _handleJoinLeave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMember ? Colors.red : Color.fromARGB(255, 255, 204, 0),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isMember ? 'Leave' : 'Join',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getCommunityPosts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No posts found.'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      CommunityModel post = CommunityModel.fromDocument(doc);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ComPostDetails(communitypost: post, community: widget.community),
                            ),
                          );
                        },
                        child: _buildPostListItem(post),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostListItem(CommunityModel post) {
    return StreamBuilder<bool>(
      key: Key(post.id), // Unique key for the StreamBuilder
      stream: widget._communityService.getCurrentUserLike(post),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildPostCard(post, isLiked: false, creator: null); // Show loading state
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        bool isLiked = snapshot.data ?? false;

        return FutureBuilder<UserModel>(
          key: Key('${post.id}_user'), // Unique key for the FutureBuilder
          future: widget._communityService.getUser(post.creator),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return _buildPostCard(post, isLiked: isLiked, creator: null); // Show loading state
            }

            if (userSnapshot.hasError) {
              return Center(child: Text('Error fetching user data'));
            }

            UserModel? creator = userSnapshot.data;

            return _buildPostCard(post, isLiked: isLiked, creator: creator);
          },
        );
      },
    );
  }

  Widget _buildPostCard(CommunityModel post, {required bool isLiked, UserModel? creator}) {
    return Card(
      key: Key(post.id), // Unique key for the Card
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (creator != null) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(creator.profileImageUrl),
                    backgroundColor: Colors.grey[200],
                  ),
                  SizedBox(width: 8),
                  Text(
                    creator.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
            Text(
              post.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            if (post.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: post.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      post.imageUrls[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            SizedBox(height: 4),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    _handleLikeUnlike(post, isLiked);
                  },
                ),
                StreamBuilder<int>(
                  stream: widget._communityService.getLikeCount(post),
                  builder: (context, snapshot) {
                    int likeCount = snapshot.data ?? 0;
                    return Text(
                      '$likeCount Likes',
                      style: TextStyle(fontSize: 12),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleLikeUnlike(CommunityModel post, bool isLiked) async {
    try {
      await widget._communityService.likePost(post, isLiked);
    } catch (e) {
      print('Error liking/unliking post: $e');
      // Handle error as needed
    }
  }
}
