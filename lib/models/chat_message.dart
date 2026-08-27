class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? stamp;
  bool isRead;
  bool isSystem; // ★システム通知フラグ

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.stamp,
    this.isRead = false,
    this.isSystem = false,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isMe': isMe,
    'timestamp': timestamp.toIso8601String(),
    'stamp': stamp,
    'isRead': isRead,
    'isSystem': isSystem,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'],
    isMe: json['isMe'],
    timestamp: DateTime.parse(json['timestamp']),
    stamp: json['stamp'],
    isRead: json['isRead'] ?? false,
    isSystem: json['isSystem'] ?? false,
  );
}
