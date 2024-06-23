import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({Key? key}) : super(key: key);

  @override
  _CreateCommunityPageState createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? selectedTopic;

  // Image variables
  File? iconImageFile;
  File? bannerImageFile;

  // Image URLs to display after selection
  String? iconImageUrl;
  String? bannerImageUrl;

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

  // Function to handle image selection
  Future<void> _pickImage(ImageSource source, String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (type == 'icon') {
          iconImageFile = File(pickedFile.path);
          iconImageUrl = null; // Clear previous image URL
        } else if (type == 'banner') {
          bannerImageFile = File(pickedFile.path);
          bannerImageUrl = null; // Clear previous image URL
        }
      });
    }
  }

  // Function to upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile, String fileName) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Function to create community with image uploads
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

    // Access Firestore and Firebase Auth instances
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      // Get current user ID
      String? userId = auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in.');
      }

      // Upload icon image if selected
      if (iconImageFile != null) {
        iconImageUrl = await _uploadImage(iconImageFile!, 'icons/$userId-icon.jpg');
      }

      // Upload banner image if selected
      if (bannerImageFile != null) {
        bannerImageUrl = await _uploadImage(bannerImageFile!, 'banners/$userId-banner.jpg');
      }

      // Add community to Firestore
      DocumentReference docRef = await firestore.collection('communities').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'createdAt': Timestamp.now(),
        'creatorId': userId,
        'iconImage': iconImageUrl ?? '',
        'bannerImage': bannerImageUrl ?? '',
        'topics': selectedTopic,
      });

      // Show success message or navigate to community page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Community created successfully')),
      );

      // Navigate back to previous screen
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
                                foregroundColor: selectedTopic == topic ? Colors.white : Colors.black,
                                backgroundColor: selectedTopic == topic ? Colors.blue : Colors.grey[300],
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
              SizedBox(height: 16.0),

              // Selected icon image preview
              if (iconImageFile != null)
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Image.file(
                    iconImageFile!,
                    fit: BoxFit.cover,
                  ),
                ),

              SizedBox(height: 16.0),

              // Selected banner image preview
              if (bannerImageFile != null)
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Image.file(
                    bannerImageFile!,
                    fit: BoxFit.cover,
                  ),
                ),

              SizedBox(height: 16.0),

              // Image picker buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery, 'icon'),
                      icon: Icon(Icons.image),
                      label: Text('Select Icon Image'),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery, 'banner'),
                      icon: Icon(Icons.image),
                      label: Text('Select Banner Image'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.0),

              ElevatedButton(
                onPressed: _createCommunity,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
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
