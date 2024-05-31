import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/add_post.dart';

class AddHomePage extends StatefulWidget {
  final String text;
  final String selectedCategory;

  const AddHomePage({
    Key? key, 
    required this.text, 
    required this.selectedCategory
    }) : super(key: key);

  @override
  State<AddHomePage> createState() => _AddHomePageState();
}

class _AddHomePageState extends State<AddHomePage> {
  final PostService _postService = PostService();
  String text = '';
  String selectedCategory = 'Cooking'; // Default category

  @override
  void initState() {
    super.initState();
    text = widget.text;
    selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Home Post'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              _postService.savePost(text, selectedCategory);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              textStyle: TextStyle(color: Colors.white),
            ),
            child: Text('Post'),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          children: [
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
                  text = val;
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter your post',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
