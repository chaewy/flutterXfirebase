import 'package:flutter/material.dart';
import 'package:flutter_application_1/setup/setup_hobby.dart';
import 'package:flutter_application_1/setup/setup_location.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({Key? key}) : super(key: key);

  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup Page'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          LocationSetupPage(
            onNext: () {
              // Callback function to handle navigation or next steps after location setup
              goToNextPage();
            },
          ),
          HobbySetupPage(),
        ],
      ),
    );
  }

  void goToNextPage() {
    // Function to navigate to the next page (HobbySetupPage)
    _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
  }
}
