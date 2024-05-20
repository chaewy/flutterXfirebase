

import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/post/list_home.dart';



class Feed extends StatefulWidget {
  Feed({Key? key}) : super(key: key);

  @override
  FeedState createState() => FeedState();
}

class FeedState extends State<Feed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListPost(),
    );
  }
}
