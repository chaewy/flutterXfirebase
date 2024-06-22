import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String? receiverID; // Make receiverID optional
  final String message;
  final String? imageUrl; // Optional imageUrl field
  final String? fileUrl; // Optional fileUrl field
  final Timestamp timestamp;

  Message({
    required this.senderID,
    required this.senderEmail,
    this.receiverID,
    required this.message,
    this.imageUrl,
    this.fileUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'timestamp': timestamp,
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'],
      senderEmail: map['senderEmail'],
      receiverID: map['receiverID'],
      message: map['message'],
      imageUrl: map['imageUrl'],
      fileUrl: map['fileUrl'],
      timestamp: map['timestamp'],
    );
  }
}
