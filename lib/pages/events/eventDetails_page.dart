import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/models/user.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
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
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Posted by ',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(user: user),
                              ),
                            );
                          },
                          child: Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.event.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Location: ${widget.event.streetName}, ${widget.event.town}, ${widget.event.region}, ${widget.event.state}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
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
                    const SizedBox(height: 8),
                    Text(
                      '${widget.event.description}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
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
                                  ElevatedButton(
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
                                  )
                                else
                                  ElevatedButton(
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
                                const SizedBox(height: 24),
                                const Text(
                                  'Users who joined the event:',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ListView(
                                  shrinkWrap: true,
                                  children: participants.map((participant) {
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(participant.profileImageUrl),
                                          backgroundColor: Colors.grey[300],
                                        ),
                                      ),
                                      title: Text(
                                        participant.name,
                                        style: const TextStyle(fontSize: 16),
                                        textAlign: TextAlign.start,
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfilePage(user: participant),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
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
