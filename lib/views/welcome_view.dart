import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/reply_service.dart';
import '../services/translation_service.dart';
import '../widgets/groq_guide.dart';

class WelcomeView extends StatefulWidget {
  final ReplyService replyService;
  final VoidCallback onComplete;
  const WelcomeView({
    super.key,
    required this.replyService,
    required this.onComplete,
  });
  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  final _nameCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  int _step = 0;
  String _selectedP = "甘えん坊";

  void _next() => setState(() => _step++);

  @override
  Widget build(BuildContext context) {
    final lang = widget.replyService.language;
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: Stack(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                _buildChar(
                  "ツンデレ",
                  "assets/images/sayo_normal.png",
                  _selectedP == "ツンデレ"
                      ? Alignment.bottomCenter
                      : const Alignment(-2.0, 1.0),
                  isMobile,
                ),
                _buildChar(
                  "クールなお姉さん",
                  "assets/images/goki_normal.png",
                  _selectedP == "クールなお姉さん"
                      ? Alignment.bottomCenter
                      : const Alignment(2.0, 1.0),
                  isMobile,
                ),
                _buildChar(
                  "甘えん坊",
                  "assets/images/hau_normal.png",
                  _selectedP == "甘えん坊"
                      ? Alignment.bottomCenter
                      : (_selectedP == "ツンデレ"
                            ? const Alignment(2.0, 1.0)
                            : const Alignment(-2.0, 1.0)),
                  isMobile,
                ),
              ],
            ),
          ),
          Positioned(top: 40, right: 20, child: _buildLangBtn(lang)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 380,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 20),
                ],
              ),
              child: _buildStep(lang),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChar(String name, String asset, Alignment align, bool isMobile) {
    bool isSelected = _selectedP == name;
    return AnimatedAlign(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      alignment: align,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isSelected ? 1.0 : 0.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Image.asset(
            asset,
            height:
                MediaQuery.of(context).size.height * (isMobile ? 0.82 : 0.95),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String lang) {
    if (_step == 0) return _stepWelcome(lang);
    if (_step == 1) return _stepName(lang);
    if (_step == 2) return _stepPersonality(lang);
    return _stepConfig(lang);
  }

  Widget _stepWelcome(String lang) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          T.get('welcome_title', lang),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          T.get('welcome_msg', lang),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: _next, child: Text(T.get('next', lang))),
      ],
    );
  }

  Widget _stepName(String lang) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          T.get('your_name_ask', lang),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameCtrl,
          decoration: InputDecoration(
            labelText: T.get('name_label', lang),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(onPressed: _next, child: Text(T.get('next', lang))),
      ],
    );
  }

  Widget _stepPersonality(String lang) {
    final pMap = {
      "甘えん坊": T.get('p_sweet', lang),
      "クールなお姉さん": T.get('p_cool', lang),
      "ツンデレ": T.get('p_tsun', lang),
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          T.get('p_title', lang),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          // ★ value から initialValue に変更して警告を解消
          initialValue: _selectedP,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
          items: pMap.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) => setState(() => _selectedP = v!),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.pink.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Text(
              widget.replyService.getSpecificDescription(_selectedP, lang),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () => _keyCtrl.text.isNotEmpty ? _finish() : _next(),
          child: Text(
            _keyCtrl.text.isNotEmpty
                ? T.get('start_app', lang)
                : T.get('next', lang),
          ),
        ),
      ],
    );
  }

  Widget _stepConfig(String lang) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          T.get('config_title', lang),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _keyCtrl,
          decoration: InputDecoration(
            labelText: "Groq API Key",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.pinkAccent),
              onPressed: () => GroqGuide.show(context, lang),
            ),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () =>
              launchUrl(Uri.parse("https://console.groq.com/keys")),
          child: Text(
            T.get('get_key_link', lang),
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _finish,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(T.get('start_app', lang)),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.replyService.userName;
    _keyCtrl.text = widget.replyService.groqApiKey;
    bool hasName =
        _nameCtrl.text.isNotEmpty &&
        _nameCtrl.text != "あなた" &&
        _nameCtrl.text != "Guest";
    bool hasKey = _keyCtrl.text.isNotEmpty;
    if (hasName && hasKey) _step = 2;
  }

  void _finish() async {
    // ★ updateSettings の引数から provider: "Groq" を削除
    await widget.replyService.updateSettings(
      name: _nameCtrl.text.isEmpty
          ? (widget.replyService.language == 'ja' ? "あなた" : "Guest")
          : _nameCtrl.text,
      nestName: widget.replyService.personalityNames[_selectedP]!,
      nestAliases: _selectedP == "甘えん坊"
          ? "ひな"
          : (_selectedP == "ツンデレ" ? "かえで" : "しずる"),
      p: _selectedP,
      apiKey: _keyCtrl.text,
    );
    await widget.replyService.addFirstMessage(widget.replyService.selfIntro);
    await widget.replyService.completeSetup();
    if (mounted) widget.onComplete();
  }

  Widget _buildLangBtn(String lang) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton.icon(
        onPressed: _showLang,
        icon: const Icon(Icons.language, color: Colors.pinkAccent, size: 18),
        label: Text(
          lang == 'ja' ? "日本語" : "English",
          style: const TextStyle(color: Colors.pinkAccent, fontSize: 13),
        ),
      ),
    );
  }

  void _showLang() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("日本語"),
              onTap: () async {
                await widget.replyService.setLanguage('ja');
                if (mounted) {
                  setState(() {});
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              title: const Text("English"),
              onTap: () async {
                await widget.replyService.setLanguage('en');
                if (mounted) {
                  setState(() {});
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
