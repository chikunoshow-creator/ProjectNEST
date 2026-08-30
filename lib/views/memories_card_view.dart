import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

class MemoriesCardView extends StatefulWidget {
  final ReplyService replyService;
  const MemoriesCardView({super.key, required this.replyService});

  @override
  State<MemoriesCardView> createState() => _MemoriesCardViewState();
}

class _MemoriesCardViewState extends State<MemoriesCardView> {
  final GlobalKey _cardKey = GlobalKey();

  String _getShareText(String lang) {
    return T
        .get('card_share_template', lang)
        .replaceAll('{name}', widget.replyService.displayName)
        .replaceAll('{days}', widget.replyService.daysTogether.toString());
  }

  Future<void> _captureAndSave(
    BuildContext context,
    String lang, {
    bool isSharing = false,
  }) async {
    try {
      final themeColor = widget.replyService.themeColor; // ★ 追加
      await Future.delayed(const Duration(milliseconds: 100));

      RenderRepaintBoundary? boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return;
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final blob = html.Blob([pngBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute(
          "download",
          "NEST_Certificate_${widget.replyService.displayName}.png",
        )
        ..click();
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSharing
                  ? (lang == 'ja'
                        ? "画像を保存したよ！SNSに添付してね ✨"
                        : "Image saved! Please attach it ✨")
                  : T.get('backup_success', lang),
            ),
            backgroundColor: themeColor, // ★ ピンク固定からテーマ連動に変更
          ),
        );
      }
    } catch (e) {
      debugPrint("Capture Error: $e");
    }
  }

  Future<void> _captureAndShareSns(
    String platform,
    String lang,
    BuildContext context,
  ) async {
    await _captureAndSave(context, lang, isSharing: true);
    await Future.delayed(const Duration(milliseconds: 500));
    final text = _getShareText(lang);
    String url = "";
    switch (platform) {
      case 'x':
        url =
            "https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}";
        break;
      case 'line':
        url = "https://line.me/R/msg/text/?${Uri.encodeComponent(text)}";
        break;
      case 'whatsapp':
        url = "https://wa.me/?text=${Uri.encodeComponent(text)}";
        break;
      case 'discord':
        Clipboard.setData(ClipboardData(text: text));
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(T.get('share_discord_done', lang))),
          );
        url = "https://discord.com/channels/@me";
        break;
    }
    if (url.isNotEmpty) html.window.open(url, "_blank");
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.replyService.language;
    final charKey = widget.replyService.charKey;
    final themeColor = widget.replyService.themeColor; // ★ 追加
    final scaffoldBg = themeColor.withValues(alpha: 0.05); // ★ 追加

    return Scaffold(
      backgroundColor: scaffoldBg, // ★ 背景色連動
      appBar: AppBar(
        title: Text(
          T.get('card_title', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: themeColor, // ★ 文字色連動
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Center(
              child: RepaintBoundary(
                key: _cardKey,
                child: _buildCardUI(
                  lang,
                  charKey,
                  themeColor,
                ), // ★ themeColorを渡す
              ),
            ),
            const SizedBox(height: 40),
            _buildActionButtons(lang, context, themeColor), // ★ themeColorを渡す
          ],
        ),
      ),
    );
  }

  Widget _buildCardUI(String lang, String charKey, Color themeColor) {
    final rank = widget.replyService.intimacyRank;
    final isRankS = (rank == "S");

    String sinceDate = "2024.01.01";
    if (widget.replyService.startDate.isNotEmpty) {
      try {
        sinceDate = DateFormat(
          'yyyy.MM.dd',
        ).format(DateTime.parse(widget.replyService.startDate));
      } catch (e) {
        sinceDate = "2024.01.01";
      }
    }

    return Container(
      width: 380,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isRankS
              ? [
                  const Color(0xFFFFD700).withValues(alpha: 0.2),
                  Colors.white,
                  const Color(0xFFDAA520).withValues(alpha: 0.1),
                ]
              : [
                  themeColor.withValues(alpha: 0.15),
                  Colors.white,
                ], // ★ 通常時はテーマ色グラデーション
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isRankS
              ? const Color(0xFFFFD700).withValues(alpha: 0.5)
              : Colors.white,
          width: isRankS ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isRankS ? const Color(0xFFFFD700) : themeColor).withValues(
              alpha: 0.1,
            ), // ★ 影の色連動
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.favorite,
              size: 150,
              color: themeColor.withValues(alpha: 0.03), // ★ 背景ハートの色連動
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 5),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.grey[100],
                            backgroundImage: AssetImage(
                              "assets/images/${charKey}_icon.png",
                            ),
                          ),
                        ),
                        Positioned(
                          right: -8,
                          bottom: 0,
                          child: _buildRankBadge(rank),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.replyService.displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isRankS
                            ? const Color(0xFFB8860B)
                            : themeColor, // ★ 名前色連動
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        T.get('card_days_together', lang),
                        "${widget.replyService.daysTogether} ${T.get('card_days_unit', lang)}",
                        Icons.calendar_today_rounded,
                      ),
                      const SizedBox(height: 12),
                      _infoRow(
                        T.get('card_intimacy', lang),
                        "❤️ ${widget.replyService.intimacyScore}",
                        Icons.favorite_rounded,
                      ),
                      const SizedBox(height: 12),
                      _infoRow(
                        T.get('card_messages', lang),
                        "${widget.replyService.messageCount} msg",
                        Icons.chat_bubble_outline_rounded,
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              T.get('card_since', lang),
                              style: const TextStyle(
                                fontSize: 7,
                                color: Colors.black26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              sinceDate,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black45,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(String rank) {
    Color badgeColor = Colors.grey;
    if (rank == "S")
      badgeColor = const Color(0xFFFFD700);
    else if (rank == "A")
      badgeColor = const Color(0xFFFF4500);
    else if (rank == "B")
      badgeColor = Colors.purple;
    else if (rank == "C")
      badgeColor = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(
        "Rank $rank",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: Colors.black26),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.black38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    String lang,
    BuildContext context,
    Color themeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            T.get('card_share_hint', lang),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black45,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.2,
            children: [
              _buildSnsButton(
                Icons.close,
                T.get('share_x', lang),
                Colors.black,
                () => _captureAndShareSns('x', lang, context),
              ),
              _buildSnsButton(
                Icons.chat_bubble,
                T.get('share_line', lang),
                const Color(0xFF06C755),
                () => _captureAndShareSns('line', lang, context),
              ),
              _buildSnsButton(
                Icons.phone_android,
                T.get('share_whatsapp', lang),
                const Color(0xFF25D366),
                () => _captureAndShareSns('whatsapp', lang, context),
              ),
              _buildSnsButton(
                Icons.discord,
                T.get('share_discord', lang),
                const Color(0xFF5865F2),
                () => _captureAndShareSns('discord', lang, context),
              ),
            ],
          ),
          const SizedBox(height: 30),
          TextButton.icon(
            onPressed: () => _captureAndSave(context, lang),
            icon: Icon(
              Icons.download_rounded,
              color: themeColor,
              size: 20,
            ), // ★ ボタンアイコン連動
            label: Text(
              T.get('share_save_btn', lang),
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.bold,
              ), // ★ ボタン文字連動
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: themeColor.withValues(alpha: 0.2),
                ), // ★ 枠線連動
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnsButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
