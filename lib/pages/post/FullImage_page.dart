import 'package:flutter/material.dart';

class FullImagePage extends StatelessWidget {
  final String imageUrl;

  FullImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        backgroundColor: Colors.black, // Set app bar background to black
        iconTheme: IconThemeData(
          color: Colors.white, // Set back button color to white
        ),
        title: Text(
          'Full Image',
          style: TextStyle(color: Colors.white), // Set app bar title color to white
        ),
      ),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
