

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/comment.dart';
import 'package:flutter_application_1/models/community.dart';
import 'package:flutter_application_1/models/communityPost.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/reply.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/auth_service.dart';

// FOR ADD POST

class PostService with ChangeNotifier{

  List<PostModel> _posts = []; // Internal list of posts

  List<PostModel> get posts => _posts; // Getter for accessing the posts

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance; // Add this line

  String userId = FirebaseAuth.instance.currentUser!.uid;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService _authService = AuthService(); // Instance of AuthService

List<PostModel> _postListFromSnapshot(QuerySnapshot snapshot) {
  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic>
    if (data != null) {
      // Parse imageUrls as List<String>
      List<String> imageUrls = (data['imageUrls'] as List<dynamic>).cast<String>();
      
      return PostModel(
        id: doc.id,
        creator: data['creator'] ?? '',
        title: data['title'] ?? '',
        imageUrls: imageUrls, // Assign parsed list of strings to imageUrls
        description: data['description'] ?? '',
        timestamp: data['timestamp'] != null ? data['timestamp'] : Timestamp.now(),
        ref: doc.reference,
      );
    } else {
      // Handle the case where data is null
      // You might want to throw an error, return a default value, or handle it based on your application logic.
      return PostModel(
        id: doc.id,
        creator: '',
        title: '',
        imageUrls: [],
        description: '',
        timestamp: Timestamp.now(), // or any other default value you prefer
        ref: doc.reference,
      );
    }
  }).toList();
}


// ------------------------------------------------------------------------------------------------
// save post
  Future<void> savePost(String title, String description, List<File> images, String category) async {
  try {
    List<String> imageUrls = [];

    for (File image in images) {
      final storageRef = FirebaseStorage.instance.ref().child('post_images/${DateTime.now().toIso8601String()}');
      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    await FirebaseFirestore.instance.collection("post").add({
      'title': title,
      'description': description,
      'imageUrls': imageUrls, // Use 'imageUrls' instead of 'imageUrl'
      'category': category, 
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Error saving post: $e');
  }
}

// ------------------------------------------------------------------------------------------------
//                             Comment


  Future<void>comment(PostModel post, String commentText) async {
  try {
    print("Attempting to add comment: $commentText");
    await FirebaseFirestore.instance
        .collection('post')
        .doc(post.id)
        .collection('comments')
        .add({
      'text': commentText,
      'creator': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print("Comment added successfully");
  } catch (e) {
    print('Error adding comment: ${e.toString()}');
    // Handle error appropriately (display a message to the user)
  }
}

  // Method to convert Firestore snapshot to list of CommentModel
    List<CommentModel> _commentListFromSnapshot(QuerySnapshot snapshot) {
      return snapshot.docs.map((doc) {
        return CommentModel.fromDocument(doc);
      }).toList();
    }

    // Method to get comments as a stream of List<CommentModel>
    Stream<List<CommentModel>> getComments(PostModel post) {
      return post.ref
          .collection("comments")
          .orderBy("timestamp", descending: true)
          .snapshots()
          .map(_commentListFromSnapshot);
    }


      Future<void> replyToComment({
      required String postId,
      required String commentId,
      required String text,
      required String author,
    }) async {
      try {
        // Create a new instance of ReplyCommentModel
        ReplyCommentModel reply = ReplyCommentModel(author: author, text: text);

        // Reference to the Firestore document where the reply will be stored
        DocumentReference replyRef = _firestore
            .collection('post')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .doc();

        // Convert the ReplyCommentModel instance to a map
        Map<String, dynamic> replyData = reply.toMap();

        // Set the reply document in Firestore
        await replyRef.set({
          ...replyData,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print("Reply added successfully.");
      } catch (e) {
        print("Failed to add reply: $e");
        throw e; // Rethrow the exception to propagate it to the caller if needed
      }
    }

    Stream<List<ReplyCommentModel>> getReplies(String postId, String commentId) {
      return _firestore
          .collection('post')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .collection('replies')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ReplyCommentModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList());
    }


     Future<void> deleteReply(String postId, String commentId, String replyId) async {
    try {
      await _firestore
          .collection('post') // Replace with your collection name for posts
          .doc(postId)
          .collection('comments') // Assuming 'comments' is a subcollection under each post
          .doc(commentId)
          .collection('replies') // Assuming 'replies' is a subcollection under each comment
          .doc(replyId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete reply: $e');
    }
  }





// ------------------------------------------------------------------------------------------------
//                             LIKE

  Stream<bool> getCurrentUserLike(PostModel post){
    return FirebaseFirestore.instance
        .collection("post")
        .doc(post.id)
        .collection("likes")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .map((snapshot){
          return snapshot.exists; 
        });
  }


  Future likePost(PostModel post, bool current) async{
    print(post.id);
    if(current){
      await FirebaseFirestore.instance
        .collection("post")
        .doc(post.id)
        .collection("likes")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .delete();
    }

    if(!current){
      await FirebaseFirestore.instance
        .collection("post")
        .doc(post.id)
        .collection("likes")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set({});
    }
  }

  //StreamController<int> _likeCountController = StreamController<int>();

  Stream<int> getLikeCount(PostModel post) {
    return FirebaseFirestore.instance
      .collection('post')
      .doc(post.id)
      .collection('likes')
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}

Future<void> updateLikeCount(PostModel post) async {
  try {
    DocumentReference postRef = _db.collection('post').doc(post.id);
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

// ------------------------------------------------------------------------------------------------

  //just display post by the user 
  Stream<List<PostModel>> getPostByUser(uid){
    return FirebaseFirestore.instance
    .collection("post")
    .where('creator', isEqualTo: uid)
    .snapshots()
    .map(_postListFromSnapshot);
  }

  // just display event by the user
   Stream<List<EventModel>> fetchEventsByCreator(String creator) {
    try {
      return _firestore
          .collection('event')
          .where('creator', isEqualTo: creator)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs
              .map((doc) => EventModel.fromDocument(doc))
              .toList());
    } catch (e) {
      print('Error fetching events by creator: $e');
      return Stream.value([]); // Return an empty list on error
    }
  }

  Stream<List<CommunityModel>> getComPostByCreatorId(String userId) {
  try {
    StreamController<List<CommunityModel>> controller = StreamController<List<CommunityModel>>();

    // Query the 'communities' collection
    _firestore
        .collection('communities')
        .snapshots()
        .listen((QuerySnapshot communitySnapshot) async {
      
      List<CommunityModel> posts = [];

      // Iterate through each document in 'communities' collection
      for (var communityDoc in communitySnapshot.docs) {
        // Get the 'posts' subcollection reference for each community
        CollectionReference postsRef = communityDoc.reference.collection('posts');

        // Query the 'posts' subcollection where 'creator' field matches 'userId'
        QuerySnapshot postQuerySnapshot = await postsRef.where('creator', isEqualTo: userId).get();

        // Iterate through 'posts' documents and convert them to CommunityModel objects
        for (var postDoc in postQuerySnapshot.docs) {
          CommunityModel post = CommunityModel.fromDocument(postDoc);
          posts.add(post);
        }
      }

      // Add the list of posts to the stream
      controller.add(posts);
    });

    // Return the stream from the controller
    return controller.stream;
  } catch (e) {
    print('Error fetching posts: $e');
    return Stream.value([]);
  }
}


  Stream<Community?> getCommunityById(String communityId) {
    // Create a stream controller to manage the stream
    StreamController<Community?> controller = StreamController<Community?>();

    // Initialize a variable to store the subscription
    late StreamSubscription<DocumentSnapshot> subscription;

    // Start listening to the document snapshots for the specified communityId
    subscription = _firestore.collection('communities').doc(communityId).snapshots().listen((doc) {
      if (doc.exists) {
        // Convert the document snapshot to a Community object using the factory constructor
        Community community = Community.fromFirestore(doc);
        
        // Add the community object to the stream
        controller.add(community);
      } else {
        // If the document does not exist, add null to the stream
        controller.add(null);
      }
    }, onError: (e) {
      print('Error fetching community: $e');
      controller.add(null); // Add null to the stream on error
    });

    // Cancel the subscription when the stream controller is closed
    controller.onCancel = () {
      subscription.cancel();
    };

    // Return the stream from the controller
    return controller.stream;
  }














   Future<UserModel?> fetchUserByUid(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Users').doc(uid).get();

      if (doc.exists) {
        return UserModel.fromDocument(doc);
      } else {
        // Document does not exist for the given uid
        return null;
      }
    } catch (e) {
      print('Error fetching user by uid: $e');
      return null;
    }
  }





  // just display communty by the user




//---------------------------------------------------------------------------------------------------------------

  // This method returns a stream of List<PostModel> which contains the posts from Firestore.
  Stream<List<PostModel>> getFeed({int limit = 10, DocumentSnapshot? startAfterDocument}) {
    Query query = FirebaseFirestore.instance
        .collection('post')
        .orderBy('timestamp', descending: true)
        .limit(limit); // Limit the number of documents fetched

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    return query.snapshots().map((querySnapshot) {
      // Map querySnapshot.docs to List<PostModel>
      List<PostModel> posts = querySnapshot.docs.map((doc) {
        return PostModel.fromDocument(doc);
      }).toList();

      return posts;
    });
  }

// ------------------------------------------------------------------------------------------------


  Future<UserModel> getUserInfoOnce(String userId) async {
  try {
    DocumentSnapshot userDoc = await _db.collection('Users').doc(userId).get();
    if (userDoc.exists) {
      return UserModel.fromDocument(userDoc);
    } else {
      return Future.value(null); // Return null wrapped in a Future
    }
  } catch (e) {
    print('Error getting user info: ${e.toString()}');
    rethrow; 
  }
}

  // ------------------------------------------------------------------------------------------------
  // Delete a comment from a post

  Future<void> deleteComment(DocumentReference commentRef) async {
    try {
      if (_auth.currentUser != null) {
        await commentRef.delete();
      } else {
        print('User not authenticated');
      }
    } catch (e) {
      print('Error deleting comment: ${e.toString()}');
    }
  }
// ------------------------------------------------------------------------------------------------
  // save events post

 Future<void> saveEventPost({
    required String title,
    required String description,
    required String category,
    required String streetName,
    required String town,
    required String region,
    required String state,
    required List<File> images,
    required int day, // Added day parameter
    required int month, // Added month parameter
    required int year, // Added year parameter
  }) async {
    try {
      List<String> imageUrls = [];

      // Upload images to Firebase Storage
      for (var imageFile in images) {
        final storageRef = FirebaseStorage.instance.ref().child('event_images/${DateTime.now().toIso8601String()}');
        await storageRef.putFile(imageFile);
        final url = await storageRef.getDownloadURL();
        imageUrls.add(url);
      }

      // Save event data to Firestore
      await FirebaseFirestore.instance.collection("event").add({
        'title': title,
        'description': description,
        'category': category,
        'streetName': streetName,
        'town': town,
        'region': region,
        'state': state,
        'imageUrl': imageUrls,
        'creator': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'day': day, // Save day
        'month': month, // Save month
        'year': year, // Save year
      });
    } catch (e) {
      print('Error saving event post: $e');
      // You can handle errors here, such as showing an error message to the user
    }
  }

// ------------------------------------------------------------------------------------------------
  //get save events post
  // Stream<List<EventModel>> getEventPosts() {
  //   return FirebaseFirestore.instance
  //       .collection('event')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .map((querySnapshot) {
  //     return querySnapshot.docs.map((doc) {
  //       return EventModel.fromDocument(doc);
  //     }).toList();
  //   });
  // }
   Stream<List<EventModel>> getEventPosts(String category) {
    return FirebaseFirestore.instance
        .collection('event')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return EventModel.fromDocument(doc);
      }).toList();
    });
  }

  Stream<List<EventModel>> getEventsSortedByParticipants(String category) {
    return FirebaseFirestore.instance
        .collection('event')
        .where('category', isEqualTo: category)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<EventModel> events = [];
      
      for (var doc in querySnapshot.docs) {
        EventModel event = EventModel.fromDocument(doc);
        // Fetch participant count from subcollection
        QuerySnapshot participantsSnapshot = await doc.reference.collection('participants').get();
        event.participantCount = participantsSnapshot.size; // Number of participants
        
        events.add(event);
      }
      
      // Sort events by participant count (descending)
      events.sort((a, b) => b.participantCount.compareTo(a.participantCount));
      
      return events;
    });
  }
  
  Stream<List<EventModel>> getEventList() {
  return FirebaseFirestore.instance
      .collection('event')
      .snapshots()
      .map((querySnapshot) {
    return querySnapshot.docs.map((doc) => EventModel.fromDocument(doc)).toList();
  });
}


  //-----------------------------------------------------------------------------------------------------------------------------------------------
  //                                                EVENT
   //-----------------------------------------------------------------------------------------------------------------------------------------------

   Future<bool> joinEvent(EventModel event) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Check if user has already joined the event
      DocumentSnapshot participantDoc = await FirebaseFirestore.instance
          .collection('event') // Ensure this matches your Firestore collection name
          .doc(event.id)
          .collection('participants')
          .doc(userId)
          .get();

      if (participantDoc.exists) {
        return true; // User has already joined the event
      } else {
        // Add user to the event's participants collection
        await FirebaseFirestore.instance
            .collection('event') // Ensure this matches your Firestore collection name
            .doc(event.id)
            .collection('participants')
            .doc(userId)
            .set({
              'userId': userId,
              // Add additional fields if needed
              'joinedAt': FieldValue.serverTimestamp(),
            });

        // Add the event to the user's joinedEvents subcollection
        await FirebaseFirestore.instance
            .collection('Users') // Ensure this matches your Firestore collection name
            .doc(userId)
            .collection('joinedEvents')
            .doc(event.id)
            .set(event.toMap()); // Use toJson() method of EventModel to save the entire object

        return false; // User successfully joined the event
      }
    } catch (e) {
      print('Error joining event: $e');
      return false; // Return false if an error occurs
    }
  }

   Future<void> leaveEvent(EventModel event, String userId) async {
    try {
      DocumentReference participantDoc = _db
          .collection('event')
          .doc(event.id)
          .collection('participants')
          .doc(userId);
      await participantDoc.delete();

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('joinedEvents')
          .doc(event.id)
          .delete();
   
    } catch (e) {
      print('Error leaving event: $e');
    }
  }

  Future<bool> saveEvent(EventModel event) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot savedEventDoc = await _db
          .collection('Users')
          .doc(userId)
          .collection('savedEvents')
          .doc(event.id)
          .get();

      if (savedEventDoc.exists) {
        return true; // Event is already saved by the user
      } else {
        await _db
            .collection('Users')
            .doc(userId)
            .collection('savedEvents')
            .doc(event.id)
            .set(event.toMap()); // Use toJson() method of EventModel to save the entire object

        return false; // Event successfully saved by the user
      }
    } catch (e) {
      print('Error saving event: $e');
      return false; // Return false if an error occurs
    }
  }


   Future<bool> unsaveEvent(String eventId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot savedEventDoc = await _db
          .collection('Users')
          .doc(userId)
          .collection('savedEvents')
          .doc(eventId)
          .get();

      if (savedEventDoc.exists) {
        await _db
            .collection('Users')
            .doc(userId)
            .collection('savedEvents')
            .doc(eventId)
            .delete();

        return true; // Event successfully unsaved by the user
      } else {
        return false; // Event was not previously saved by the user
      }
    } catch (e) {
      print('Error unsaving event: $e');
      return false; // Return false if an error occurs
    }
  }


 Future<void> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required String category,
    required String streetName,
    required String town,
    required String region,
    required String state,
    required List<String> imageUrl,
  }) async {
    try {
      Map<String, dynamic> eventData = {
        'title': title,
        'description': description,
        'category': category,
        'streetName': streetName,
        'town': town,
        'region': region,
        'state': state,
        'imageUrl': imageUrl,
      };

      await _db.collection('event').doc(eventId).update(eventData);
    } catch (e) {
      print('Error updating event: $e');
      throw e;
    }
  }

   Future<void> deleteEvent(String eventId) async {
    try {
      // Delete all documents in the 'participants' subcollection
      var participantsCollection = _db.collection('event').doc(eventId).collection('participants');
      var participantsSnapshot = await participantsCollection.get();
      for (var doc in participantsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the event document
      await _db.collection('event').doc(eventId).delete();

      // Delete the event document in the 'joinedEvents' subcollection inside the 'Users' collection
      var usersCollection = _db.collection('Users');
      var usersSnapshot = await usersCollection.get();
      for (var userDoc in usersSnapshot.docs) {
        var joinedEventDoc = usersCollection.doc(userDoc.id).collection('joinedEvents').doc(eventId);
        var joinedEventSnapshot = await joinedEventDoc.get();
        if (joinedEventSnapshot.exists) {
          await joinedEventDoc.delete();
        }
      }

    } catch (e) {
      print('Error deleting event and its participants: $e');
      throw e;
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('event_images/${DateTime.now().toIso8601String()}');
      await storageRef.putFile(imageFile);
      final url = await storageRef.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

Future<List<EventModel>> fetchSavedEvents() async {
    try {
      String? userId = await AuthService().getCurrentUserId(); // Fetch current user ID
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Query saved events for the current user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('savedEvents')
          .get();

      // Convert QuerySnapshot to List<EventModel>
      List<EventModel> fetchedSavedEvents = querySnapshot.docs.map((doc) {
        return EventModel.fromDocument(doc);
      }).toList();

      return fetchedSavedEvents;
    } catch (error) {
      print('Error fetching saved events: $error');
      return []; // Return empty list if error occurs
    }
  }

  Future<List<EventModel>> fetchJoinEvent() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      

      // Query the joinedEvents subcollection for the current user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('joinedEvents')
          .get();

      // Convert QuerySnapshot to List<EventModel>
      List<EventModel> joinedEvents = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ensure the document ID is set
        return EventModel.fromDocument(doc);
      }).toList();

      return joinedEvents;
    } catch (e) {
      print('Error fetching joined events: $e');
      throw e; // Rethrow the error to handle it in the UI
    }
  }

    Future<List<Map<String, dynamic>>> fetchParticipants(String eventId) async {
    try {
      // Reference to the participants collection inside the event document
      CollectionReference<Map<String, dynamic>> participantsRef = _firestore
          .collection('event')
          .doc(eventId)
          .collection('participants');

      // Fetch all participant documents
      QuerySnapshot<Map<String, dynamic>> snapshot = await participantsRef.get();

      // Map the documents to a list of participant data
      List<Map<String, dynamic>> participants = snapshot.docs.map((doc) {
        return doc.data();
      }).toList();

      return participants;
    } catch (e) {
      print('Error fetching participants: $e');
      return []; // Return an empty list on error
    }
  }

  // --------------------------------------------


   Stream<List<EventModel>> fetchAndSortEventsByParticipantCount() {
    StreamController<List<EventModel>> controller = StreamController<List<EventModel>>();

    // Initial fetch and sort
    _fetchAndSortEvents(controller);

    // Listen for changes in Firestore
    FirebaseFirestore.instance.collection('event').snapshots().listen((querySnapshot) {
      _fetchAndSortEvents(controller);
    }, onError: (error) {
      print("Error fetching and sorting events: $error");
      controller.addError(error);
    });

    return controller.stream;
  }

  Future<void> _fetchAndSortEvents(StreamController<List<EventModel>> controller) async {
    try {
      final eventsSnapshot = await FirebaseFirestore.instance.collection('event').get();

      final events = eventsSnapshot.docs
          .map((doc) => EventModel.fromDocument(doc))
          .toList();

      // Fetch participant counts for each event
      await Future.forEach(events, (event) async {
        final participantsSnapshot = await FirebaseFirestore.instance
            .collection('event')
            .doc(event.id)
            .collection('participants')
            .get();
        event.participantCount = participantsSnapshot.size; // Update participant count for each event
      });

      // Sort events by participant count in descending order
      events.sort((a, b) => b.participantCount.compareTo(a.participantCount));

      controller.add(events);
    } catch (error) {
      print("Error fetching, counting participants, and sorting events: $error");
      controller.addError(error);
    }
  }


   Stream<int> getMemberCountStream(String communityId) {
    return _firestore
        .collection('communities')
        .doc(communityId)
        .collection('members')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }





































  



}