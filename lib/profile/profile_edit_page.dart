// screens/edit.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/map_search.dart';
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
  UserModel? _currentUser; // To hold current user data
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _birthdayController;
  String _selectedGender = 'Male'; // Default value for gender
  Map<String, String>? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _birthdayController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userSnapshot = await _userService.getUserInfo(currentUser.uid).first;
      setState(() {
        _currentUser = userSnapshot;
        _nameController.text = _currentUser!.name;
        _bioController.text = _currentUser!.bio;
        _birthdayController.text = _currentUser!.birthday;
        _selectedGender = _currentUser!.gender;
      });
    }
  }

  Future<void> getImage(int type, ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        if (type == 0) {
          _profileImage = File(pickedFile.path);
        } else if (type == 1) {
          _bannerImage = File(pickedFile.path);
        }
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

  void _onGenderChanged(String? value) {
  if (value != null) {
    setState(() {
      _selectedGender = value;
    });
  }
}

 Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _birthdayController.text = picked.toString(); // Adjust date format as needed
      });
    }
  }

  String _formatDate(String dateString) {
  // Parse the dateString into a DateTime object
  DateTime? selectedDate = DateTime.tryParse(dateString);

  if (selectedDate != null) {
    // Format the DateTime into a string with year, month, and day
    return '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';
  } else {
    return 'Select Date';
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () async {
              await _userService.updateProfile(
                bannerImage: _bannerImage,
                profileImage: _profileImage,
                name: _nameController.text,
                bio: _bioController.text,
                birthday: _birthdayController.text,
                streetName: _selectedAddress?['streetName'], // Use ':' for named argument assignment
                town: _selectedAddress?['town'],
                region: _selectedAddress?['region'],
                state: _selectedAddress?['state'],
                gender: _selectedGender,
              );
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: Color.fromARGB(255, 255, 175, 16))),
          )
        ],

      ),
      body: _currentUser == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: ListView(
                children: [
                  TextButton(
                    onPressed: () => _showImageSourceDialog(0),
                    child: _profileImage == null 
                      ? _currentUser!.profileImageUrl.isNotEmpty
                        ? Image.network(_currentUser!.profileImageUrl, height: 100)
                        : Icon(Icons.person, size: 100)
                      : Image.file(_profileImage!, height: 100),
                  ),
                  TextButton(
                    onPressed: () => _showImageSourceDialog(1),
                    child: _bannerImage == null 
                      ? _currentUser!.bannerImageUrl.isNotEmpty
                        ? Image.network(_currentUser!.bannerImageUrl, height: 100)
                        : Icon(Icons.image, size: 100)
                      : Image.file(_bannerImage!, height: 100),
                  ),
                  
                  DropdownButtonFormField<String>(
  value: _selectedGender,
  onChanged: _onGenderChanged,
  items: ['Male', 'Female', 'Other'].map((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(value),
    );
  }).toList(),
  decoration: InputDecoration(labelText: 'Gender'),
),


                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextFormField(
                    controller: _bioController,
                    decoration: InputDecoration(labelText: 'Bio'),
                  ),
                  Row(
  children: [
    Icon(Icons.calendar_today),
    SizedBox(width: 10),
    Flexible( // or Expanded
      child: TextButton(
        onPressed: _selectDate,
        child: Text(
          'Birthday: ${_birthdayController.text.isEmpty ? "Select Date" : _formatDate(_birthdayController.text)}',
          style: TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis, // Optional: Handle overflow gracefully
          maxLines: 1, // Optional: Limit to a single line
        ),
      ),
    ),
  ],
),

                  
                 Row(
  children: [
    Icon(Icons.location_pin),
    SizedBox(width: 10),
    ElevatedButton(
      onPressed: () async {
        final selectedAddress = await Navigator.push<Map<String, String>>(
          context,
          MaterialPageRoute(
            builder: (context) => MapSearch(
              onAddressSelected: (components) {
                setState(() {
                  _selectedAddress = components;
                });
              },
            ),
          ),
        );
      },
      child: const Text("Add Location"),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 243, 20, 154)),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
    ),
  ],
),

// Display selected address below the row
if (_selectedAddress != null) ...[
  SizedBox(height: 16.0), // Adjust the height as per your design
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Selected Address:',
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 4.0),
      Text(
        'Street Name: ${_selectedAddress!['streetName']}',
        style: TextStyle(fontSize: 16.0),
      ),
      Text(
        'Town/City: ${_selectedAddress!['town']}',
        style: TextStyle(fontSize: 16.0),
      ),
      Text(
        'Region: ${_selectedAddress!['region']}',
        style: TextStyle(fontSize: 16.0),
      ),
      Text(
        'State: ${_selectedAddress!['state']}',
        style: TextStyle(fontSize: 16.0),
      ),
    ],
  ),
],



                ],
              ),
            ),
    );
  }
  
}
