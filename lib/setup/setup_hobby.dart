import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/home_page.dart';

class HobbySetupPage extends StatefulWidget {
  @override
  _HobbySetupPageState createState() => _HobbySetupPageState();
}

class _HobbySetupPageState extends State<HobbySetupPage> {
  List<String> selectedHobbies = [];
  List<String> allHobbies = [
    'Reading',
    'Traveling',
    'Cooking',
    'Gaming',
    'Fitness',
    'Photography',
    'Painting',
    'Music',
    'Sports',
    'Writing',
  ];

  void toggleHobby(String hobby) {
    setState(() {
      if (selectedHobbies.contains(hobby)) {
        selectedHobbies.remove(hobby);
      } else {
        selectedHobbies.add(hobby);
      }
    });
  }

  void finishSetup() {
    // Navigate to HomePage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hobby Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your hobbies:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: allHobbies.length,
                itemBuilder: (context, index) {
                  final hobby = allHobbies[index];
                  return CheckboxListTile(
                    title: Text(hobby),
                    value: selectedHobbies.contains(hobby),
                    onChanged: (bool? value) {
                      toggleHobby(hobby);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: finishSetup,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 16.0),
                child: Text(
                  'Finish',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
