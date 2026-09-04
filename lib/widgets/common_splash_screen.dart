import 'package:flutter/material.dart';
import '../services/reply_service.dart';

class CommonSplashScreen extends StatelessWidget {
  final ReplyService replyService;

  const CommonSplashScreen({super.key, required this.replyService});

  @override
  Widget build(BuildContext context) {
    final themeColor = replyService.themeColor;
    final scaffoldBg = themeColor.withValues(alpha: 0.05);

    // デフォルトのアイコンパス（ひな）
    const String defaultIcon = 'assets/images/clingy_f_icon.webp';
    // 現在のキャラクターアイコンパス
    final String currentIcon =
        'assets/images/${replyService.charKey}_icon.webp';

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeColor.withValues(alpha: 0.3),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                // AssetImageに失敗してもImage.assetのエラーハンドリングでカバーします
                child: ClipOval(
                  child: Image.asset(
                    currentIcon,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    // ★ 1段目の保険：現在のアイコンがなければ「ひな（clingy_f）」を表示
                    errorBuilder: (c, e, s) => Image.asset(
                      defaultIcon,
                      fit: BoxFit.cover,
                      // ★ 2段目の保険：ひなさえいなければ「ハートマーク」を表示
                      errorBuilder: (c2, e2, s2) =>
                          Icon(Icons.favorite, size: 60, color: themeColor),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Project NEST',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: themeColor,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 120,
              height: 3,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(10),
                color: themeColor.withValues(alpha: 0.6),
                backgroundColor: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
