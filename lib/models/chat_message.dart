class ChatMessage {
  final int? id;
  final String message;
  final bool isSentByUser;

  ChatMessage({this.id, required this.message, required this.isSentByUser});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'isSentByUser': isSentByUser ? 1 : 0,
    };
  }
}
