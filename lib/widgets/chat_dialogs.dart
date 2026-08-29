import 'package:flutter/material.dart';
import '../services/reply_service.dart';
import '../services/translation_service.dart';

class ChatDialogs {
  // 1. ご利用時の注意事項
  static void showPrecautions(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          T.get('precautions_title', lang),
          style: const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrecautionSection(
                  T.get('precautions_data_title', lang),
                  T.get('precautions_data_desc', lang),
                ),
                _buildPrecautionSection(
                  T.get('precautions_api_title', lang),
                  T.get('precautions_api_desc', lang),
                ),
                _buildPrecautionSection(
                  T.get('precautions_disclaimer_title', lang),
                  T.get('precautions_disclaimer_desc', lang),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(T.get('ok', lang)),
          ),
        ],
      ),
    );
  }

  // 2. PWAガイド（アプリとしてインストール）
  static void showPwaGuide(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          T.get('install', lang),
          style: const TextStyle(
            color: Colors.pinkAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepRow("iPhone (Safari)", T.get('install_ios', lang)),
            const SizedBox(height: 12),
            _buildStepRow("Android (Chrome)", T.get('install_android', lang)),
            const SizedBox(height: 20),
            Text(
              T.get('pwa_note', lang), // ★ 辞書化
              style: const TextStyle(
                fontSize: 12,
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // 3. 思い出リセット
  static void showTalkResetDialog(
    BuildContext context,
    String lang,
    ReplyService replyService,
    VoidCallback onResetConfirmed,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(T.get('reset_talk', lang)),
        content: Text(
          T.get('reset_warning_msg', lang),
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              T.get('cancel', lang),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              await replyService.clearChatOnly();
              onResetConfirmed(); // 親クラス側で _messages.clear() するためのコールバック
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(T.get('reset_snack_msg', lang))),
              );
            },
            child: Text(
              T.get('reset_btn', lang),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 補助パーツ ---
  static Widget _buildPrecautionSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  static Widget _buildStepRow(String os, String msg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          os,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(msg, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}
