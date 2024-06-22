import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/models/community.dart';
import 'package:flutter_application_1/models/communityPost.dart';
import 'package:flutter_application_1/services/community_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCommunityPostPage extends StatefulWidget {
  @override
  _AddCommunityPostPageState createState() => _AddCommunityPostPageState();
}

class _AddCommunityPostPageState extends State<AddCommunityPostPage> {
  Community? _selectedCommunity;
  final TextEditingController _postContentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  Stream<List<Community>>? _searchResults;

  final CommunityService _communityService = CommunityService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _searchResults = _communityService.queryCommunitiesByName('');
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _clearImages() {
    setState(() {
      _images.clear();
    });
  }

// -------------------------------------

  Future<void> _addPostToCommunity() async {
  try {
    if (_selectedCommunity == null) return;

    List<String> imageUrls = [];

    // Upload each image and collect download URLs
    for (File image in _images) {
      String imageUrl = await _uploadImage(image);
      imageUrls.add(imageUrl);
    }

    // Get current user's ID
    String? creatorId = await _authService.getCurrentUserId();
    if (creatorId == null) {
      throw Exception('User not logged in');
    }

    // Prepare post data
    CommunityModel post = CommunityModel(
      id: '', // Firestore will generate a unique ID
      communityId: _selectedCommunity!.id, // Assign selected community ID here
      creator: creatorId,
      title: _postContentController.text.trim(),
      imageUrls: imageUrls,
      description: _descController.text.trim(),
      timestamp: Timestamp.now(),
      likeCount: 0,
      ref: FirebaseFirestore.instance.collection('communities').doc(_selectedCommunity!.id).collection('posts').doc(), // Set reference as needed
    );

    // Add post data to Firestore
    await post.ref.set({
      'creator': post.creator,
      'title': post.title,
      'imageUrls': post.imageUrls,
      'description': post.description,
      'timestamp': post.timestamp,
      'likeCount': post.likeCount,
      'communityId': post.communityId,
    });

    // Show success message or navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post added successfully')),
    );

    // Optionally navigate back to previous screen or home
    Navigator.pop(context);
  } catch (e) {
    // Handle errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add post: $e')),
    );
  }
}

// -------------------------------------

  Future<String> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('post_images').child(fileName);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  void _filterCommunities(String query) {
    setState(() {
      _searchResults = _communityService.queryCommunitiesByName(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Community Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Communities',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterCommunities('');
                  },
                ),
              ),
              onChanged: _filterCommunities,
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<List<Community>>(
                stream: _searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No communities found.'));
                  } else {
                    List<Community> communities = snapshot.data!;
                    return ListView.builder(
                      itemCount: communities.length,
                      itemBuilder: (context, index) {
                        Community community = communities[index];
                        return ListTile(
                          title: Text(community.name),
                          onTap: () {
                            setState(() {
                              _selectedCommunity = community;
                            });
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 16.0),
            if (_selectedCommunity != null) ...[
              Text(
                'Selected Community: ${_selectedCommunity!.name}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _postContentController,
                decoration: InputDecoration(labelText: 'Title'),
                maxLines: null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: null,
              ),
              Wrap(
                spacing: 8.0,
                children: _images.map((image) {
                  int index = _images.indexOf(image);
                  return Stack(
                    children: [
                      Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Icon(Icons.remove_circle, color: Colors.red),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _addPostToCommunity,
                child: Text('Add Post to Community'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
