import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String personality;
  final VoidCallback? onDelete;
  final Color themeColor; // ★1. テーマ色を受け取るように追加

  const ChatBubble({
    super.key,
    required this.message,
    required this.personality,
    required this.themeColor, // ★2. ここにも追加
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
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            // ★3. 枠線のピンクをテーマ色に変更
            border: Border.all(color: themeColor.withValues(alpha: 0.1)),
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

    // --- 吹き出しの色決定ロジック ---
    Color bubbleColor;
    if (message.isMe) {
      bubbleColor = const Color(0xFFDCF8C6).withValues(alpha: 0.95);
    } else {
      // ★4. テーマが「青」の時は、性格に関わらず青系の吹き出しにする
      if (themeColor != Colors.pinkAccent) {
        bubbleColor = themeColor.withValues(alpha: 0.12);
      } else {
        // テーマが「ピンク」の時は、今までの性格ごとの色を使う
        if (personality == "クールなお姉さん") {
          bubbleColor = const Color(0xFFE0F7FA).withValues(alpha: 0.95);
        } else if (personality == "ツンデレ") {
          bubbleColor = const Color(0xFFFFF3E0).withValues(alpha: 0.95);
        } else {
          bubbleColor = const Color(0xFFFFE4E1).withValues(alpha: 0.95);
        }
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
                    // ★5. エラー時のアイコン色もテーマ色に
                    errorBuilder: (c, e, s) =>
                        Icon(Icons.face, color: themeColor),
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
            Text(
              "既読",
              style: TextStyle(
                fontSize: 10,
                color: themeColor, // ★6. 「既読」のピンクをテーマ色に変更
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
