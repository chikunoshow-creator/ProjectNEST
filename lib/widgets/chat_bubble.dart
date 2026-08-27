// lib/widgets/chat_bubble.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String personality;
  final VoidCallback? onDelete;

  const ChatBubble({
    super.key,
    required this.message,
    required this.personality,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            // システムメッセージを少しだけピンクがかった白に
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.1)),
          ),
          child: Text(
            message.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black45,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    // 性格に合わせた色の設定
    Color bubbleColor;
    if (message.isMe) {
      bubbleColor = const Color(0xFFDCF8C6).withValues(alpha: 0.95);
    } else {
      if (personality == "クールなお姉さん") {
        bubbleColor = const Color(0xFFE0F7FA).withValues(alpha: 0.95);
      } else if (personality == "ツンデレ") {
        bubbleColor = const Color(0xFFFFF3E0).withValues(alpha: 0.95);
      } else {
        bubbleColor = const Color(0xFFFFE4E1).withValues(alpha: 0.95);
      }
    }

    String charPrefix = personality == "クールなお姉さん"
        ? "goki"
        : (personality == "ツンデレ" ? "sayo" : "hau");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    "assets/images/${charPrefix}_icon.png",
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.face, color: Colors.pinkAccent),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          if (message.isMe) ...[_buildTimeAndRead(), const SizedBox(width: 8)],

          Flexible(
            child: GestureDetector(
              onLongPress: onDelete,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(message.isMe ? 20 : 6),
                    bottomRight: Radius.circular(message.isMe ? 6 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SelectableText(
                  message.text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),

          if (!message.isMe) ...[const SizedBox(width: 8), _buildTimeAndRead()],
        ],
      ),
    );
  }

  Widget _buildTimeAndRead() {
    String timeText = DateFormat('HH:mm').format(message.timestamp);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: message.isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (message.isMe && message.isRead)
            const Text(
              "既読",
              style: TextStyle(
                fontSize: 10,
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          Text(
            timeText,
            style: const TextStyle(fontSize: 10, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
