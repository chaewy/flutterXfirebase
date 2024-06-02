import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/services/add_post.dart';

class AddHomePage extends StatefulWidget {
  final String selectedCategory;

  const AddHomePage({
    Key? key,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  State<AddHomePage> createState() => _AddHomePageState();
}

class _AddHomePageState extends State<AddHomePage> {
  final PostService _postService = PostService();
  final ImagePicker _picker = ImagePicker();
  String title = '';
  String description = '';
  List<File> _images = [];
  String selectedCategory = 'Cooking';

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
  }

  Future<void> _pickImage(ImageSource imageSource) async {
  final pickedFile = await _picker.pickImage(source: imageSource);

  if (pickedFile != null) {
    setState(() {
      _images.add(File(pickedFile.path));
    });
  }
}

Future<void> _savePost() async {
  if (title.isEmpty || description.isEmpty || _images.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill in all fields and select at least one image')),
    );
    return;
  }

  try {
    await _postService.savePost(title, description, _images, selectedCategory);
    Navigator.pop(context);
  } catch (e) {
    print('Error saving post: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving post')),
    );
  }
}

Widget _buildImagePreview() {
  return Wrap(
    spacing: 8.0,
    runSpacing: 8.0,
    children: _images.map((image) {
      return Stack(
        children: [
          Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.remove_circle),
              onPressed: () {
                setState(() {
                  _images.remove(image);
                });
              },
            ),
          ),
        ],
      );
    }).toList(),
  );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Add Home Post'),
      actions: <Widget>[
        TextButton(
          onPressed: _savePost,
          style: TextButton.styleFrom(
            textStyle: TextStyle(color: Colors.white),
          ),
          child: Text('Post'),
        )
      ],
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        children: [
          TextFormField(
            onChanged: (val) {
              setState(() {
                title = val;
              });
            },
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue!;
              });
            },
            items: <String>['Cooking', 'Drawing', 'Painting', 'Singing', 'Writing']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          TextFormField(
            onChanged: (val) {
              setState(() {
                description = val;
              });
            },
            decoration: InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: null,
          ),
          SizedBox(height: 20),
          _images.isEmpty
              ? Text('No image selected.')
              : _buildImagePreview(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: Icon(Icons.camera),
                label: Text('Camera'),
              ),
              SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: Icon(Icons.photo_library),
                label: Text('Gallery'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}