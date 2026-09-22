import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../models/chat_message.dart';
import '../../widgets/chat_bubble.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

// ★ 選択モードの定義
enum SelectionMode { none, copy, delete }

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

  // ★ メッセージ選択モード管理用
  SelectionMode _selectionMode = SelectionMode.none;
  final Set<int> _selectedIndices = {};

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

  // --- 選択モードの制御メソッド ---

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = SelectionMode.none;
      _selectedIndices.clear();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIndices.length == widget.messages.length) {
        _selectedIndices.clear();
      } else {
        _selectedIndices.clear();
        for (int i = 0; i < widget.messages.length; i++) {
          _selectedIndices.add(i);
        }
      }
    });
  }

  // 長押し時のアクションバブル（ポップアップメニュー）表示
  void _showMessageActionMenu(
    BuildContext context,
    Offset position,
    int index,
  ) async {
    final lang = widget.replyService.language;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final selectedAction = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 40, 40),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      items: [
        PopupMenuItem<String>(
          value: 'copy',
          child: Row(
            children: [
              Icon(
                Icons.copy_rounded,
                size: 20,
                color: widget.replyService.themeColor,
              ),
              const SizedBox(width: 10),
              Text(T.get('action_copy', lang)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 10),
              Text(
                T.get('action_delete', lang),
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ],
    );

    if (!mounted || selectedAction == null) return;

    setState(() {
      _selectedIndices.clear();
      _selectedIndices.add(index);
      if (selectedAction == 'copy') {
        _selectionMode = SelectionMode.copy;
      } else if (selectedAction == 'delete') {
        _selectionMode = SelectionMode.delete;
      }
    });
  }

  // 一括コピー処理
  void _executeCopy() {
    if (_selectedIndices.isEmpty) return;
    final lang = widget.replyService.language;

    // 元の会話順（昇順）にソート
    final sortedIndices = _selectedIndices.toList()..sort();
    final buffer = StringBuffer();

    for (final idx in sortedIndices) {
      if (idx >= 0 && idx < widget.messages.length) {
        final msg = widget.messages[idx];
        if (msg.isSystem) continue;
        final speaker = msg.isMe
            ? widget.replyService.displayUserName
            : widget.replyService.displayName;
        buffer.writeln("$speaker：${msg.text}");
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString().trimRight()));
    _exitSelectionMode();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(T.get('copied_toast', lang)),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // まとめて削除の確認ダイアログ
  void _showBulkDeleteConfirm() {
    final count = _selectedIndices.length;
    if (count == 0) return;
    final lang = widget.replyService.language;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(T.get('delete_bulk_title', lang)),
        content: Text(
          T
              .get('delete_bulk_confirm', lang)
              .replaceAll('{count}', count.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              T.get('btn_cancel', lang),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _executeBulkDelete();
            },
            child: Text(
              T.get('action_delete', lang),
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 複数削除の安全な実行（降順に削除してインデックスズレを防止）
  void _executeBulkDelete() {
    final sortedDesc = _selectedIndices.toList()
      ..sort((a, b) => b.compareTo(a));
    for (final idx in sortedDesc) {
      widget.onDeleteMessage(idx);
    }
    _exitSelectionMode();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.replyService.themeColor;
    final scaffoldBg = widget.replyService.scaffoldBg;
    final isSelectionActive = _selectionMode != SelectionMode.none;

    final backgrounds = widget.replyService.getAllBackgrounds();
    final selectedBgData = backgrounds.firstWhere(
      (bg) => bg['id'] == widget.replyService.selectedBg,
      orElse: () => {"path": ""},
    );

    Widget wallpaper = widget.replyService.selectedBg == "default"
        ? Container(color: scaffoldBg)
        : Image.asset(
            selectedBgData['path'],
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.7),
            errorBuilder: (c, e, s) => Container(color: scaffoldBg),
          );

    return Stack(
      children: [
        Positioned.fill(child: wallpaper),
        Column(
          children: [
            // ★【修正点】浮かすのをやめ、親ヘッダーの直下に自然に挟み込む構造に変更
            if (isSelectionActive) ...[
              const SizedBox(height: 56), // 親ヘッダー「Project NEST」の高さ分だけ空ける
              _buildSelectionTopBar(themeColor), // その直下にピタッと配置
            ] else ...[
              const SizedBox(height: 90), // 通常時（メッセージ用の余白）
            ],

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
                    themeColor: themeColor,
                    isSelectionMode: isSelectionActive,
                    isSelected: _selectedIndices.contains(index),
                    onToggleSelect: () {
                      setState(() {
                        if (_selectedIndices.contains(index)) {
                          _selectedIndices.remove(index);
                        } else {
                          _selectedIndices.add(index);
                        }
                      });
                    },
                    onLongPressWithPosition: (pos) =>
                        _showMessageActionMenu(context, pos, index),
                  );
                },
              ),
            ),

            if (widget.isTyping && !isSelectionActive)
              _buildTypingIndicator(themeColor),

            // 選択モード中と通常時でボトムバーを完全切り替え
            if (isSelectionActive)
              _buildSelectionBottomBar(themeColor)
            else
              _buildBottomControls(),
          ],
        ),

        // 最新へ戻るボタン（通常時のみ表示）
        if (_showScrollButton && !isSelectionActive)
          Positioned(
            bottom: 130,
            right: 20,
            child: FloatingActionButton.small(
              heroTag: "scrollBtn",
              onPressed: _scrollToBottom,
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              foregroundColor: themeColor,
              elevation: 4,
              child: const Icon(Icons.keyboard_arrow_down),
            ),
          ),
      ],
    );
  }

  // --- トップバー（選択モード時：高さをスッキリ整え、＜と文字の中心を完全一致） ---
  Widget _buildSelectionTopBar(Color themeColor) {
    final lang = widget.replyService.language;
    final modeText = _selectionMode == SelectionMode.copy
        ? T.get('action_copy', lang)
        : T.get('action_delete', lang);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 「＜」と文字を一体化して、中心軸をピタッと合わせる
          InkWell(
            onTap: _exitSelectionMode,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    modeText,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _toggleSelectAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(
              T.get('select_all', lang),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ボトムバー（選択モード時） ---
  Widget _buildSelectionBottomBar(Color themeColor) {
    final lang = widget.replyService.language;
    final isCopy = _selectionMode == SelectionMode.copy;
    final actionText = isCopy
        ? T.get('action_copy', lang)
        : T.get('action_delete', lang);
    final count = _selectedIndices.length;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _exitSelectionMode,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              T.get('btn_cancel', lang),
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: count == 0
                ? null
                : (isCopy ? _executeCopy : _showBulkDeleteConfirm),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCopy ? themeColor : Colors.redAccent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[500],
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              "$actionText ($count)",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(Color themeColor) {
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
            style: TextStyle(
              color: themeColor,
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
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
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
            _buildMicButton(),
            const SizedBox(width: 4),
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
          shape: BoxShape.circle,
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
        icon: Icon(
          Icons.send_rounded,
          color: widget.replyService.themeColor,
          size: 28,
        ),
        onPressed: widget.onSend,
      ),
    );
  }
}
