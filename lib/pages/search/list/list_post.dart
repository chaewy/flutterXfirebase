import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/post.dart'; // Adjust import as per your project structure
import 'package:flutter_application_1/models/user.dart'; // Adjust import as per your project structure

class ListPosts extends StatelessWidget {
  final String searchText;

  ListPosts(this.searchText);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('post')
          .where('title', isGreaterThanOrEqualTo: searchText)
          .where('title', isLessThan: searchText + 'z') // Adjust end range
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No Posts Found'));
        }

        List<PostModel> posts = snapshot.data!.docs.map((DocumentSnapshot doc) {
          return PostModel.fromDocument(doc);
        }).toList();

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(post.creator) // Fetch user document based on creatorId
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Center(child: Text('Creator not found for post ${post.id}'));
                }

                UserModel creator = UserModel.fromDocument(userSnapshot.data!);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 1, horizontal: 1), // Adjust padding here
                  child: Card(
                    elevation: 3,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 14), // Adjust ListTile padding
                      title: Text(post.title),
                      subtitle: Text(post.description),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          creator.profileImageUrl,
                        ),
                      ),
                      trailing: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          width: 100.0,
                          height: 150.0, // Adjust card height here
                          decoration: BoxDecoration(
                            image: post.imageUrls.isNotEmpty
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(post.imageUrls[0]),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
