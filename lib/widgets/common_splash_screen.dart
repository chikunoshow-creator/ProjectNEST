import 'package:flutter/material.dart';
import '../services/reply_service.dart'; // ★ インポート追加

class CommonSplashScreen extends StatelessWidget {
  final ReplyService replyService; // ★ 追加

  const CommonSplashScreen({super.key, required this.replyService}); // ★ 引数に追加

  @override
  Widget build(BuildContext context) {
    // テーマ色の取得
    final themeColor = replyService.themeColor;
    final scaffoldBg = themeColor.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: scaffoldBg, // ★ 背景色を連動
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeColor.withValues(alpha: 0.3), // ★ 輪郭の色を連動
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage('assets/images/hau_icon.png'),
                child: Image.asset(
                  'assets/images/hau_icon.png',
                  errorBuilder: (c, e, s) => Icon(
                    Icons.favorite,
                    size: 60,
                    color: themeColor, // ★ アイコン色を連動
                  ),
                  color: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Project NEST',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: themeColor, // ★ 文字色を連動
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 120,
              height: 3,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(10),
                color: themeColor.withValues(alpha: 0.6), // ★ バーの色を連動
                backgroundColor: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
