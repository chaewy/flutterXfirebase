import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/map_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/services/add_post.dart';

class AddEventPage extends StatefulWidget {
  final String title;
  final String description;
  final String category;
  final String streetName;
  final String town;
  final String region;
  final String state;
  //streetName , town, region and state 

  const AddEventPage({
    Key? key,
    required this.title,
    required this.description,
    required this.category,
    required this.streetName,
    required this.town,
    required this.region,
    required this.state,
  }) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final PostService _postService = PostService();
  File? _image;
  final picker = ImagePicker();
  Map<String, String>? _selectedAddress; // Update the type

  @override
  void initState() {
    super.initState();
    // Initialize text fields with passed values
    _titleController.text = '';
    _descriptionController.text = '';

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
                // Remove the old code that updates _selectedAddress
              },
              child: const Text("Add Location"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 243, 20, 154)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            if (_selectedAddress != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
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
            ),


            
        
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
            // TextField(
            //   controller: _addressController,
            //   decoration: InputDecoration(labelText: 'address'),
            // ),
            
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
  
  final streetName = _selectedAddress?['streetName'] ?? '';
  final town = _selectedAddress?['town'] ?? '';
  final region = _selectedAddress?['region'] ?? '';
  final state = _selectedAddress?['state'] ?? '';

  if (_validateFields(title, description, streetName, town, region, state )) {
    await _postService.saveEventPost(
      //streetName , town, region and state 
      title: title,
      description: description,
      category: category,
      streetName: streetName,
      town: town,
      region: region,
      state: state,
      image: _image!,
    );

    Navigator.pop(context);
  }
}


  bool _validateFields(String title, String description, String? streetName, String? town, String? region, String? state) {
  if (title.isEmpty || description.isEmpty || streetName == null || town == null || region == null || state == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select an image')),
      );
      return false;
    }
    return true;
  }
}


