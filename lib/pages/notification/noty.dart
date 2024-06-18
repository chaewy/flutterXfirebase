import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  final RemoteMessage? message; // Make message nullable

  const NotificationPage({Key? key, this.message}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    final message = widget.message;

    return Scaffold(
      body: Center(
        child: message != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Title: ${message.notification?.title ?? "No Title"}'),
                  Text('Body: ${message.notification?.body ?? "No Body"}'),
                  Text('Payload: ${message.data}'),
                ],
              )
            : const Text('No message received'),
      ),
    );
  }
}
