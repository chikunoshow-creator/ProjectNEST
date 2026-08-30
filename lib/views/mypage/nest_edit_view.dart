import 'package:flutter/material.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

class NestEditView extends StatefulWidget {
  final ReplyService replyService;
  final VoidCallback onSettingsUpdated;

  const NestEditView({
    super.key,
    required this.replyService,
    required this.onSettingsUpdated,
  });

  @override
  State<NestEditView> createState() => _NestEditViewState();
}

class _NestEditViewState extends State<NestEditView> {
  late TextEditingController _aliasesCtrl;

  @override
  void initState() {
    super.initState();
    String currentAliases = widget.replyService.nestAliases;

    if (widget.replyService.language == 'en') {
      if (currentAliases == "ひな,ひなちゃん,陽菜" || currentAliases == "ひな") {
        currentAliases = "Hina,My Love";
      }
      if (currentAliases == "しずる,しず,静流" || currentAliases == "しずる") {
        currentAliases = "Shizuru,Honey";
      }
      if (currentAliases == "かえで,楓,かえたん" || currentAliases == "かえで") {
        currentAliases = "Kaede,Sweetie";
      }
    }

    _aliasesCtrl = TextEditingController(text: currentAliases);
  }

  @override
  void dispose() {
    _aliasesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.replyService.language;
    final themeColor = widget.replyService.themeColor;
    final scaffoldBg = themeColor.withValues(alpha: 0.05);

    String pLabel = widget.replyService.personality;
    if (lang == 'en') {
      if (pLabel == "甘えん坊") pLabel = T.get('p_sweet', lang);
      if (pLabel == "クールなお姉さん") pLabel = T.get('p_cool', lang);
      if (pLabel == "ツンデレ") pLabel = T.get('p_tsun', lang);
    }

    return Scaffold(
      backgroundColor: scaffoldBg, // 背景色を連動
      appBar: AppBar(
        title: Text(
          T.get('edit_nest', lang),
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
            lang == 'ja'
                ? "${widget.replyService.displayName}への呼び方を設定できるよ。AIがあなたの呼びかけを理解しやすくなります。"
                : "Set how you want to call ${widget.replyService.displayName}. This helps her understand you better.",
          ),
          const SizedBox(height: 24),
          _buildInfoCard(
            T.get('nest_name_label', lang),
            widget.replyService.displayName,
            Icons.face_rounded,
            themeColor,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            T.get('personality_label', lang),
            pLabel,
            Icons.auto_awesome_rounded,
            themeColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Divider(
              color: themeColor.withValues(alpha: 0.2),
              thickness: 1,
            ),
          ),
          _buildNicknameField(lang, themeColor), // 入力欄の色を連動
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor, // 保存ボタンの色を連動
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 2,
            ),
            child: Text(
              T.get('save', lang),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black54,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color themeColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: themeColor.withValues(alpha: 0.5), size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameField(String lang, Color themeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            lang == 'ja' ? "彼女への呼び名（カンマ区切り）" : "Nicknames (comma separated)",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        TextField(
          controller: _aliasesCtrl,
          decoration: InputDecoration(
            hintText: lang == 'ja' ? "ひな,ひなちゃん" : "Hina,My Love",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(
              Icons.edit_note_rounded,
              color: themeColor,
            ), // アイコン色を連動
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          lang == 'ja'
              ? "※複数の呼び方を登録すると、会話がスムーズになるよ。"
              : "Registering multiple names helps AI recognize them better.",
          style: const TextStyle(fontSize: 11, color: Colors.black38),
        ),
      ],
    );
  }

  Future<void> _saveSettings() async {
    await widget.replyService.updateSettings(
      name: widget.replyService.userName,
      nestName: widget.replyService.nestName,
      nestAliases: _aliasesCtrl.text,
      p: widget.replyService.personality,
      apiKey: widget.replyService.groqApiKey,
      birthday: widget.replyService.userBirthday,
      food: widget.replyService.userFood,
      job: widget.replyService.userJob,
    );

    widget.onSettingsUpdated();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(T.get('save_complete', widget.replyService.language)),
          backgroundColor: widget.replyService.themeColor, // 通知の色を連動
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}
