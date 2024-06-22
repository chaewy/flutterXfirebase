import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // Import Material library for context
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/com_comment.dart';
import 'package:flutter_application_1/models/com_reply.dart';
import 'package:flutter_application_1/models/community.dart';
import 'package:flutter_application_1/models/communityPost.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/home_page.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class CommunityService {
  final CollectionReference _communityCollection =
  FirebaseFirestore.instance.collection('communities');
  final AuthService _authService = AuthService(); // Your AuthService instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  // Add a new community to Firestore
  Future<void> addCommunity(BuildContext context, Community community) async {
    try {
      // Get current user's ID
      String? userId = await _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not logged in.'); // Handle case where user is not logged in
      }

      // Set creatorId in community object
      community.creatorId = userId;

      // Add community to Firestore
      await _communityCollection.doc(community.id).set({
        'name': community.name,
        'description': community.description,
        'createdAt': community.createdAt,
        'creatorId': community.creatorId,
       
      });

      // Navigate to HomePage after successfully adding community
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      // Handle any errors here
      print('Error adding community: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to create community. Please try again.'),
        ),
      );
    }
  }

  // Add a member to a community's members sub-collection
  Future<void> addMemberToCommunity(String communityId, Member member) async {
    await _communityCollection
        .doc(communityId)
        .collection('members')
        .doc(member.userId)
        .set({
      'userId': member.userId,
    });
  }

  // Get community details including members
  Stream<Community> getCommunityDetails(String communityId) {
    return _communityCollection.doc(communityId).snapshots().map(
          (snapshot) => Community.fromFirestore(snapshot),
        );
  }

  // Query communities by name
  Stream<List<Community>> queryCommunitiesByName(String search) {
    return _communityCollection
        .where('name', isGreaterThanOrEqualTo: search)
        .where('name', isLessThanOrEqualTo: search + '\uf8ff')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Community.fromFirestore(doc)).toList());
  }

List<CommunityModel> _communityListFromQuerySnapshot(QuerySnapshot snapshot) {
  return snapshot.docs.map((doc) => CommunityModel.fromDocument(doc)).toList();
}


//------------------------------------------------------------------------------------------------------
//               LIKE 

Stream<bool> getCurrentUserLike(CommunityModel post) {
    return _firestore
        .collection("communities")
        .doc(post.communityId) // Use communityId instead of id
        .collection("posts")
        .doc(post.id)
        .collection("likes")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.exists;
        });
  }

  Future<void> likePost(CommunityModel post, bool current) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final postRef = _firestore
        .collection("communities")
        .doc(post.communityId) // Use communityId instead of id
        .collection("posts")
        .doc(post.id);
    final likeRef = postRef.collection("likes").doc(userId);

    if (current) {
      await likeRef.delete();
    } else {
      await likeRef.set({});
    }

    await updateLikeCount(post);
  }

  Stream<int> getLikeCount(CommunityModel post) {
    return _firestore
        .collection('communities')
        .doc(post.communityId) // Use communityId instead of id
        .collection('posts')
        .doc(post.id)
        .collection('likes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> updateLikeCount(CommunityModel post) async {
    try {
      DocumentReference postRef = _firestore
          .collection('communities')
          .doc(post.communityId) // Use communityId instead of id
          .collection('posts')
          .doc(post.id);

      CollectionReference likesRef = postRef.collection('likes');

      QuerySnapshot snapshot = await likesRef.get();
      int likeCount = snapshot.size;

      // Update the like count in the post document
      await postRef.update({'likeCount': likeCount});
    } catch (e) {
      print('Error updating like count: $e');
      // Handle any errors that may occur during the update process
    }
  }

  //-----------------------------------------------------------------------------------------------------------

   Future<UserModel> getUser(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(userId).get();
      return UserModel.fromDocument(userDoc);
    } catch (e) {
      print('Error fetching user: $e');
      throw Exception('Failed to fetch user data');
    }
  }
//-----------------------------------------------------------------------------------------------------------

  Future<void> editCommunity(Community community) async {
    try {
      await _communityCollection.doc(community.id).update(community.toMap());
    } catch (e) {
      print('Error editing community: $e');
      // Handle error as per your application's requirement
      throw e; // Re-throwing the exception to be handled upstream
    }
  }

    Future<void> deleteCommunity(String communityId) async {
    try {
      // Delete the posts subcollection first
      QuerySnapshot postsQuery = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .get();

      // Delete each document in the posts subcollection
      var batch = _firestore.batch();
      postsQuery.docs.forEach((doc) {
        batch.delete(doc.reference);
      });
      await batch.commit();

      // Then delete the main community document
      await _firestore.collection('communities').doc(communityId).delete();
    } catch (e) {
      throw Exception('Error deleting community: $e');
    }
  }

   Future<void> joinCommunity(String communityId, String userId) async {
    try {
      // Reference to the community document
      DocumentReference communityRef =
          _firestore.collection('communities').doc(communityId);

      // Add user ID to the members subcollection
      await communityRef.collection('members').doc(userId).set({
        'id': userId,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      // Optionally, update community statistics or perform other actions here

      print('User $userId joined community $communityId successfully.');
    } catch (e) {
      print('Error joining community: $e');
      // Handle any errors as needed
    }
  }

    Future<bool> isCommunityMember(String communityId, String userId) async {
    try {
      // Check if the user ID exists in the members subcollection of the community
      DocumentSnapshot communitySnapshot = await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('members')
          .doc(userId)
          .get();

      return communitySnapshot.exists;
    } catch (e) {
      print('Error checking community membership: $e');
      throw Exception('Failed to check community membership');
    }
  }

  Future<void> leaveCommunity(String communityId, String userId) async {
    try {
      // Remove the user from the members subcollection of the community
      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('members')
          .doc(userId)
          .delete();
    } catch (e) {
      print('Error leaving community: $e');
      throw Exception('Failed to leave community');
    }
  }


//-----------------------------------------------------------------------------------------------------------
//                                          C O M M E N T                                                   |
//-----------------------------------------------------------------------------------------------------------


Future<void> comment(Community community, String commentText, CommunityModel communityPost) async {
  try {
    print("Attempting to add comment for post in community: $commentText");
    
    // Get a reference to the new comment document
    DocumentReference commentRef = FirebaseFirestore.instance
        .collection('communities')
        .doc(community.id)
        .collection('posts')
        .doc(communityPost.id)
        .collection('comments')
        .doc();

    // Create the comment data with the generated ID
    Map<String, dynamic> commentData = {
      'id': commentRef.id,
      'post_id': communityPost.id,
      'community_id': community.id,
      'text': commentText,
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Set the comment document with the comment data
    await commentRef.set(commentData);

    print("Comment added successfully");
  } catch (e) {
    print('Error adding comment: ${e.toString()}');
    // Handle error appropriately (display a message to the user)
  }
}

Future<void> deleteComment(Community community, CommunityModel communityPost, String commentId) async {
  try {
    // Reference to the comment document
    DocumentReference commentRef = FirebaseFirestore.instance
        .collection('communities')
        .doc(community.id)
        .collection('posts')
        .doc(communityPost.id)
        .collection('comments')
        .doc(commentId);

    // Delete the comment document
    await commentRef.delete();

    print("Comment deleted successfully");
  } catch (e) {
    print('Error deleting comment: ${e.toString()}');
    // Handle error appropriately (display a message to the user)
  }
}


  // Method to convert Firestore snapshot to list of CommunityCommentModel
    List<CommunityCommentModel> _commentListFromSnapshot(QuerySnapshot snapshot) {
      return snapshot.docs.map((doc) {
        return CommunityCommentModel.fromDocument(doc);
      }).toList();
    }

    Stream<List<CommunityCommentModel>> getCommentsStream(Community community, CommunityModel communityPost) {
    return FirebaseFirestore.instance
        .collection('communities')
        .doc(community.id)
        .collection('posts')
        .doc(communityPost.id)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommunityCommentModel.fromDocument(doc))
            .toList());
  }


    Future<void> replyToComment(String communityId, String postId, String commentId, String replyText) async {
    try {
      print("Attempting to add reply for comment: $replyText");

      // Get a reference to the new reply document
      DocumentReference replyRef = FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc();

      // Create the reply data with the generated ID
      Map<String, dynamic> replyData = {
        'id': replyRef.id,
        'author': FirebaseAuth.instance.currentUser!.uid,
        'text': replyText,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Set the reply document with the reply data
      await replyRef.set(replyData);

      print("Reply added successfully");
    } catch (e) {
      print('Error adding reply: ${e.toString()}');
      // Handle error appropriately (display a message to the user)
    }
  }

  // Method to get replies as a stream of list
  Stream<List<ReplyComCommentModel>> getRepliesStream(String communityId, String postId, String commentId) {
    return FirebaseFirestore.instance
        .collection('communities')
        .doc(communityId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReplyComCommentModel.fromDocument(doc))
            .toList());
  }

  // Method to delete a reply
  Future<void> deleteReply(String communityId, String postId, String commentId, String replyId) async {
    try {
      print("Attempting to delete reply: $replyId");

      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .doc(replyId)
          .delete();

      print("Reply deleted successfully");
    } catch (e) {
      print('Error deleting reply: ${e.toString()}');
      // Handle error appropriately (display a message to the user)
    }
  }























}
