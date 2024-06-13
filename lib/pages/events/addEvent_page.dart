import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/pages/map_search.dart';

class AddEventPage extends StatefulWidget {
  final String title;
  final String description;
  final String category;

  const AddEventPage({
    Key? key,
    required this.title,
    required this.description,
    required this.category,
  }) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final picker = ImagePicker();
  final PostService _postService = PostService();
  List<File> _images = [];
  Map<String, String>? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    _descriptionController.text = widget.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event Post'),
        actions: [
          TextButton(
            onPressed: _saveEventPost,
            child: const Text('Post', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              },
              child: const Text("Add Location"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 243, 20, 154)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            if (_selectedAddress != null) ...[
              const SizedBox(height: 8.0),
              const Text(
                'Selected Address:',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4.0),
              Text(
                'Street Name: ${_selectedAddress!['streetName']}',
                style: const TextStyle(fontSize: 16.0),
              ),
              Text(
                'Town/City: ${_selectedAddress!['town']}',
                style: const TextStyle(fontSize: 16.0),
              ),
              Text(
                'Region: ${_selectedAddress!['region']}',
                style: const TextStyle(fontSize: 16.0),
              ),
              Text(
                'State: ${_selectedAddress!['state']}',
                style: const TextStyle(fontSize: 16.0),
              ),
            ],
            const SizedBox(height: 16.0),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            DropdownButtonFormField<String>(
              value: widget.category,
              onChanged: (String? newValue) {
                // Add your onChanged logic here if needed
              },
              decoration: const InputDecoration(labelText: 'Category'),
              items: <String>['Cooking', 'Drawing', 'Painting', 'Singing', 'Writing']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Add Image'),
                    onPressed: _pickImage,
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove All'),
                    onPressed: _clearImages,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Image.file(_images[index], fit: BoxFit.cover),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () => _removeImage(index),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
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

  Future<void> _saveEventPost() async {
  final title = _titleController.text;
  final description = _descriptionController.text;
  final category = widget.category;
  final streetName = _selectedAddress?['streetName'] ?? '';
  final town = _selectedAddress?['town'] ?? '';
  final region = _selectedAddress?['region'] ?? '';
  final state = _selectedAddress?['state'] ?? '';

  if (_validateFields(title, description, streetName, town, region, state)) {
    await _postService.saveEventPost(
      title: title,
      description: description,
      category: category,
      streetName: streetName,
      town: town,
      region: region,
      state: state,
      images: _images,
    );

    Navigator.pop(context);
  }
}


  bool _validateFields(String title, String description, String? streetName, String? town, String? region, String? state) {
    if (title.isEmpty || description.isEmpty || streetName == null || town == null || region == null || state == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and select an image')),
      );
      return false;
    }
    return true;
  }
}
