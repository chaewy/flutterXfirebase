import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/events/addEvent_page.dart';
import 'package:flutter_application_1/pages/post/addHomePost_page.dart';


class Add extends StatefulWidget {
  final bool isEvent;
  const Add({Key? key, required this.isEvent}) : super(key: key);

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  @override
  Widget build(BuildContext context) {
    if (widget.isEvent) {
      return AddEventPage(
        title: '',
        description: '',
        category: 'Cooking',
        state: '',
        city: '',
      );
    } else {
      return AddHomePage(
        selectedCategory: 'Cooking',
      );
    }
  }
}