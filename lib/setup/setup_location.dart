import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationSetupPage extends StatelessWidget {
  final VoidCallback onNext; // Define onNext callback

  LocationSetupPage({required this.onNext}); // Constructor with onNext parameter

  TextEditingController _locationController = TextEditingController();

  void saveLocation(BuildContext context) async {
    final location = _locationController.text.trim();

    if (location.isNotEmpty) {
      try {
        // Get current user
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // Store location in Firestore
          await FirebaseFirestore.instance.collection("Users").doc(user.uid).update({
            'location': location,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location saved successfully!')),
          );

          // Call onNext callback to proceed to the next page
          onNext();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not authenticated.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save location: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a location!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Enter your location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => saveLocation(context), // Pass context to saveLocation
              child: Text('Save Location'),
            ),
          ],
        ),
      ),
    );
  }
}
