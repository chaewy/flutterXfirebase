import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/community/editCommunity.dart';
import 'package:flutter_application_1/community/post_com_details.dart';
import 'package:flutter_application_1/loading,dart';
import 'package:flutter_application_1/models/community.dart';
import 'package:flutter_application_1/models/communityPost.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/add_post.dart';
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
  PostService _postService = PostService();
  Map<String, UserModel?> postCreators = {};
  Map<String, ValueNotifier<bool>> likedPosts = {};
  Map<String, ValueNotifier<int>> likeCounts = {};
  ValueNotifier<bool> isMemberNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    likedPosts = {};
    likeCounts = {};
    postCreators = {};
    _checkMembership();
    _fetchInitialData();
  }

  Future<void> _checkMembership() async {
    try {
      bool memberStatus = await widget._communityService.isCommunityMember(widget.community.id, userId);
      isMemberNotifier.value = memberStatus;
    } catch (e) {
      print('Error checking membership status: $e');
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.community.id)
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();

      for (var doc in postsSnapshot.docs) {
        CommunityModel post = CommunityModel.fromDocument(doc);
        bool isLiked = await widget._communityService.getCurrentUserLike(post).first ?? false;
        int likeCount = await widget._communityService.getLikeCount(post).first ?? 0;
        UserModel? creator = await widget._communityService.getUser(post.creator);

        setState(() {
          likedPosts[post.id] = ValueNotifier<bool>(isLiked);
          likeCounts[post.id] = ValueNotifier<int>(likeCount);
          postCreators[post.id] = creator;
        });
      }
    } catch (e) {
      print('Error fetching initial data: $e');
    }
  }

  void _handleJoinLeave() async {
    try {
      if (isMemberNotifier.value) {
        await widget._communityService.leaveCommunity(widget.community.id, userId);
      } else {
        await widget._communityService.joinCommunity(widget.community.id, userId);
      }
      isMemberNotifier.value = !isMemberNotifier.value; // Toggle membership status
    } catch (e) {
      print('Error joining/leaving community: $e');
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
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override

  void dispose() {
    // Dispose ValueNotifiers to prevent memory leaks
    isMemberNotifier.dispose(); // Dispose the ValueNotifier
    likedPosts.forEach((postId, notifier) {
      notifier.dispose();
    });
    likeCounts.forEach((postId, notifier) {
      notifier.dispose();
    });
    super.dispose();
  }
  Widget build(BuildContext context) {
    // Get current logged-in user ID (replace with your actual implementation)
    String currentUserId = userId; // Replace with your actual logic to get current user ID

    // Determine if the current user is the creator of the community
    bool isCreator = widget.community.creatorId == currentUserId;

     bool isMember = isMemberNotifier.value;

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
      body: StreamBuilder<int>(
        stream: _postService.getMemberCountStream(widget.community.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CustomLoadingIndicator(), // Show custom loading indicator
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final memberCount = snapshot.data ?? 0;

          return Padding(
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
                          Text(
                            '$memberCount members',
                            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSecondary),
                          ),
                          Text(
                            widget.community.description,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),

                     ValueListenableBuilder<bool>(
                  valueListenable: isMemberNotifier,
                  builder: (context, isMemberValue, child) {
                    return ElevatedButton(
                      onPressed: _handleJoinLeave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMemberValue ? const Color.fromARGB(255, 255, 255, 255) : Theme.of(context).colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isMemberValue ? 'Leave' : 'Join',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  },
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
        return Center(child: CustomLoadingIndicator()); // Show custom loading indicator
      }

      if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
        return Center(child: Text('No posts found.'));
      }

      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          DocumentSnapshot doc = snapshot.data!.docs[index];
          CommunityModel post = CommunityModel.fromDocument(doc);
          ValueNotifier<bool>? likedNotifier = likedPosts[post.id];

          // Check if the notifier is not null and get the current value
          bool isLiked = likedNotifier?.value ?? false;
          UserModel? creator = postCreators[post.id];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComPostDetails(
                    communitypost: post,
                    community: widget.community,
                  ),
                ),
              );
            },
            child: _buildPostCard(post, isLiked: isLiked, creator: creator),
          );
        },
      );
    },
  ),
),

              ],
            ),
          );
        },
      ),
    );
  }

 Widget _buildPostCard(CommunityModel post, {required bool isLiked, UserModel? creator}) {
  return Card(
    key: Key(post.id),
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
                  backgroundImage: NetworkImage(creator.profileImageUrl), // This line is likely causing the error
                  radius: 16,
                ),
                SizedBox(width: 8),
                Text(
                  creator.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8), // Add spacing between creator info and post content
          ],
          Text(
            post.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Other post content// Display images in a ListView
          SizedBox(height: 10),
          Container(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: post.imageUrls.length,
              itemBuilder: (context, index) {
                String imageUrl = post.imageUrls[index];
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 323,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),









          Row(
  children: [
     SizedBox(width: 20),
    SizedBox(height: 15),
    IconButton(
      icon: ValueListenableBuilder<bool>(
        valueListenable: likedPosts[post.id] ?? ValueNotifier<bool>(false),
        builder: (context, isLiked, _) {
          return Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.grey,
          );
        },
      ),
      onPressed: () {
        _handleLikeUnlike(post, likedPosts[post.id]!.value); // Pass current like status
      },
    ),
    ValueListenableBuilder<int>(
      valueListenable: likeCounts[post.id] ?? ValueNotifier<int>(0),
      builder: (context, likeCount, _) {
        return Text(
          '$likeCount Likes',
          style: TextStyle(fontSize: 12),
        );
      },
    ),
    SizedBox(width: 90), // Adjust the spacing between like icon and message icon
    IconButton(
      icon: Icon(Icons.message),
      onPressed: () {
        // Handle message icon onPressed event
        // Example: Navigate to message screen or show a message dialog
      },
    ),
  ],
),

        ],
      ),
    ),
  );
}




 void _handleLikeUnlike(CommunityModel post, bool isCurrentlyLiked) async {
  try {
    // Toggle like status
    await widget._communityService.likePost(post, !isCurrentlyLiked);

    // Immediately update ValueNotifier
    likedPosts[post.id]!.value = !isCurrentlyLiked;

    // Fetch and update like count
    int newLikeCount = await widget._communityService.getLikeCount(post).first;
    likeCounts[post.id]!.value = newLikeCount;
  } catch (e) {
    print('Error liking/unliking post: $e');
  }
}





}


