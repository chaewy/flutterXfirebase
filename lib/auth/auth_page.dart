import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/register_page.dart';
import 'package:flutter_application_1/pages/loginPage.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  // init show login page
  bool showloginpage = true;

  void togglScreens(){
    setState(() {
      showloginpage = !showloginpage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showloginpage){
      return LoginPage(showRegisterPage: togglScreens);
    }else{
      return RegisterPage(showloginpage: togglScreens);
    }
    
  }
}