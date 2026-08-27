import 'package:flutter/material.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

class PrivacyPolicyView extends StatelessWidget {
  final ReplyService replyService;

  const PrivacyPolicyView({super.key, required this.replyService});

  @override
  Widget build(BuildContext context) {
    final lang = replyService.language;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5), // 統一された背景色
      appBar: AppBar(
        title: Text(
          T.get('menu_policy_title', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // メインタイトル
            Text(
              T.get('policy_header', lang),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // 各セクション（共通パーツ化してスッキリ）
            _buildPolicySection(
              T.get('policy_s1_title', lang),
              T.get('policy_s1_desc', lang),
            ),
            _buildPolicySection(
              T.get('policy_s2_title', lang),
              T.get('policy_s2_desc', lang),
            ),
            _buildPolicySection(
              T.get('policy_s3_title', lang),
              T.get('policy_s3_desc', lang),
            ),
            _buildPolicySection(
              T.get('policy_s4_title', lang),
              T.get('policy_s4_desc', lang),
            ),

            const SizedBox(height: 60),

            // 共通フッター
            _buildFooter(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Center(
          child: Text(
            "© 2026 Project NEST Team",
            style: TextStyle(
              color: Colors.black26,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            "Developed by Chiku",
            style: TextStyle(color: Colors.black26, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
