import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

class HelpView extends StatelessWidget {
  final ReplyService replyService;

  const HelpView({super.key, required this.replyService});

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  // ... 前略 ...

  @override
  Widget build(BuildContext context) {
    final lang = replyService.language;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        title: Text(
          T.get('menu_help_title', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: Colors.pinkAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 1. APIキーの概要
          _buildSectionTitle(T.get('help_api_key_title', lang)),
          _buildInfoBox(T.get('help_api_key_desc', lang)),
          const SizedBox(height: 32),

          // 2. Groqの手順
          _buildSectionTitle(T.get('help_groq_title', lang)),
          _buildGuideCard(
            title: T.get('help_groq_sub', lang),
            steps: lang == 'ja'
                ? [
                    "Googleアカウント等でサインイン",
                    "メニューの「API Keys」をクリック",
                    "「Create API Key」で名前を付けて作成",
                    "表示された「gsk_...」をコピー",
                  ]
                : [
                    "Sign in with Google",
                    "Click 'API Keys' in the menu",
                    "Click 'Create API Key'",
                    "Copy the 'gsk_...' key",
                  ],
            url: "https://console.groq.com/keys",
            buttonText: T.get('help_groq_btn', lang),
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 24),

          // 3. Geminiの手順
          _buildSectionTitle(T.get('help_gemini_title', lang)),
          _buildGuideCard(
            title: T.get('help_gemini_sub', lang),
            steps: lang == 'ja'
                ? [
                    "「Get API key」をクリック",
                    "「Create API key in new project」を押す",
                    "表示された「AIzaSy...」をコピー",
                  ]
                : [
                    "Click 'Get API key'",
                    "Click 'Create API key in new project'",
                    "Copy the 'AIzaSy...' key",
                  ],
            url: "https://aistudio.google.com/app/apikey",
            buttonText: T.get('help_gemini_btn', lang),
            color: Colors.blueAccent,
          ),

          const SizedBox(height: 32),

          // 4. トラブルシューティング
          _buildSectionTitle(T.get('help_trouble_title', lang)),
          _buildFaqItem(
            T.get('help_q1_title', lang),
            T.get('help_q1_ans', lang),
          ),
          _buildFaqItem(
            T.get('help_q2_title', lang),
            T.get('help_q2_ans', lang),
          ),

          const SizedBox(height: 60),

          // 5. フッター（クレジット）
          _buildFooter(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- ヘルパーメソッド ---

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          "Project NEST v${replyService.appVersion}",
          style: const TextStyle(
            color: Colors.black26,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Developed by Chiku",
          style: TextStyle(color: Colors.black26, fontSize: 11),
        ),
      ],
    );
  }

  // ... 以下、_buildSectionTitle などのUIパーツ定義（前回と同じ）は省略 ...
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.pinkAccent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required String title,
    required List<String> steps,
    required String url,
    required String buttonText,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...List.generate(
                  steps.length,
                  (i) => _buildStepRow(i + 1, steps[i]),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _launchURL(url),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(int num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: Colors.pinkAccent.withValues(alpha: 0.2),
            child: Text(
              "$num",
              style: const TextStyle(
                fontSize: 10,
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            a,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
