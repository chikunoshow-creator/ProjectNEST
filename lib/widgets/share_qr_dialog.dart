import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/translation_service.dart'; // ★ インポート追加

class ShareQrDialog extends StatelessWidget {
  final Color themeColor;
  final String lang; // ★ 言語を受け取る変数を追加

  const ShareQrDialog({
    super.key,
    required this.themeColor,
    required this.lang, // ★ コンストラクタに追加
  });

  final String appUrl = "https://chikunoshow-creator.github.io/ProjectNEST/";

  @override
  Widget build(BuildContext context) {
    final double dialogWidth = MediaQuery.of(context).size.width * 0.8;

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.share_rounded, color: themeColor, size: 30),
          const SizedBox(height: 10),
          Text(
            T.get('share_title', lang), // ★ 翻訳適用
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth > 400 ? 400 : dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              T.get('share_desc', lang), // ★ 翻訳適用
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.1),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: QrImageView(
                  data: appUrl,
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.circle,
                    color: themeColor,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle,
                    color: themeColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SelectableText(
                appUrl,
                style: TextStyle(
                  fontSize: 10,
                  color: themeColor.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            T.get('ok', lang), // ★ 翻訳適用
            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ★ 表示用メソッドに lang を追加
  static void show(BuildContext context, Color themeColor, String lang) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ShareQrDialog(themeColor: themeColor, lang: lang),
    );
  }
}
