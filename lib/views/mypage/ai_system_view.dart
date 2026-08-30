import 'package:flutter/material.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';
import '../../widgets/groq_guide.dart';

class AiSystemView extends StatefulWidget {
  final ReplyService replyService;
  final VoidCallback onSettingsUpdated;

  const AiSystemView({
    super.key,
    required this.replyService,
    required this.onSettingsUpdated,
  });

  @override
  State<AiSystemView> createState() => _AiSystemViewState();
}

class _AiSystemViewState extends State<AiSystemView> {
  late String _tempLang;
  late TextEditingController _groqKeyCtrl;

  @override
  void initState() {
    super.initState();
    _tempLang = widget.replyService.language;
    _groqKeyCtrl = TextEditingController(text: widget.replyService.groqApiKey);
  }

  @override
  void dispose() {
    _groqKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // テーマ色の取得
    final themeColor = widget.replyService.themeColor;
    final scaffoldBg = themeColor.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: scaffoldBg, // 背景色を連動
      appBar: AppBar(
        title: Text(
          T.get('ai_setting', _tempLang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: themeColor, // 文字色を連動
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildInfoText(
            _tempLang == 'ja'
                ? "APIキーはあなたのブラウザ内にのみ保存され、開発者にも送信されません。安心して設定してね。"
                : "Your API key is saved only in your browser and is never sent to the developer.",
            themeColor,
          ),
          const SizedBox(height: 24),

          // 1. 言語設定
          _buildSectionTitle(_tempLang == 'ja' ? "表示言語" : "Language"),
          _buildCard(
            child: DropdownButtonFormField<String>(
              value: _tempLang,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.language, color: themeColor), // アイコン色を連動
              ),
              items: const [
                DropdownMenuItem(value: "ja", child: Text("日本語")),
                DropdownMenuItem(value: "en", child: Text("English")),
              ],
              onChanged: (v) => setState(() => _tempLang = v!),
            ),
          ),
          const SizedBox(height: 24),

          // 2. AIエンジン（表示のみ）
          _buildSectionTitle(_tempLang == 'ja' ? "AIエンジン" : "AI Provider"),
          _buildCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.psychology, color: themeColor), // アイコン色を連動
              title: const Text("Groq (Recommended)"),
              subtitle: Text(
                _tempLang == 'ja'
                    ? "高速で自然な会話が可能です"
                    : "Fast and natural conversation",
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 3. Groq APIキー入力
          _buildSectionTitle("Groq API Key"),
          _buildCard(
            child: TextField(
              controller: _groqKeyCtrl,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "gsk_...",
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.vpn_key_rounded,
                  color: themeColor, // アイコン色を連動
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.help_outline_rounded,
                    color: themeColor, // アイコン色を連動
                  ),
                  onPressed: () => GroqGuide.show(context, _tempLang),
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor, // ボタンの色を連動
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Text(
              T.get('save', _tempLang),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoText(String text, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.05), // 背景色を連動
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security_rounded,
            color: themeColor, // アイコン色を連動
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    await widget.replyService.setLanguage(_tempLang);

    await widget.replyService.updateSettings(
      name: widget.replyService.userName,
      nestName: widget.replyService.nestName,
      nestAliases: widget.replyService.nestAliases,
      p: widget.replyService.personality,
      apiKey: _groqKeyCtrl.text,
      birthday: widget.replyService.userBirthday,
      food: widget.replyService.userFood,
      job: widget.replyService.userJob,
    );

    widget.onSettingsUpdated();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _tempLang == 'ja' ? "システム設定を保存したよ！" : "Settings Saved!",
          ),
          backgroundColor: widget.replyService.themeColor, // 通知の色を連動
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}
