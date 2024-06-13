import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/event.dart'; // Adjust import as per your project structure
import 'package:flutter_application_1/models/user.dart'; // Adjust import as per your project structure

class ListEvents extends StatelessWidget {
  final String searchText;

  ListEvents(this.searchText);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('event')
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
          return Center(child: Text('No Events Found'));
        }

        List<EventModel> events = snapshot.data!.docs.map((DocumentSnapshot doc) {
          return EventModel.fromDocument(doc);
        }).toList();

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('Users').doc(event.creator).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return Center(child: Text('Creator not found for event ${event.id}'));
                }

                UserModel creator = UserModel.fromDocument(userSnapshot.data!);

                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('event')
                      .doc(event.id)
                      .collection('participants')
                      .get(),
                  builder: (context, participantSnapshot) {
                    if (participantSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (participantSnapshot.hasError) {
                      return Center(child: Text('Error: ${participantSnapshot.error}'));
                    }

                    int participantCount = participantSnapshot.data!.docs.length;

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(creator.profileImageUrl),
                        ),
                        title: Text(event.title),
                        subtitle: Text('$participantCount participants'),
                        trailing: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              image: event.imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(event.imageUrl[0]),
                                    )
                                  : null,
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
      },
    );
  }
}
