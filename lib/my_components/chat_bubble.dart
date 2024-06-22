import 'package:flutter/material.dart';
import 'package:flutter_application_1/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String? imageUrl; // Optional imageUrl parameter
  final String? fileUrl;  // Optional fileUrl parameter

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.imageUrl,
    this.fileUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser
            ? (isDarkMode ? Colors.yellow : Colors.grey.shade200)
            : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              width: 200, // Adjust width as needed
            ),
          if (fileUrl != null)
            InkWell(
              onTap: () {
                // Handle file tap action
              },
              child: Text(
                'File: $fileUrl',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          Text(
            message,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
