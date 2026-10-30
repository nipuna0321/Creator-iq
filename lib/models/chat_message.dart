/// A message in the AI chat assistant conversation.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.time,
  });

  final String id;
  final String text;

  /// True for messages typed by the user, false for AI replies.
  final bool isUser;
  final DateTime time;
}
