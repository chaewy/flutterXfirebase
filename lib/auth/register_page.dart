import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {

  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final VoidCallback showloginpage; 
  const RegisterPage({
    Key? key,
    required this.showloginpage,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  //text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //create a user
  Future signUp() async{
    UserCredential userCredential = await  FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(), 
      password: _passwordController.text.trim(),
      );

    //after create the user, create a documents
    FirebaseFirestore.instance
    .collection("Users")
    .doc(userCredential.user!.uid) // TUKAR
    .set({
      'uid':userCredential.user!.uid, //tambah for uid
      'email': userCredential.user!.email,
      'name': _emailController.text.split('@')[0],
      'bannerImageUrl': 'https://firebasestorage.googleapis.com/v0/b/hobby-b1c8b.appspot.com/o/default%2Fdownload.png?alt=media&token=3a86e147-621c-4d06-9f49-287a693170ae',
      'profileImageUrl': 'https://firebasestorage.googleapis.com/v0/b/hobby-b1c8b.appspot.com/o/default%2Fdefault_profile_icon.jpg?alt=media&token=4d751354-0697-4c92-90ee-a58a565f0281',
      'bio': '',
    });

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
              // Hello again
              Text(
                "Hello There",
                style: GoogleFonts.bebasNeue(
                  fontSize: 54,
                ),
              ),
            
                SizedBox(height: 10),
            
                Text(
                "Register below with your details!",
                style: TextStyle( 
                  fontSize: 20,
                  ),
                ),
            
                SizedBox(height: 50),
            
            
              
              // email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color:  Colors.grey[200],
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
            
              // password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color:  Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password",
                      ),
                    ),
                  ),
                ),
              ),
            
              SizedBox(height: 15),
            
              //signin button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: signUp,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Sign Up ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
              SizedBox(height: 10),
            
              // not a member? mesti mau register meh
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
              )
            
            
            ],),
          ),
        ),
      )
    );
  }
}