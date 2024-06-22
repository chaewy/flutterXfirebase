import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/community.dart';
import 'package:flutter_application_1/services/community_service.dart';
import 'package:image_picker/image_picker.dart';

class EditCommunityPage extends StatefulWidget {
  final String communityId;

  EditCommunityPage({required this.communityId});

  @override
  _EditCommunityPageState createState() => _EditCommunityPageState();
}

class _EditCommunityPageState extends State<EditCommunityPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController = TextEditingController();
  late TextEditingController _descriptionController = TextEditingController();
  late TextEditingController _iconImageController = TextEditingController();
  late TextEditingController _bannerImageController = TextEditingController();
  late TextEditingController _topicsController = TextEditingController();

  File? _pickedBannerImage;
  File? _pickedIconImage;

  bool _isLoading = false;

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

  String? selectedTopic;

  @override
  void initState() {
    super.initState();
    _fetchCommunityDetails();
  }

  void _fetchCommunityDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DocumentSnapshot communitySnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.communityId)
          .get();

      Community community = Community.fromFirestore(communitySnapshot);

      _nameController.text = community.name;
      _descriptionController.text = community.description;
      _iconImageController.text = community.iconImage;
      _bannerImageController.text = community.bannerImage;
      _topicsController.text = community.topics;

      selectedTopic = community.topics; // Set selected topic for initial display
    } catch (e) {
      print('Error fetching community details: $e');
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconImageController.dispose();
    _bannerImageController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String? bannerImageUrl;
        String? iconImageUrl;

        if (_pickedBannerImage != null) {
          bannerImageUrl = await _uploadImage(_pickedBannerImage!);
        } else {
          bannerImageUrl = _bannerImageController.text;
        }

        if (_pickedIconImage != null) {
          iconImageUrl = await _uploadImage(_pickedIconImage!);
        } else {
          iconImageUrl = _iconImageController.text;
        }

        Community updatedCommunity = Community(
          id: widget.communityId,
          name: _nameController.text,
          description: _descriptionController.text,
          iconImage: iconImageUrl,
          bannerImage: bannerImageUrl,
          topics: _topicsController.text,
          createdAt: Timestamp.now(),
          creatorId: userId,
          ref: FirebaseFirestore.instance.collection('communities').doc(widget.communityId),
        );

        CommunityService communityService = CommunityService();
        await communityService.editCommunity(updatedCommunity);

        // Optionally, navigate back or show success message
        Navigator.pop(context); // Navigate back after successful update
      } catch (e) {
        print('Error updating community: $e');
        // Handle error
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    // Implement your image upload logic to a cloud storage (e.g., Firebase Storage)
    // Here's an example using Firebase Storage
    // This is just a placeholder, you should replace it with your actual implementation
    // and handle error cases properly
    String imageUrl = 'placeholder_url';
    return imageUrl;
  }

  Future<void> _pickImage(ImageSource source, bool isBannerImage) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        if (isBannerImage) {
          _pickedBannerImage = File(pickedImage.path);
        } else {
          _pickedIconImage = File(pickedImage.path);
        }
      });
    }
  }

  void _removeImage(bool isBannerImage) {
    setState(() {
      if (isBannerImage) {
        _pickedBannerImage = null;
        _bannerImageController.clear();
      } else {
        _pickedIconImage = null;
        _iconImageController.clear();
      }
    });
  }

  void _selectTopic(String topic) {
    setState(() {
      selectedTopic = topic;
      _topicsController.text = topic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Community'),
        actions: [
          if (_bannerImageController.text.isNotEmpty || _pickedBannerImage != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeImage(true),
            ),
        ],
        flexibleSpace: _bannerImageController.text.isNotEmpty || _pickedBannerImage != null
            ? Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _pickedBannerImage != null
                        ? FileImage(_pickedBannerImage!) as ImageProvider<Object>
                        : NetworkImage(_bannerImageController.text) as ImageProvider<Object>,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery, false),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _pickedIconImage != null
                            ? FileImage(_pickedIconImage!) as ImageProvider<Object>
                            : _iconImageController.text.isNotEmpty
                                ? NetworkImage(_iconImageController.text) as ImageProvider<Object>
                                : AssetImage('assets/default_icon_image.png') as ImageProvider<Object>,
                        child: _pickedIconImage == null && _iconImageController.text.isEmpty
                            ? Icon(Icons.add_photo_alternate, size: 50)
                            : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (_iconImageController.text.isNotEmpty || _pickedIconImage != null)
                      Align(
                        alignment: Alignment.center,
                        child: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeImage(false),
                        ),
                      ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Choose a Topic:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: topics.map((topic) {
                        return ElevatedButton(
                          onPressed: () => _selectTopic(topic),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                // Determine if the button is selected
                                bool isSelected = selectedTopic == topic;

                                // Define default colors for different states
                                Color defaultColor = const Color.fromARGB(255, 255, 255, 255); // Example of default color

                                // Return appropriate color based on state
                                return isSelected
                                    ? Color.fromARGB(255, 237, 163, 43) // Selected state color
                                    : Color.fromARGB(255, 255, 255, 255); // Default state color
                              },
                            ),
                          ),
                          child: Text(topic),
                        );
                      }).toList(),
                    ),

                    TextFormField(
                      controller: _topicsController,
                      decoration: InputDecoration(labelText: 'Selected Topic'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a topic';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
