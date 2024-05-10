

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/my_components/text_box.dart';

import '../my_components/drawer.dart';
import '../my_components/text_box.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //all user
  final userCollection = FirebaseFirestore.instance.collection("Users");

  //edit field
  Future<void> editField(String field) async {

    //declare variable to store username
    String newvalue = "";
    await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),

        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration:   InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey)
          ),
          onChanged: (value){
            newvalue = value;
          },
        ),

        actions: [
          //cancel button
          TextButton(
            child: Text(
              'cancel',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),

          //save button
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(newvalue),
          ),
        ],
      ),
    );


    //update in firestore = username only
    if (newvalue.trim().length>0){
      //only update if there something in text field
      await userCollection.doc(currentUser.email).update({field: newvalue});
    } 

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color.fromARGB(255, 200, 200, 200),
      //backgroundColor: Color.fromARGB(255, 255, 244, 93),
      appBar: AppBar(
        title: Text('Profile'),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.email).snapshots(),
        builder: (context, snapshot){
          //get user data
          //if user login or signin , do as below
          if(snapshot.hasData){
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [

                const SizedBox(height: 50),

                //profile pic
                const Icon(
                  Icons.person,
                  size: 80,
                ),

                const SizedBox(height: 30),

                //user email
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),

                const SizedBox(height: 50),


                //userdetails
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My details',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ),

                //username
                MyTextbox(
                  text: userData['username'],
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                  
                ),


                //bio
                MyTextbox(
                  text: userData['bio'],
                  sectionName: 'bio',
                  onPressed: () => editField('bio'),
                ),

                const SizedBox(height: 50),


                //user post
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Post',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ),



              ],
            );
            
          } else if(snapshot.hasError){
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
          

      ),

        drawer: MyDrawer(),

    );
  }
}
