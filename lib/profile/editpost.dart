import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/services/add_post.dart';

class EditPostPage extends StatefulWidget {
  final PostModel post;

  EditPostPage({required this.post});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<String> _imageUrls;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _descriptionController = TextEditingController(text: widget.post.description);
    _imageUrls = List.from(widget.post.imageUrls);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String imageUrl = await _uploadImage(imageFile);
      setState(() {
        _imageUrls.add(imageUrl);
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = FirebaseStorage.instance.ref().child("images/$fileName");
      UploadTask uploadTask = reference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  void _updatePost() {
    if (_formKey.currentState!.validate()) {
      PostModel updatedPost = PostModel(
        id: widget.post.id,
        creator: widget.post.creator,
        title: _titleController.text,
        imageUrls: _imageUrls,
        description: _descriptionController.text,
        timestamp: widget.post.timestamp,
        likeCount: widget.post.likeCount,
        ref: widget.post.ref,
      );

      PostService().updatePost(updatedPost).then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
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
              SizedBox(height: 16),
              Text('Images:'),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(_imageUrls[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _imageUrls.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Text('Add Image from Gallery'),
              ),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: Text('Add Image from Camera'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updatePost,
                child: Text('Update Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
