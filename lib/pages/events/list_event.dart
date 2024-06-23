// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/models/event.dart';
// import 'package:flutter_application_1/models/user.dart';
// import 'package:flutter_application_1/pages/events/eventDetails_page.dart';
// import 'package:flutter_application_1/pages/post/FullImage_page.dart';
// import 'package:flutter_application_1/services/add_post.dart';
// import 'package:flutter_application_1/services/user.dart';

// class ListEvent extends StatelessWidget {
//   final PostService _postService = PostService();
//   final UserService _userService = UserService();
//   final String category;

//   ListEvent({Key? key, required this.category}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: StreamBuilder<List<EventModel>>(
//           stream: _postService.getEventPosts(category),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               print('Error retrieving event posts: ${snapshot.error}');
//               return Center(child: Text('An error occurred: ${snapshot.error}. Please try again later.'));
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return Center(child: Text('No event posts found.'));
//             } else {
//               List<EventModel> eventPosts = snapshot.data!;
//               return Row(
//                 children: eventPosts.map((eventPost) {
//                   return StreamBuilder<UserModel>(
//                     stream: _userService.getUserInfo(eventPost.creator),
//                     builder: (context, userSnapshot) {
//                       if (userSnapshot.connectionState == ConnectionState.waiting) {
//                         return SizedBox.shrink();
//                       } else if (userSnapshot.hasError) {
//                         print('Error retrieving user info: ${userSnapshot.error}');
//                         return SizedBox.shrink();
//                       } else if (!userSnapshot.hasData) {
//                         print('User info not found.');
//                         return SizedBox.shrink();
//                       } else {
//                         final user = userSnapshot.data!;
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
//                           child: GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => EventDetails(event: eventPost),
//                                 ),
//                               );
//                             },
//                             child: SizedBox(
//                               width: MediaQuery.of(context).size.width * 0.4,
//                               child: Card(
//                                 elevation: 3,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     _buildImageList(context, eventPost.imageUrl),
//                                     Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Text(
//                                             eventPost.title,
//                                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                                             overflow: TextOverflow.ellipsis,
//                                             maxLines: 1,
//                                           ),
//                                           SizedBox(height: 4),
//                                           Row(
//                                             children: [
//                                               Icon(Icons.location_on, size: 14),
//                                               SizedBox(width: 4),
//                                               Expanded(
//                                                 child: Text(
//                                                   "${eventPost.region}, ${eventPost.state}",
//                                                   style: TextStyle(color: Colors.grey, fontSize: 12),
//                                                   overflow: TextOverflow.ellipsis,
//                                                   maxLines: 1,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                           SizedBox(height: 4),
//                                           Text(
//                                             eventPost.description,
//                                             style: TextStyle(color: Colors.black87, fontSize: 12),
//                                             overflow: TextOverflow.ellipsis,
//                                             maxLines: 2,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                   );
//                 }).toList(),
//               );
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildImageList(BuildContext context, List<String> imageUrl) {
//     if (imageUrl.length == 1) {
//       return GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => FullImagePage(imageUrl: imageUrl.first),
//             ),
//           );
//         },
//         child: Center(
//           child: Image.network(
//             imageUrl.first,
//             fit: BoxFit.cover,
//             height: MediaQuery.of(context).size.height * 0.15, // Adjusted height
//             width: double.infinity, // Full width to avoid empty space
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         height: MediaQuery.of(context).size.height * 0.15, // Adjusted height
//         child: PageView.builder(
//           scrollDirection: Axis.horizontal,
//           itemCount: imageUrl.length,
//           itemBuilder: (context, index) {
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => FullImagePage(imageUrl: imageUrl[index]),
//                   ),
//                 );
//               },
//               child: Image.network(
//                 imageUrl[index],
//                 fit: BoxFit.cover,
//                 width: double.infinity, // Full width to avoid empty space
//               ),
//             );
//           },
//         ),
//       );
//     }
//   }
// }
