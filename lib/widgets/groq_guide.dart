import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GroqGuide {
  // ★ lang を受け取れるように変更
  static void show(BuildContext context, String lang) {
    bool isEn = (lang == 'en');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.pinkAccent),
            const SizedBox(width: 10),
            Text(
              isEn ? "How to get API Key" : "APIキーの取得方法",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn ? "Free and takes only 1 minute! ✨" : "全て無料、1分で終わります！✨",
                style: const TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildStep(
                1,
                isEn ? "Open official site" : "公式サイトを開く",
                isEn
                    ? "Click the 'Open Site' button below to visit the Groq website."
                    : "下の「サイトを開く」ボタンを押して、英語のサイトへ移動します。",
              ),
              _buildStep(
                2,
                isEn ? "Sign in" : "ログインする",
                isEn
                    ? "Using 'Login with Google' is the easiest way."
                    : "「Login with Google」を選ぶのが一番簡単でおすすめです。",
              ),
              _buildStep(
                3,
                isEn ? "Create API Key" : "キー作成ボタンを押す",
                isEn
                    ? "Look for the black 'Create API Key' button and click it."
                    : "黒いボタン「Create API Key」を探して押してください。",
              ),
              _buildStep(
                4,
                isEn ? "Name it" : "名前を入力して決定",
                isEn
                    ? "Any name is fine (e.g., NEST). Enter it and click 'Submit'."
                    : "名前は何でもOK（例：NEST）です。入力して「Submit」を押します。",
              ),
              _buildStep(
                5,
                isEn ? "Copy the key" : "キーをコピーする",
                isEn
                    ? "Copy the text starting with 'gsk_...' and paste it into this app."
                    : "表示された「gsk_...」で始まる文字をコピーして、このアプリに貼り付ければ完了です！",
              ),
              const SizedBox(height: 10),
              const Divider(),
              Text(
                isEn
                    ? "Note: The key is only displayed once. If you forget it, you can just create a new one! 🐾"
                    : "※注意：キーは一度しか表示されません。もし忘れたら、もう一度新しいキーを作れば大丈夫だよ！🐾",
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isEn ? "Close" : "閉じる"),
          ),
          ElevatedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse("https://console.groq.com/keys"),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.launch, size: 16),
            label: Text(isEn ? "Open Site" : "サイトを開く"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStep(int num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.pinkAccent,
            child: Text(
              "$num",
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
