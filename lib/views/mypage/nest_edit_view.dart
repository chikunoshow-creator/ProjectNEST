import 'package:flutter/material.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';
import '../../models/nest_profile.dart';

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
  late Relationship _relationship;

  @override
  void initState() {
    super.initState();
    _aliasesCtrl = TextEditingController(text: widget.replyService.nestAliases);
    _relationship = widget.replyService.partnerProfile.relationship;
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
    final scaffoldBg = themeColor.withOpacity(0.05);

    String pLabel = widget.replyService.personality;
    if (lang == 'en') {
      if (pLabel == "甘えん坊") pLabel = T.get('p_sweet', lang);
      if (pLabel == "クールなお姉さん") pLabel = T.get('p_cool', lang);
      if (pLabel == "ツンデレ") pLabel = T.get('p_tsun', lang);
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          T.get('edit_nest', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        foregroundColor: themeColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 1. 彼女の名前
          _buildInfoCard(
            T.get('nest_name_label', lang),
            widget.replyService.displayName,
            Icons.face_rounded,
            themeColor,
          ),
          const SizedBox(height: 12),

          // 2. 性格
          _buildInfoCard(
            T.get('personality_label', lang),
            pLabel,
            Icons.auto_awesome_rounded,
            themeColor,
          ),
          const SizedBox(height: 32),

          // 3. 二人の関係性
          _buildSectionLabel(T.get('relationship_label', lang)),
          Row(
            children: [
              _buildSimpleRadio(
                Relationship.lover,
                T.get('label_rel_lover', lang),
                themeColor,
              ),
              const SizedBox(width: 24),
              _buildSimpleRadio(
                Relationship.bestFriend,
                T.get('label_rel_bestFriend', lang),
                themeColor,
              ),
            ],
          ),

          // 関係性の説明欄
          const SizedBox(height: 16),
          _buildExplanationBox(lang, themeColor),

          const SizedBox(height: 32),
          Divider(color: themeColor.withOpacity(0.2)),
          const SizedBox(height: 32),

          // 4. 呼び名
          _buildNicknameField(lang, themeColor),

          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
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

  // --- ヘルパー ---

  Widget _buildSimpleRadio(Relationship value, String label, Color themeColor) {
    return InkWell(
      onTap: () => setState(() => _relationship = value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<Relationship>(
            value: value,
            groupValue: _relationship,
            activeColor: themeColor,
            onChanged: (v) {
              if (v != null) setState(() => _relationship = v);
            },
          ),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExplanationBox(String lang, Color themeColor) {
    // ui.dart の新しいキーを指定
    String descKey = (_relationship == Relationship.lover)
        ? 'desc_rel_lover'
        : 'desc_rel_bestFriend';
    String desc = T.get(descKey, lang);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: themeColor.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, size: 16, color: themeColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              desc,
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

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
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
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: themeColor.withOpacity(0.5), size: 24),
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
        _buildSectionLabel(lang == 'ja' ? "彼女への呼び名（カンマ区切り）" : "Nicknames"),
        TextField(
          controller: _aliasesCtrl,
          decoration: InputDecoration(
            hintText: lang == 'ja' ? "ひな,ひなちゃん" : "Hina,My Love",
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.edit_note_rounded, color: themeColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveSettings() async {
    await widget.replyService.updateSettings(
      name: widget.replyService.userName,
      userGender: widget.replyService.partnerProfile.userGender,
      nestName: widget.replyService.nestName,
      nestAliases: _aliasesCtrl.text,
      p: widget.replyService.personality,
      apiKey: widget.replyService.groqApiKey,
      nestGender: Gender.female,
      relationship: _relationship,
      birthday: widget.replyService.userBirthday,
      food: widget.replyService.userFood,
      job: widget.replyService.userJob,
    );
    widget.onSettingsUpdated();
    if (mounted) Navigator.pop(context);
  }
}
