// lib/views/nest/nest_edit_dialog.dart

import 'package:flutter/material.dart';
import '../../models/nest_profile.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

class NestEditDialog extends StatefulWidget {
  final ReplyService replyService;
  const NestEditDialog({super.key, required this.replyService});

  @override
  State<NestEditDialog> createState() => _NestEditDialogState();
}

class _NestEditDialogState extends State<NestEditDialog> {
  late String _nestName;
  late String _personality;
  late Gender _userGender;
  late Relationship _relationship;

  @override
  void initState() {
    super.initState();
    final p = widget.replyService.partnerProfile;
    _nestName = widget.replyService.nestName;
    _personality = widget.replyService.personality;
    _userGender = p.userGender;
    _relationship = p.relationship;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.replyService.language;
    final themeColor = widget.replyService.themeColor;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: Text(
        T.get('edit_nest', lang),
        style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // パートナーの名前
            TextField(
              decoration: InputDecoration(
                labelText: T.get('nest_name_label', lang),
                labelStyle: TextStyle(color: themeColor),
              ),
              controller: TextEditingController(text: _nestName),
              onChanged: (v) => _nestName = v,
            ),
            const SizedBox(height: 20),

            // パートナーの性格
            _buildDropdown<String>(
              label: T.get('personality_label', lang),
              value: _personality,
              items: widget.replyService.personalityNames.keys.toList(),
              onChanged: (v) => setState(() => _personality = v!),
              itemLabel: (v) => v,
              themeColor: themeColor,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),

            // あなたの性別
            _buildDropdown<Gender>(
              label: T.get('user_gender_label', lang),
              value: _userGender,
              items: Gender.values,
              onChanged: (v) => setState(() => _userGender = v!),
              itemLabel: (v) => T.get('gender_${v.name}', lang),
              themeColor: themeColor,
            ),

            const SizedBox(height: 20),

            // 二人の関係性（恋人と親友に限定）
            _buildDropdown<Relationship>(
              label: T.get('relationship_label', lang),
              value: _relationship,
              items: [Relationship.lover, Relationship.bestFriend],
              onChanged: (v) => setState(() => _relationship = v!),
              itemLabel: (v) => T.get('rel_${v.name}', lang),
              themeColor: themeColor,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            T.get('cancel', lang),
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () async {
            await widget.replyService.updateSettings(
              name: widget.replyService.userName,
              nestName: _nestName,
              nestAliases: widget.replyService.nestAliases,
              p: _personality,
              apiKey: widget.replyService.groqApiKey,
              userGender: _userGender,
              nestGender: Gender.female, // アセット都合により女性固定
              relationship: _relationship,
            );
            if (mounted) Navigator.pop(context, true);
          },
          child: Text(
            T.get('save', lang),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabel,
    required Color themeColor,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: themeColor.withOpacity(0.8), fontSize: 14),
      ),
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(itemLabel(e))))
          .toList(),
      onChanged: onChanged,
    );
  }
}
