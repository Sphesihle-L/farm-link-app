class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'chatId': chatId,
    'senderId': senderId,
    'receiverId': receiverId,
    'message': message,
    'timestamp': timestamp.toUtc().toIso8601String(),
  };

  factory ChatMessage.fromMap(String id, Map<String, dynamic> m) => ChatMessage(
    id: id,
    chatId: m['chatId'] as String? ?? '',
    senderId: m['senderId'] as String? ?? '',
    receiverId: m['receiverId'] as String? ?? '',
    message: m['message'] as String? ?? '',
    timestamp:
        DateTime.tryParse(m['timestamp'] as String? ?? '') ?? DateTime.now(),
  );
}
