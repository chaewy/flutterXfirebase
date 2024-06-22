class ReplyCommentModel {
  String author;
  String text;

  ReplyCommentModel({required this.author, required this.text});

  // Optional: Add a method to create an instance from a map (for example, from JSON)
  factory ReplyCommentModel.fromMap(Map<String, dynamic> map) {
    return ReplyCommentModel(
      author: map['author'],
      text: map['text'],
    );
  }

  // Optional: Add a method to convert an instance to a map (for example, for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'text': text,
    };
  }

  // Optional: Add a method to create a formatted string representation of the instance
  @override
  String toString() {
    return 'ReplyCommentModel(author: $author, text: $text)';
  }
}
