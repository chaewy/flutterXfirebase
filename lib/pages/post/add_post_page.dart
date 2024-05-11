
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/add_post.dart';


//  tO ADD POST 
class Add extends StatefulWidget {
  const Add({Key? key}) : super(key: key);

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {

  final PostService _postService = PostService();
  String text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              _postService.savePost(text);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              textStyle: TextStyle(color: Colors.white), // Sets the text color to white
            ),
            child: Text('Post'),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: new Form(
          child: TextFormField(
            onChanged: (val){
              setState(() {
                text = val;
                
              });
            },
          )),
      ),
    );
  }
}