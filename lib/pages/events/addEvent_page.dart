import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/loading,dart';
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
  bool _isLoading = false;
  DateTime? _selectedDate;

  List<String> categories = [
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

  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.title;
    _descriptionController.text = widget.description;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event Post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEventPost,
            child: Text('Post', style: TextStyle(color: Color.fromARGB(255, 245, 168, 35),
            fontWeight: FontWeight.bold, // Make the text bold
            fontSize: 17, // Optional: Adjust font size if needed
            )),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final selectedAddress =
                        await Navigator.push<Map<String, String>>(
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
                  child: Text("Add Location"),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color.fromARGB(255, 245, 168, 35),),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
                if (_selectedAddress != null) ...[
                  SizedBox(height: 8.0),
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
                SizedBox(height: 16.0),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                    text: _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : '',
                  ),
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(labelText: 'Select Date'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Text(category),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedCategory == category
                                ? Colors.blue
                                : Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: Icon(Icons.image),
                        label: Text('Add Image'),
                        onPressed: _pickImage,
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: Icon(Icons.delete),
                        label: Text('Remove All'),
                        onPressed: _clearImages,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _images.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                            icon: Icon(Icons.remove_circle),
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
          if (_isLoading)
            Center(
              child: CustomLoadingIndicator(),
            ),
        ],
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
    final streetName = _selectedAddress?['streetName'] ?? '';
    final town = _selectedAddress?['town'] ?? '';
    final region = _selectedAddress?['region'] ?? '';
    final state = _selectedAddress?['state'] ?? '';

    if (_validateFields(title, description, streetName, town, region, state)) {
      setState(() {
        _isLoading = true;
      });

      // Ensure _selectedDate is not null before accessing its properties
      int day = _selectedDate?.day ?? 0;
      int month = _selectedDate?.month ?? 0;
      int year = _selectedDate?.year ?? 0;

      await _postService.saveEventPost(
        title: title,
        description: description,
        category: _selectedCategory, // Use _selectedCategory instead of widget.category
        streetName: streetName,
        town: town,
        region: region,
        state: state,
        images: _images,
        day: day,
        month: month,
        year: year,
      );

      setState(() {
        _isLoading = false;
      });

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
