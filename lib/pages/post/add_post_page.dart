import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/add_post.dart';

class Add extends StatefulWidget {
  final bool isEvent; // Add property to distinguish between home and event posts
  const Add({Key? key, required this.isEvent}) : super(key: key);

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final PostService _postService = PostService();
  String text = '';
  String selectedCategory = 'Cooking'; // Default category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEvent ? 'Add Event Post' : 'Add Post'), // Adjust title based on isEvent
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              if (widget.isEvent) {
                _postService.saveEventPost(text, selectedCategory); // Pass selected category to saveEventPost
              } else {
                _postService.savePost(text, selectedCategory); // Pass selected category to savePost
              }
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
