import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/event.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:image_picker/image_picker.dart';

class EditEventPage extends StatefulWidget {
  final EventModel event;

  EditEventPage({required this.event});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();
  final TextEditingController _townController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  List<String> _imageUrls = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.event.title;
    _descriptionController.text = widget.event.description;
    _categoryController.text = widget.event.category;
    _streetNameController.text = widget.event.streetName;
    _townController.text = widget.event.town;
    _regionController.text = widget.event.region;
    _stateController.text = widget.event.state;
    _imageUrls.addAll(widget.event.imageUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _streetNameController.dispose();
    _townController.dispose();
    _regionController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _streetNameController.text.isEmpty ||
        _townController.text.isEmpty ||
        _regionController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _imageUrls.isEmpty) {
      _showErrorDialog('Please fill all fields and add at least one image.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await PostService().updateEvent(
        eventId: widget.event.id,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        streetName: _streetNameController.text,
        town: _townController.text,
        region: _regionController.text,
        state: _stateController.text,
        imageUrl: _imageUrls,
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error updating event: $e');
      _showErrorDialog('Error updating event. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        for (var image in images) {
          String downloadUrl = await PostService().uploadImage(File(image.path));
          _imageUrls.add(downloadUrl);
        }
      } catch (e) {
        print('Error uploading image: $e');
        _showErrorDialog('Error uploading image. Please try again.');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeImage(String imageUrl) {
    setState(() {
      _imageUrls.remove(imageUrl);
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
        title: const Text('Edit Event'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(labelText: 'Category'),
                    ),
                    TextField(
                      controller: _streetNameController,
                      decoration: InputDecoration(labelText: 'Street Name'),
                    ),
                    TextField(
                      controller: _townController,
                      decoration: InputDecoration(labelText: 'Town'),
                    ),
                    TextField(
                      controller: _regionController,
                      decoration: InputDecoration(labelText: 'Region'),
                    ),
                    TextField(
                      controller: _stateController,
                      decoration: InputDecoration(labelText: 'State'),
                    ),
                    const SizedBox(height: 20),
                    Text('Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index) {
                          final imageUrl = _imageUrls[index];
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Image.network(
                                  imageUrl,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeImage(imageUrl),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Add Images'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
