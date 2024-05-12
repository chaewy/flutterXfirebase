


import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/pages/post/list.dart';
import 'package:flutter_application_1/pages/profile_edit_page.dart';
import 'package:flutter_application_1/services/add_post.dart';
import 'package:flutter_application_1/services/user.dart';
import 'package:provider/provider.dart';

import '../my_components/drawer.dart';





class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  //show own post
  //PostService _postService = PostService();
  final _postService = PostService(); // Create an instance of PostService

  // for show profile
  UserService _userService = UserService();

  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //all user doc
  final userCollection = FirebaseFirestore.instance.collection("Users");

  ///////////////////////////////////////////////////////////////////////////////

  // //edit field
  // Future<void> editField(String field) async {

  //   //declare variable to store username
  //   String newvalue = "";
  //   await showDialog(
  //     context: context, 
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Colors.grey[800],
  //       title: Text(
  //         "Edit $field",
  //         style: const TextStyle(color: Colors.white),
  //       ),

  //       content: TextField(
  //         autofocus: true,
  //         style: TextStyle(color: Colors.white),
  //         decoration:   InputDecoration(
  //           hintText: "Enter new $field",
  //           hintStyle: TextStyle(color: Colors.grey)
  //         ),
  //         onChanged: (value){
  //           newvalue = value;
  //         },
  //       ),

  //       actions: [
  //         //cancel button
  //         TextButton(
  //           child: Text(
  //             'cancel',
  //             style: TextStyle(color: Colors.white),
  //           ),
  //           onPressed: () => Navigator.pop(context),
  //         ),

  //         //save button
  //         TextButton(
  //           child: Text(
  //             'Save',
  //             style: TextStyle(color: Colors.white),
  //           ),
  //           onPressed: () => Navigator.of(context).pop(newvalue),
  //         ),
  //       ],
  //     ),
  //   );


  //   //update in firestore = username only
  //   if (newvalue.trim().length>0){
  //     //only update if there something in text field
  //     await userCollection.doc(currentUser.email).update({field: newvalue});
  //   } 

  // }

  /////////////////////////////////////////////////////////////////////////////
  

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // If currentUser is null, show a loading indicator or return an empty container
      return CircularProgressIndicator(); // Example: Show loading indicator
    }

    return MultiProvider(
      providers: [
        StreamProvider<List<PostModel>>.value(
          value: _postService.getPostByUser(currentUser.uid),
          initialData: [],
        ),
        StreamProvider<UserModel>.value(
          value: _userService.getUserInfo(currentUser.email),
          initialData: UserModel(
            id: '',
            name: '',
            profileImageUrl: '',
            bannerImageUrl: '',
            email: '',
          ),
        ),

      ],



      //child: ListPost(),
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text('Profile'),
        //   elevation: 0,
        //   actions: [
        //     IconButton(
        //       icon: Icon(Icons.edit),
        //       onPressed: () {
        //         Navigator.push(context, MaterialPageRoute(builder: (context) => Edit()));
        //       },
        //     ),
        //   ],
        // ),

        drawer: MyDrawer(),

        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(headerSliverBuilder: (context, _){
          return [
            SliverAppBar(
              floating: false,
              pinned: true,
              expandedHeight: 130,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(Provider.of<UserModel>(context).bannerImageUrl ?? '' ,
                fit: BoxFit.cover,
                )
              ),
            ),
            SliverList(delegate: SliverChildListDelegate(
              [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.network(Provider.of<UserModel>(context).profileImageUrl ?? '' ,
                          height: 60,
                          fit: BoxFit.cover,
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Edit()),
                            );
                          }, 
                          child: Text('Edit profile')
                        )



                        ]),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(Provider.of<UserModel>(context).name ?? '' ,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),),

                            ),
                        )


    
                    ],),
                )
              ]
            ))



          ];



        },
        body: ListPost(),
        ),)






        // Your other widgets here
      ),
    );

        


        
        
        
        
        
      
  
  }
 
    
    
    
    
    
    
    
    
    
    
    
    
    // Scaffold(

    //   backgroundColor: Color.fromARGB(255, 200, 200, 200),
    //   //backgroundColor: Color.fromARGB(255, 255, 244, 93),
    //   appBar: AppBar(
    //     title: Text('Profile'),
    //   ),

    //   body: StreamBuilder<DocumentSnapshot>(
    //     stream: FirebaseFirestore.instance.collection("Users").doc(currentUser.email).snapshots(),
        

    //     builder: (context, snapshot){
    //       //get user data
    //       //if user login or signin , do as below
    //       if(snapshot.hasData){
    //         final userData = snapshot.data!.data() as Map<String, dynamic>;

    //         return ListView(
    //           children: [

    //             const SizedBox(height: 50),

    //             //profile pic
    //             const Icon(
    //               Icons.person,
    //               size: 80,
    //             ),

    //             const SizedBox(height: 30),

    //             //user email
    //             Text(
    //               currentUser.email!,
    //               textAlign: TextAlign.center,
    //               style: TextStyle(color: Colors.grey[700]),
    //             ),

    //             const SizedBox(height: 50),


    //             //userdetails
    //             Padding(
    //               padding: const EdgeInsets.only(left: 25.0),
    //               child: Text(
    //                 'My details',
    //                   style: TextStyle(color: Colors.grey[600]),
    //                 ),
    //             ),

    //             //username
    //             MyTextbox(
    //               text: userData['username'],
    //               sectionName: 'username',
    //               onPressed: () => editField('username'),
                  
    //             ),


    //             //bio
    //             MyTextbox(
    //               text: userData['bio'],
    //               sectionName: 'bio',
    //               onPressed: () => editField('bio'),
    //             ),

    //             const SizedBox(height: 50),


    //             //user post
    //             Padding(
    //               padding: const EdgeInsets.only(left: 25.0),
    //               child: Text(
    //                 'My Post',
    //                   style: TextStyle(color: Colors.grey[600]),
    //                 ),
    //             ),



    //           ],
    //         );
            
    //       } else if(snapshot.hasError){
    //         return Center(
    //           child: Text('Error${snapshot.error}'),
    //         );
    //       }

    //       return const Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     },
          

    //   ),

    //     drawer: MyDrawer(),

    // );







  }

