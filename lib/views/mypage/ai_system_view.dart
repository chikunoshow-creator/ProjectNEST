import 'package:flutter/material.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';
import '../../widgets/groq_guide.dart'; // ★ ガイドをインポート

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
  late String _tempProvider;
  late String _tempLang;
  late TextEditingController _groqKeyCtrl;
  late TextEditingController _geminiKeyCtrl;

  @override
  void initState() {
    super.initState();
    _tempProvider = widget.replyService.aiProvider;
    _tempLang = widget.replyService.language;
    _groqKeyCtrl = TextEditingController(text: widget.replyService.groqApiKey);
    _geminiKeyCtrl = TextEditingController(
      text: widget.replyService.geminiApiKey,
    );
  }

  @override
  void dispose() {
    _groqKeyCtrl.dispose();
    _geminiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        title: Text(
          T.get('ai_setting', _tempLang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: Colors.pinkAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // システム情報の安心ガイド
          _buildInfoText(
            _tempLang == 'ja'
                ? "APIキーはあなたのブラウザ内にのみ保存され、開発者にも送信されません。安心して設定してね。"
                : "Your API key is saved only in your browser and is never sent to the developer.",
          ),
          const SizedBox(height: 24),

          // 1. 言語設定（ここでも変更可能に）
          _buildSectionTitle(_tempLang == 'ja' ? "表示言語" : "Language"),
          _buildCard(
            child: DropdownButtonFormField<String>(
              value: _tempLang,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.language, color: Colors.pinkAccent),
              ),
              items: const [
                DropdownMenuItem(value: "ja", child: Text("日本語")),
                DropdownMenuItem(value: "en", child: Text("English")),
              ],
              onChanged: (v) => setState(() => _tempLang = v!),
            ),
          ),
          const SizedBox(height: 24),

          // 2. AIプロバイダー選択
          _buildSectionTitle(_tempLang == 'ja' ? "AIエンジン" : "AI Provider"),
          _buildCard(
            child: DropdownButtonFormField<String>(
              value: _tempProvider,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.psychology, color: Colors.pinkAccent),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Groq",
                  child: Text("Groq (Recommended)"),
                ),
                DropdownMenuItem(
                  value: "Gemini",
                  child: Text("Gemini (Experimental)"),
                ),
              ],
              onChanged: (v) => setState(() => _tempProvider = v!),
            ),
          ),
          const SizedBox(height: 24),

          // 3. APIキー入力
          _buildSectionTitle("Groq API Key"),
          _buildCard(
            child: TextField(
              controller: _groqKeyCtrl,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "gsk_...",
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Icons.vpn_key_rounded,
                  color: Colors.pinkAccent,
                ),
                // ★ ここで GroqGuide を呼び出す
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.pinkAccent,
                  ),
                  onPressed: () => GroqGuide.show(context, _tempLang),
                ),
              ),
            ),
          ),

          if (_tempProvider == "Gemini") ...[
            const SizedBox(height: 24),
            _buildSectionTitle("Gemini API Key"),
            _buildCard(
              child: TextField(
                controller: _geminiKeyCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "AIza...",
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.vpn_key_rounded,
                    color: Colors.pinkAccent,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 48),

          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
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

  Widget _buildInfoText(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pinkAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.security_rounded,
            color: Colors.pinkAccent,
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
    // 言語設定を保存
    await widget.replyService.setLanguage(_tempLang);

    // 全ての設定を更新
    await widget.replyService.updateSettings(
      name: widget.replyService.userName,
      nestName: widget.replyService.nestName,
      nestAliases: widget.replyService.nestAliases,
      p: widget.replyService.personality,
      provider: _tempProvider,
      apiKey: _groqKeyCtrl.text,
      geminiKey: _geminiKeyCtrl.text,
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
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}
