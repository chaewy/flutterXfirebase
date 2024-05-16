import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/user.dart';
import 'package:image_picker/image_picker.dart';

class Edit extends StatefulWidget {
  const Edit({Key? key}) : super(key: key);

  @override
  State<Edit> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Edit> {
  UserService _userService = UserService();

  File? _profileImage;
  File? _bannerImage;
  final picker = ImagePicker();
  String name = '';

  Future<void> getImage(int type) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      // for image
      if (pickedFile != null && type == 0) {
        _profileImage = File(pickedFile.path);
      }
      // for banner image
      if (pickedFile != null && type == 1) {
        _bannerImage = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              if (_bannerImage != null && _profileImage != null) {
                await _userService.updateProfile(_bannerImage!, _profileImage!, name);
                Navigator.pop(context);
              } else {
                // Handle the case where either bannerImage or profileImage is null
              }
            },
            child: Text('Save'),
          )

        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
          child: Column(
            children: [
              TextButton(
                onPressed: () => getImage(0),
                child: _profileImage == null ? Icon(Icons.person) : Image.file(_profileImage!, height: 100,),
              ),
              TextButton(
                onPressed: () => getImage(1),
                child: _bannerImage == null ? Icon(Icons.person) : Image.file(_bannerImage!, height: 100,),
              ),
              TextFormField(
                onChanged: (val) => setState(() {
                  name = val;
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
