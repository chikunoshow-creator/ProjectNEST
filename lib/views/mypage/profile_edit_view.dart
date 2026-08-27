import 'package:flutter/material.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

class ProfileEditView extends StatefulWidget {
  final ReplyService replyService;
  final VoidCallback onSettingsUpdated;

  const ProfileEditView({
    super.key,
    required this.replyService,
    required this.onSettingsUpdated,
  });

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  late TextEditingController _nameCtrl;
  late TextEditingController _birthdayCtrl;
  late TextEditingController _foodCtrl;
  late TextEditingController _jobCtrl;

  @override
  void initState() {
    super.initState();
    // 各項目の初期値をセット
    _nameCtrl = TextEditingController(
      text: widget.replyService.displayUserName,
    );
    _birthdayCtrl = TextEditingController(
      text: widget.replyService.userBirthday,
    );
    _foodCtrl = TextEditingController(text: widget.replyService.userFood);
    _jobCtrl = TextEditingController(text: widget.replyService.userJob);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthdayCtrl.dispose();
    _foodCtrl.dispose();
    _jobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.replyService.language;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        title: Text(
          T.get('menu_profile_title', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: Colors.pinkAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildInfoText(
            lang == 'ja'
                ? "NESTにあなたのことを教えてあげてね。"
                : "Tell NEST more about yourself.",
          ),
          const SizedBox(height: 24),

          _buildTextField(
            controller: _nameCtrl,
            label: T.get('name_label', lang),
            icon: Icons.person_rounded,
            hint: lang == 'ja' ? "あなたの名前" : "Your Name",
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _birthdayCtrl,
            label: lang == 'ja' ? "誕生日" : "Birthday",
            icon: Icons.cake_rounded,
            hint: "Example: 08/25",
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _foodCtrl,
            label: lang == 'ja' ? "好きな食べ物" : "Favorite Food",
            icon: Icons.restaurant_rounded,
            hint: lang == 'ja' ? "オムライス、甘いもの、など" : "e.g. Sushi, Pizza",
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _jobCtrl,
            label: lang == 'ja' ? "お仕事" : "Occupation",
            icon: Icons.work_rounded,
            hint: lang == 'ja' ? "エンジニア、学生、など" : "e.g. Engineer, Student",
          ),

          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 2,
            ),
            child: Text(
              T.get('save', lang), // ★ save_btn を save に修正
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
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.pinkAccent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.pinkAccent, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    await widget.replyService.updateSettings(
      name: _nameCtrl.text,
      nestName: widget.replyService.nestName,
      nestAliases: widget.replyService.nestAliases,
      p: widget.replyService.personality,
      provider: widget.replyService.aiProvider,
      apiKey: widget.replyService.groqApiKey,
      // ★ ここを geminiApiKey から geminiKey に修正します
      geminiKey: widget.replyService.geminiApiKey,
      birthday: _birthdayCtrl.text,
      food: _foodCtrl.text,
      job: _jobCtrl.text,
    );

    widget.onSettingsUpdated();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile Updated! ❤️"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
