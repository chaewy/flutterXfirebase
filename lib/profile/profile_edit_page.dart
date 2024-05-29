import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/user.dart';
import 'package:image_picker/image_picker.dart';

class Edit extends StatefulWidget {
  const Edit({Key? key}) : super(key: key);

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  UserService _userService = UserService();
  File? _profileImage;
  File? _bannerImage;
  final picker = ImagePicker();
  late UserModel _currentUser; // To hold current user data
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _birthdayController;
  late TextEditingController _locationController;
  late TextEditingController _educationController;
  late TextEditingController _hobbyController;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userSnapshot = await _userService.getUserInfo(currentUser.uid).first;
      setState(() {
        _currentUser = userSnapshot;
        _nameController = TextEditingController(text: _currentUser.name);
        _bioController = TextEditingController(text: _currentUser.bio);
        _birthdayController = TextEditingController(text: _currentUser.birthday);
        _locationController = TextEditingController(text: _currentUser.location);
        _educationController = TextEditingController(text: _currentUser.education);
        _hobbyController = TextEditingController(text: _currentUser.hobby);
      });
    }
  }

  Future<void> getImage(int type, ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null && type == 0) {
        _profileImage = File(pickedFile.path);
      }
      if (pickedFile != null && type == 1) {
        _bannerImage = File(pickedFile.path);
      }
    });
  }

  void _showImageSourceDialog(int type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                getImage(type, ImageSource.camera);
              },
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                getImage(type, ImageSource.gallery);
              },
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              await _userService.updateProfile(
                bannerImage: _bannerImage,
                profileImage: _profileImage,
                name: _nameController.text,
                bio: _bioController.text,
                birthday: _birthdayController.text,
                location: _locationController.text,
                education: _educationController.text,
                hobby: _hobbyController.text,
              );
              Navigator.pop(context);
            },
            child: Text('Save'),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: ListView(
          children: [
            TextButton(
              onPressed: () => _showImageSourceDialog(0),
              child: _profileImage == null 
                ? _currentUser.profileImageUrl.isNotEmpty
                  ? Image.network(_currentUser.profileImageUrl, height: 100)
                  : Icon(Icons.person)
                : Image.file(_profileImage!, height: 100),
            ),
            TextButton(
              onPressed: () => _showImageSourceDialog(1),
              child: _bannerImage == null 
                ? _currentUser.bannerImageUrl.isNotEmpty
                  ? Image.network(_currentUser.bannerImageUrl, height: 100)
                  : Icon(Icons.person)
                : Image.file(_bannerImage!, height: 100),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Bio'),
            ),
            TextFormField(
              controller: _birthdayController,
              decoration: InputDecoration(labelText: 'Birthday'),
            ),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location',
              ),
            ),
            TextFormField(
              controller: _educationController,
              decoration: InputDecoration(labelText: 'Education'),
            ),
            TextFormField(
              controller: _hobbyController,
              decoration: InputDecoration(labelText: 'Hobby'),
            ),
          ],
        ),
      ),
    );
  }
}
