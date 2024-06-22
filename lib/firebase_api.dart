import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/pages/chat/chat_page.dart';
import 'package:flutter_application_1/pages/chat/event_chat_page.dart';

class FirebaseApi {


  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();



  final AndroidNotificationChannel _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: "This is used for important notifications",
    importance: Importance.defaultImportance,
  );

  void handleMessage(RemoteMessage? message) {
  if (message == null) return;

  final data = message.data;
  final String notificationType = data['type'] ?? '';

  if (notificationType == 'personal_chat') {
    Navigator.of(navigatorKey.currentContext!).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(
          receiverName: data['senderName'] ?? '',
          receiverID: data['senderId'] ?? '',
        ),
      ),
    );
  } else if (notificationType == 'event_chat') {
    Navigator.of(navigatorKey.currentContext!).push(
      MaterialPageRoute(
        builder: (context) => EventChatPage(
        eventID: data['eventId'] ?? '',
        eventName: data['eventName'] ?? '',
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------------------------------------------------------

  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings('@drawable/ic_launcher');
    final InitializationSettings settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          handleMessage(RemoteMessage.fromMap(jsonDecode(notificationResponse.payload!)));
        }
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (platform != null) {
      await platform.createNotificationChannel(_androidChannel);
    }
  }

// ------------------------------------------------------------------------------------------------------------------------

  Future<void> initNotifications() async {
  // Request permission for receiving notifications
  await _firebaseMessaging.requestPermission();

  // Retrieve the FCM token
  final fCMToken = await _firebaseMessaging.getToken();
  print("FCM Token: $fCMToken");

  // Listen for when a notification message is tapped/opened while the app is in the background
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

  // Initialize local notifications for Android
  initLocalNotifications();

  // Listen for incoming FCM messages and handle notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.defaultImportance,
          icon: '@drawable/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  });
}


// ------------------------------------------------------------------------------------------------------------------------


Future<String?> getFCMToken() async {
    String? fcmToken;

    // Request permission if not yet granted
    await _firebaseMessaging.requestPermission();

    try {
      fcmToken = await _firebaseMessaging.getToken();
    } catch (e) {
      // Handle error when getting FCM token
      print('Error getting FCM token: $e');
    }

    return fcmToken;
  }

// ------------------------------------------------------------------------------------------------------------------------

  Future<void> sendMessage(String senderId, String receiverId, String message, String type) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference chatCollection = firestore.collection('chat').doc(receiverId).collection('messages');

    DocumentSnapshot receiverSnapshot = await firestore.collection('Users').doc(receiverId).get();

    if (receiverSnapshot.exists && receiverSnapshot.data() != null) {
      String? receiverToken = receiverSnapshot['fcmToken'] as String?;

      if (receiverToken != null && receiverToken.isNotEmpty) {
        await chatCollection.add({
          'senderId': senderId,
          'receiverId': receiverId,
          'message': message,
          'type': type,
          'timestamp': FieldValue.serverTimestamp(),
        });

        print('Sending notification to receiver with token: $receiverToken');
        sendNotification(receiverToken, 'New Message', message, type, senderId);
      } else {
        print('Receiver does not have a valid FCM token');
      }
    } else {
      print('Receiver does not exist');
    }
  } catch (e) {
    print('Error sending message: $e');
  }
}

Future<void> sendNotification(String token, String title, String body, String type, String senderId) async {
  try {


    final payload = {
      'to': token, 
      'notification': {
        'title': title,
        'body': body,
      },
      'data': {
        'type': type,
        'senderId': senderId,
      },
    };


    print('Sending notification to token: $token, with payload: $payload');
    _localNotifications.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.defaultImportance,
          icon: '@drawable/ic_launcher',
        ),
      ),
      payload: jsonEncode(payload),
    );
  } catch (e) {
    print('Failed to send notification: $e');
  }
}



 Future<void> sendEventMessage(String senderId, String eventId, String message) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference events = firestore.collection('events');
    final CollectionReference users = firestore.collection('users');
    final CollectionReference eventChats = firestore.collection('eventChats');

    try {
      DocumentSnapshot eventSnapshot = await events.doc(eventId).get();
      List<String> participantIds = List<String>.from(eventSnapshot['participants']);

      for (String participantId in participantIds) {
        if (participantId != senderId) {
          try {
            DocumentSnapshot participantSnapshot = await users.doc(participantId).get();
            String? participantToken = participantSnapshot.get('fcmToken') as String?;

            if (participantToken != null && participantToken.isNotEmpty) {
              await eventChats.add({
                'senderId': senderId,
                'eventId': eventId,
                'message': message,
                'timestamp': FieldValue.serverTimestamp(),
              });

              sendNotification(participantToken, 'New Event Message', message, 'event_chat', eventId);
            } else {
              print('Participant $participantId does not have a valid FCM token');
            }
          } catch (e) {
            print('Error fetching participant $participantId details: $e');
          }
        }
      }
    } catch (e) {
      print('Error fetching event $eventId details: $e');
    }
  }
}
  






