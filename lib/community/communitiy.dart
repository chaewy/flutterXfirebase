import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/community/community_page.dart';
import 'package:flutter_application_1/loading,dart';
import 'package:flutter_application_1/models/community.dart'; // Import your Community model

//   SHOW ALL COMMUNITY

class Communitiy extends StatefulWidget {
  const Communitiy({Key? key}) : super(key: key);

  @override
  State<Communitiy> createState() => _CommunitiyState();
}

class _CommunitiyState extends State<Communitiy> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('communities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CustomLoadingIndicator(), // Show custom loading indicator
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No communities found.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Text(
                  'Most Popular Community',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSecondary,),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Community community = Community.fromFirestore(doc);

                    return _buildCommunityListItem(community);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCommunityListItem(Community community) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityPage(community: community),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipOval(
            child: Image.network(
              community.iconImage,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            community.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            community.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14),
          ),
          // trailing: ElevatedButton(
          //   onPressed: () {
          //     // Implement join community logic here
          //   },
          //   style: ElevatedButton.styleFrom(
          //     foregroundColor: Theme.of(context).colorScheme.onSecondary, backgroundColor: Theme.of(context).colorScheme.onPrimary, // Text color
          //     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(10),
          //       side: BorderSide(color: Theme.of(context).colorScheme.onSecondary), // Border color
          //     ),
          //   ),
          //   child: Text(
          //     'Join',
          //     style: TextStyle(fontSize: 14),
          //   ),
          // ),
        ),
      ),
    ),
  );
}

}