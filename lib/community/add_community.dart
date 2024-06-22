import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({Key? key}) : super(key: key);

  @override
  _CreateCommunityPageState createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? selectedTopic; // Variable to store the selected topic

  // Available topics
  List<String> topics = [
    'anime & cosplay',
    'collectibles',
    'fashion & beauty',
    'art',
    'business & finance',
    'education & career',
    'food & drinks',
    'games',
    'law',
    'home & garden',
    'nature & outdoors',
    'music',
    'movies & tv',
    'news & politics',
    'places & travel',
    'reading and writing',
    'sports',
    'vehicles',
    'technology',
  ];

  // Function to handle topic button press
  void _selectTopic(String topic) {
    setState(() {
      selectedTopic = topic; // Set the selected topic
    });
  }

  Future<void> _createCommunity() async {
    // Validate fields
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        selectedTopic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Access Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      // Get current user ID
      String? userId = auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in.'); // Handle case where user is not logged in
      }

      // Add community to Firestore
      DocumentReference docRef = await firestore.collection('communities').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'createdAt': Timestamp.now(), // Store creation timestamp
        'creatorId': userId, // Assign creator's user ID
        'iconImage': 'https://firebasestorage.googleapis.com/v0/b/hobby-b1c8b.appspot.com/o/default%2Fcom.jpg?alt=media&token=8d43d287-41ca-4bae-b279-5f8bb645b4e5',
        'bannerImage': 'https://firebasestorage.googleapis.com/v0/b/hobby-b1c8b.appspot.com/o/default%2Fyellow.jpg?alt=media&token=06a3b070-5b6f-4d5a-8d92-c78569796cea',
        'topics': selectedTopic, // Store selected topic
      });

      // Show success message or navigate to community page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Community created successfully')),
      );

      // Navigate back to previous screen (assuming this is where you navigate back)
      Navigator.pop(context);

    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create community: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Community'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Community Name'),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 5,
              ),
              SizedBox(height: 16.0),
              Text(
                'Select Topic:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              SizedBox(
                height: 80.0, // Height of each row of buttons
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Row(
                      children: [
                        for (String topic in topics)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ElevatedButton(
                              onPressed: () => _selectTopic(topic),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: selectedTopic == topic ? Colors.white : Colors.black, backgroundColor: selectedTopic == topic ? Colors.blue : Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0), // Oval-shaped button
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Adjusted button size
                              ),
                              child: Text(topic),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _createCommunity,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // Oval-shaped button
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0), // Adjusted button size
                ),
                child: Text('Create Community'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
