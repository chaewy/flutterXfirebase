import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/firebase_api.dart';
import 'package:flutter_application_1/setup/setup_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showloginpage;

  const RegisterPage({
    Key? key,
    required this.showloginpage,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool isPasswordValid(String password) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
    return passwordRegex.hasMatch(password);
  }

  Future<void> signUp(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (!isEmailValid(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    if (!isPasswordValid(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must be at least 6 characters long and include both letters and numbers.')),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseApi = FirebaseApi();
      final fcmToken = await firebaseApi.getFCMToken();

      await FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': username,
        'bannerImageUrl': 'https://firebasestorage.googleapis.com/v0/b/hobby-b1c8b.appspot.com/o/default%2Fdownload.png?alt=media&token=3a86e147-621c-4d06-9f49-287a693170ae',
        'profileImageUrl': 'https://firebasestorage.googleapis.com/v0/b/hobby-b1c8b.appspot.com/o/default%2Fdefault_profile_icon.jpg?alt=media&token=4d751354-0697-4c92-90ee-a58a565f0281',
        'bio': '',
        'fcmToken': fcmToken,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully!')),
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('This email is already in use. Please use a different email address.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign up: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [



                 Image.network(
                  'https://firebasestorage.googleapis.com/v0/b/hobby-b1c8b.appspot.com/o/default%2FHobbyist%20Logo%202.png?alt=media&token=6e8a75f7-bb0c-4f0a-a78c-e1e3f634f6d4',
                  height: 70, // Adjust height as needed
                ),





                SizedBox(height: 10),
                Text(
                  "Register below with your details!",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Username",
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email",
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? FontAwesomeIcons.eye
                                  : FontAwesomeIcons.eyeSlash,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: () async {
                      await signUp(context); // Await signUp function for async operation
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 237, 163, 43),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I am a member',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showloginpage,
                      child: Text(
                        ' Login Now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
