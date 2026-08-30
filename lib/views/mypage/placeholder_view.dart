import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

class PlaceholderView extends StatelessWidget {
  final String title;
  final ReplyService replyService;

  const PlaceholderView({
    super.key,
    required this.title,
    required this.replyService,
  });

  final String appUrl =
      "https://chikunoshow-creator.github.io/ProjectNEST/?v=1";

  // X（Twitter）へのシェア
  Future<void> _shareOnX() async {
    final String text = T.get('support_share_msg', replyService.language);
    final String xUrl =
        "https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}&url=${Uri.encodeComponent(appUrl)}";
    await _launch(xUrl);
  }

  // LINEで送る
  Future<void> _shareOnLine() async {
    final String text = T.get('support_share_msg', replyService.language);
    final String lineUrl =
        "https://line.me/R/msg/text/?${Uri.encodeComponent("$text\n$appUrl")}";
    await _launch(lineUrl);
  }

  // URLをコピー
  void _copyLink(BuildContext context, Color themeColor) {
    Clipboard.setData(ClipboardData(text: appUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(T.get('support_copy_success', replyService.language)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: themeColor, // 通知の色を連動
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Buy Me a Coffee を開く
  Future<void> _openBuyMeACoffee() async {
    const String url = "https://www.buymeacoffee.com/chikunoshow";
    await _launch(url);
  }

  Future<void> _launch(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = replyService.language;
    final themeColor = replyService.themeColor;
    final scaffoldBg = themeColor.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: scaffoldBg, // 背景色を連動
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: themeColor, // AppBarの文字色を連動
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                // ハートアイコンの装飾
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.1), // 影の色を連動
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 60,
                    color: themeColor, // ハートの色を連動
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  T.get('menu_support_title', lang),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: themeColor, // タイトル色を連動
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  T.get('support_header_msg', lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    T.get('support_desc_msg', lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // --- アクションカード ---
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Support & Share",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black38,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildActionButton(
                        onPressed: _openBuyMeACoffee,
                        icon: Icons.coffee_rounded,
                        label: T.get('support_btn_coffee', lang),
                        color: const Color(0xFFFFDD00),
                        textColor: Colors.black87,
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        onPressed: _shareOnX,
                        icon: Icons.share_rounded,
                        label: T.get('support_btn_x', lang),
                        color: const Color(0xFF000000),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        onPressed: _shareOnLine,
                        icon: Icons.chat_bubble_rounded,
                        label: T.get('support_btn_line', lang),
                        color: const Color(0xFF06C755),
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        onPressed: () => _copyLink(context, themeColor),
                        icon: Icons.link_rounded,
                        label: T.get('support_btn_copy', lang),
                        color: Colors.grey[100]!,
                        textColor: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),

                // フッタークレジット
                Column(
                  children: [
                    const Text(
                      "© 2026 Project NEST",
                      style: TextStyle(
                        color: Colors.black26,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Developed by Chiku",
                      style: TextStyle(
                        color: themeColor.withValues(alpha: 0.5), // クレジットをテーマ色に
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
