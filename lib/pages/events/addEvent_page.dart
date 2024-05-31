import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/services/add_post.dart';

class AddEventPage extends StatefulWidget {
  final String title;
  final String description;
  final String category;
  final String state;
  final String city;

  const AddEventPage({
    Key? key,
    required this.title,
    required this.description,
    required this.category,
    required this.state,
    required this.city,
  }) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final PostService _postService = PostService();
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize text fields with passed values
    _titleController.text = '';
    _descriptionController.text = '';
    _stateController.text = '';
    _cityController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event Post'),
        actions: [
          TextButton(
            onPressed: _saveEventPost,
            child: Text('Post', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            DropdownButtonFormField<String>(
              value: widget.category,
              onChanged: (String? newValue) {
                // Add your onChanged logic here if needed
              },
              decoration: InputDecoration(labelText: 'Category'),
              items: <String>['Cooking', 'Drawing', 'Painting', 'Singing', 'Writing']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _stateController,
              decoration: InputDecoration(labelText: 'State'),
            ),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            SizedBox(height: 10),
            _image == null
                ? TextButton.icon(
                    icon: Icon(Icons.image),
                    label: Text('Pick Image'),
                    onPressed: _pickImage,
                  )
                : Image.file(_image!),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveEventPost() async {
    // Extract values from text fields and save event post using _postService.saveEventPost
    final title = _titleController.text;
    final description = _descriptionController.text;
    final category = widget.category;
    final state = _stateController.text;
    final city = _cityController.text;

    if (_validateFields(title, description, state, city)) {
      await _postService.saveEventPost(
        title: title,
        description: description,
        category: category,
        state: state,
        city: city,
        image: _image!,
      );

      Navigator.pop(context);
    }
  }

  bool _validateFields(
    String title,
    String description,
    String state,
    String city,
  ) {
    if (title.isEmpty || description.isEmpty || state.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select an image')),
      );
      return false;
    }
    return true;
  }
}
