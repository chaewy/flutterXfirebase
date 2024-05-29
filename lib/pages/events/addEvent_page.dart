import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/add_post.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({Key? key}) : super(key: key);

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final PostService _postService = PostService();
  String text = '';
  String selectedCategory = 'Cooking'; // Default category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event Post'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              _postService.saveEventPost(text, selectedCategory); // Pass selected category to saveEventPost
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
                labelText: 'Enter your event post',
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
