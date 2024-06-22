import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/events/editEvent.dart';
import 'package:flutter_application_1/pages/events/participant.dart';
import 'package:flutter_application_1/profile/profile_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';
import 'package:flutter_application_1/pages/post/FullImage_page.dart';

class EventDetails extends StatefulWidget {
  final EventModel event;

  EventDetails({required this.event});

  @override
  _EventDetailsState createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  late Future<List<UserModel>> _participantsFuture;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _participantsFuture = _userService.getEventParticipants(widget.event.id);
  }

  Future<void> _refreshParticipants() async {
    setState(() {
      _participantsFuture = _userService.getEventParticipants(widget.event.id);
    });
  }

  @override
  Widget build(BuildContext context) {

    bool isCurrentUserCreator = widget.event.creator == userId;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
    if (isCurrentUserCreator)



      PopupMenuButton<String>(
  onSelected: (value) async {
    if (value == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditEventPage(event: widget.event),
        ),
      );
    } else if (value == 'delete') {
      // Confirm before deleting
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this event?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      if (confirmDelete) {
        try {
          await PostService().deleteEvent(widget.event.id);
          // Navigate back to the previous page or show a confirmation
          Navigator.pop(context);
        } catch (e) {
          // Handle error if needed
          print('Error deleting event: $e');
        }
      }
    }
  },
  itemBuilder: (BuildContext context) {
    return [
      PopupMenuItem(
        value: 'edit',
        child: Text('Edit'),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Text('Delete'),
      ),
    ];
  },
),





          if (!isCurrentUserCreator)
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                // Handle save action
                // For example, show a dialog or perform some action
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Save Event'),
                      content: Text('Do you want to save this event?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Save'),
                          onPressed: () {
                            // Perform save action here
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<UserModel>(
          future: _userService.getUserInfo(widget.event.creator).first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('User not found'));
            } else {
              final user = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (widget.event.imageUrl.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.event.imageUrl.length,
                          itemBuilder: (context, index) {
                            final imageUrl = widget.event.imageUrl[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullImagePage(imageUrl: imageUrl),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  imageUrl,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 10),
                    Text(
                      widget.event.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    const Row(
                    children: [
                      SizedBox(width: 5), 
                      Icon(Icons.calendar_today), // Calendar Icon
                      SizedBox(width: 20), // Spacer for a little distance
                      Text(
                        '21', // Day
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 4), // Spacer between day and month
                      Text(
                        'Jun', // Month
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: 4), // Spacer between month and year
                      Text(
                        '2024', // Year
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),
                  const Divider(
                    color: Colors.grey,
                    height: 20,
                    thickness: 1,
                    indent: 0,
                    endIndent: 20,
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      SizedBox(width: 5), 
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Location",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        '${widget.event.streetName}, ${widget.event.town}, ${widget.event.region}, ${widget.event.state}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 20),
                                      Align(
                                        alignment: Alignment.center,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Close'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        
                        child: Icon(Icons.location_pin),
                      ),
                      SizedBox(width: 20),
                      Text(
                        '${widget.event.region},',
                        style: TextStyle(fontSize: 17),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${widget.event.state}',
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 5),
                  const Divider(
                    color: Colors.grey,
                    height: 20,
                    thickness: 1,
                    indent: 0,
                    endIndent: 20,
                  ),

                  const SizedBox(height: 5),

                  const Row(
                    children: [
                      SizedBox(width: 5),
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5), // Adjust height between single-line and multi-line text
                      Text(
                        '${widget.event.description}',
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),
                  const Divider(
                    color: Colors.grey,
                    height: 20,
                    thickness: 1,
                    indent: 0,
                    endIndent: 20,
                  ),
                  const SizedBox(height: 5),

                 Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          // Fetch participants using PostService
                          List<Map<String, dynamic>> participants = await _postService.fetchParticipants(widget.event.id);

                          // Navigate to participant page and pass participants data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParticipantsPage(participants: participants),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Text(
                                'Participants join:  ',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: _postService.fetchParticipants(widget.event.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    List<Map<String, dynamic>> participants = snapshot.data!;
                                    return Text(
                                      '${participants.length}',
                                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),


                const SizedBox(height: 5),
                  const Divider(
                    color: Colors.grey,
                    height: 20,
                    thickness: 1,
                    indent: 0,
                    endIndent: 20,
                  ),

                  const SizedBox(height: 5),
                    const SizedBox(height: 10),
                    FutureBuilder<List<UserModel>>(
                      future: _participantsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else {
                          final participants = snapshot.data!;
                          final isParticipant = participants.any((participant) => participant.uid == userId);
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (isParticipant)
                                   SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await _postService.leaveEvent(widget.event, userId);
                                        JoinEventSnackbar.showLeftEvent(context);
                                        await _refreshParticipants();
                                      },
                                      child: const Text('Leave Event'),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                      ),
                                    ),
                                  )
                                                    else
                                                      SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        bool alreadyJoined = await _postService.joinEvent(widget.event);
                                        JoinEventSnackbar.showSuccessOrAlreadyJoined(context, alreadyJoined);
                                        await _refreshParticipants();
                                      },
                                      child: const Text('Join Event'),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                      ),
                                    ),
                                  ),



                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class JoinEventSnackbar {
  static void showSuccessOrAlreadyJoined(BuildContext context, bool alreadyJoined) {
    if (alreadyJoined) {
      showAlreadyJoined(context);
    } else {
      showSuccess(context);
    }
  }

  static void showSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have joined the event!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static void showAlreadyJoined(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have already joined the event!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static void showLeftEvent(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have left the event!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
