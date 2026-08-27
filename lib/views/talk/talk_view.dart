import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../models/chat_message.dart';
import '../../widgets/chat_bubble.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

class TalkView extends StatefulWidget {
  final List<ChatMessage> messages;
  final ReplyService replyService;
  final ScrollController scrollController;
  final TextEditingController chatController;
  final bool isTyping;
  final SpeechToText speechToText;
  final VoidCallback onSend;
  final VoidCallback onMicStart;
  final VoidCallback onMicEnd;
  final Function(int) onDeleteMessage;
  // backgroundはChatPageから渡されますが、TalkView側で壁紙ロジックを優先させます
  final Widget background;

  const TalkView({
    super.key,
    required this.messages,
    required this.replyService,
    required this.scrollController,
    required this.chatController,
    required this.isTyping,
    required this.speechToText,
    required this.onSend,
    required this.onMicStart,
    required this.onMicEnd,
    required this.onDeleteMessage,
    required this.background,
  });

  @override
  State<TalkView> createState() => _TalkViewState();
}

class _TalkViewState extends State<TalkView> {
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!widget.scrollController.hasClients) return;
    final offset = widget.scrollController.offset;
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final isFarFromBottom = offset < maxScroll - 200;

    if (isFarFromBottom != _showScrollButton) {
      setState(() => _showScrollButton = isFarFromBottom);
    }
  }

  void _scrollToBottom() {
    widget.scrollController.animateTo(
      widget.scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ★ 壁紙ロジックの修正：getAllBackgrounds からパスを検索するように変更
    final backgrounds = widget.replyService.getAllBackgrounds();
    final selectedBgData = backgrounds.firstWhere(
      (bg) => bg['id'] == widget.replyService.selectedBg,
      orElse: () => {"path": ""},
    );
    Widget wallpaper = widget.replyService.selectedBg == "default"
        ? Container(color: const Color(0xFFFFF0F5))
        : Image.asset(
            selectedBgData['path'],
            fit: BoxFit.cover,
            // ★ トーク画面でも上部を優先的に表示
            alignment: const Alignment(0, -0.7),
            errorBuilder: (c, e, s) =>
                Container(color: const Color(0xFFFFF0F5)),
          );
    return Stack(
      children: [
        Positioned.fill(child: wallpaper),
        // 2. メインコンテンツ
        Column(
          children: [
            // AppBarとの重なりを防ぐ余白
            const SizedBox(height: 90),

            // チャットリスト
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 20,
                ),
                itemCount: widget.messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(
                    message: widget.messages[index],
                    personality: widget.replyService.personality,
                    onDelete: () => _showDeleteConfirm(context, index),
                  );
                },
              ),
            ),

            // 入力中インジケーター
            if (widget.isTyping) _buildTypingIndicator(),

            // 絵文字と入力エリア
            _buildBottomControls(),
          ],
        ),

        // 3. 最新へ戻るボタン
        if (_showScrollButton)
          Positioned(
            bottom: 130,
            right: 20,
            child: FloatingActionButton.small(
              heroTag: "scrollBtn",
              onPressed: _scrollToBottom,
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              foregroundColor: Colors.pinkAccent,
              elevation: 4,
              child: const Icon(Icons.keyboard_arrow_down),
            ),
          ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            "${widget.replyService.displayName}が入力中...",
            style: const TextStyle(
              color: Colors.pinkAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [_buildEmojiPalette(), _buildInputArea()],
      ),
    );
  }

  Widget _buildEmojiPalette() {
    final emojis = ["❤️", "😊", "🥺", "✨", "💤", "🎵", "💦", "💢"];
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: emojis.length,
        itemBuilder: (context, index) => InkWell(
          onTap: () => widget.chatController.text += emojis[index],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text(emojis[index], style: const TextStyle(fontSize: 22)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final lang = widget.replyService.language;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: widget.chatController,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  minLines: 1,
                  maxLines: 5, // 最大5行のこだわり
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline, // Enterで改行
                  decoration: InputDecoration(
                    hintText: T
                        .get('hint_msg', lang)
                        .replaceAll('{name}', widget.replyService.displayName),
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // マイクボタン
            _buildMicButton(),
            const SizedBox(width: 4),
            // 送信ボタン
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    bool isListening = widget.speechToText.isListening;
    return GestureDetector(
      onLongPressStart: (_) => widget.onMicStart(),
      onLongPressEnd: (_) => widget.onMicEnd(),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: isListening
              ? Colors.redAccent.withValues(alpha: 0.1)
              : Colors.transparent,
          shape: BoxShape.circle, // ★ BoxType から BoxShape に修正
        ),
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          color: isListening ? Colors.redAccent : Colors.grey[600],
          size: 26,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      height: 44,
      width: 44,
      margin: const EdgeInsets.only(bottom: 2),
      child: IconButton(
        icon: const Icon(
          Icons.send_rounded,
          color: Colors.pinkAccent,
          size: 28,
        ),
        onPressed: widget.onSend,
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, int index) {
    // 削除確認ダイアログ（デザイン統一）
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("思い出の整理"),
        content: const Text("このメッセージを消去してもいい？\n（あなたの画面からのみ消えます）"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("やめとく", style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteMessage(index);
              Navigator.pop(context);
            },
            child: const Text(
              "消去する",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
