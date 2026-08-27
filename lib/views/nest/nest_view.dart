import 'package:flutter/material.dart';
import '../../services/reply_service.dart'; // パスが一段深くなったので修正
import '../../services/translation_service.dart';

class NestView extends StatefulWidget {
  final ReplyService replyService;
  final bool isGeneratingDiary;
  final VoidCallback onCreateDiary;
  final Widget background;

  const NestView({
    super.key,
    required this.replyService,
    required this.isGeneratingDiary,
    required this.onCreateDiary,
    required this.background,
  });

  @override
  State<NestView> createState() => _NestViewState();
}

class _NestViewState extends State<NestView> {
  bool _isProfileVisible = true;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 700;
    String charPrefix = widget.replyService.charKey;

    return Stack(
      children: [
        // 1. 背景層
        widget.background,

        // 2. キャラクター層（黄金比配置）
        Positioned.fill(
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            // プロフィールが出ている時は少し左に寄せる演出（デスクトップのみ）
            alignment: isMobile
                ? Alignment.bottomCenter
                : (_isProfileVisible
                      ? const Alignment(-0.3, 1.0)
                      : Alignment.bottomCenter),
            child: Image.asset(
              "assets/images/${charPrefix}_normal.png",
              height: isMobile ? screenHeight * 0.80 : screenHeight * 0.90,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // 3. プロフィール層（下半身を隠す枠）
        Align(
          alignment: isMobile ? Alignment.bottomCenter : Alignment.centerRight,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: _isProfileVisible ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !_isProfileVisible,
              child: _buildResponsiveProfile(
                isMobile,
                screenWidth,
                screenHeight,
              ),
            ),
          ),
        ),

        // 4. 操作UI層
        Positioned(
          top: 100,
          right: 20,
          child: FloatingActionButton.small(
            elevation: 2,
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            foregroundColor: Colors.pinkAccent,
            onPressed: () =>
                setState(() => _isProfileVisible = !_isProfileVisible),
            child: Icon(
              _isProfileVisible ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveProfile(
    bool isMobile,
    double screenWidth,
    double screenHeight,
  ) {
    return Container(
      width: isMobile ? double.infinity : screenWidth * 0.42,
      height: isMobile ? screenHeight * 0.48 : double.infinity,
      // スマホ版では下からせり上がる、PC版では右から出てくるマージン設定
      margin: isMobile
          ? const EdgeInsets.fromLTRB(15, 0, 15, 10)
          : const EdgeInsets.fromLTRB(0, 80, 30, 80),
      child: _buildProfileContent(isMobile),
    );
  }

  Widget _buildProfileContent(bool isMobile) {
    final lang = widget.replyService.language;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        // より透明感のある白
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 名前と親密度
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.replyService.displayName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "${lang == 'ja' ? "本名" : "Full Name"}: ${widget.replyService.fullPersonalityName}",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.pinkAccent.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              //const SizedBox(height: 15),
              _buildIntimacyBadge(lang),
            ],
          ),
          const SizedBox(height: 20),

          // スクロール可能な詳細エリア
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(T.get('self_intro_title', lang)),
                  Text(
                    widget.replyService.selfIntro,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle(T.get('likes_title', lang)),
                  Text(
                    widget.replyService.likes,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle(T.get('dislikes_title', lang)),
                  Text(
                    widget.replyService.dislikes,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          //_buildDiaryButton(lang),
        ],
      ),
    );
  }

  Widget _buildIntimacyBadge(String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.pinkAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, color: Colors.pinkAccent, size: 18),
          const SizedBox(width: 6),
          Text(
            "${widget.replyService.intimacyScore}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.pinkAccent.withValues(alpha: 0.6),
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
