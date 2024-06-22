import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: FacebookPostPage(),
  ));
}

class FacebookPostPage extends StatefulWidget {
  const FacebookPostPage({Key? key}) : super(key: key);

  @override
  _FacebookPostPageState createState() => _FacebookPostPageState();
}

class _FacebookPostPageState extends State<FacebookPostPage> {
  bool isExpanded = false; // Track expansion state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facebook Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Your existing UI code here...
            // Second row: Title
            Text(
              'Sample Post Title', // Replace with actual post title
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),

            // Third row: Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://via.placeholder.com/400', // Replace with actual image URL
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 12),

            // Fourth row: Like, comment, share buttons (dummy example)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(Icons.thumb_up, 'Like', () {
                  // Handle like button press
                }),
                _buildButton(Icons.mode_comment, 'Comment', () {
                  // Handle comment button press
                }),
                _buildButton(Icons.share, 'Share', () {
                  // Handle share button press
                }),
              ],
            ),
            // SizedBox(height: 12),

            // Fifth row: Comments and replies (expanded/collapsible)
            Expanded(
              child: ListView(
                children: [
                  _buildComment(
                    'Jane Smith',
                    'This is a great post!',
                    [
                      _buildReply('John Doe', 'Thanks, Jane!'),
                      _buildReply('Alice', 'Nice post!'),
                    ],
                    // Replace with actual comment ID if needed
                    commentId: 'comment_1',
                  ),
                  _buildComment(
                    'Michael Johnson',
                    'Awesome photo!',
                    [],
                    // Replace with actual comment ID if needed
                    commentId: 'comment_2',
                  ),
                  // Add more comments as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.grey[700]),
      label: Text(
        label,
        style: TextStyle(color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildComment(String author, String text, List<Widget> replies,
      {required String commentId}) {
    TextEditingController replyController = TextEditingController();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '$author:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
            if (replies.isNotEmpty)
              ExpansionTile(
                title: Text(
                  'View ${replies.length} replies',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
                children: replies,
                onExpansionChanged: (expanded) {
                  setState(() {
                    isExpanded = expanded; // Update expansion state
                  });
                },
              ),
            if (isExpanded) // Show reply UI only when expanded
              Column(
                children: [
                  SizedBox(height: 12),
                  // Reply Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: TextField(
                            controller: replyController,
                            decoration: InputDecoration(
                              hintText: 'Reply...',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            minLines: 1,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () {
                          // Handle reply submission
                          String replyText = replyController.text;
                          if (replyText.isNotEmpty) {
                            // Add the new reply widget to the list
                            _addReply(commentId, _buildReply('Current User', replyText));
                            // Clear the reply text field
                            replyController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                        child: Text(
                          'Reply',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _addReply(String commentId, Widget newReply) {
    // Logic to add the new reply to the appropriate comment
    // For demonstration, we'll simply update the UI locally
    // In a real app, this would involve updating state or sending data to backend
    // Assuming a simple local list of comments for demonstration purpose
    // You may need to manage state using Provider, Bloc, or similar approach
  }

  Widget _buildReply(String author, String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.grey[200],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(
                'https://via.placeholder.com/150'), // Replace with actual image URL
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 2),
              Text(
                text,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
