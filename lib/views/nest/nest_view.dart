import 'package:flutter/material.dart';
import '../../services/reply_service.dart';
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

    // ★ テーマ色の取得
    final themeColor = widget.replyService.themeColor;

    return Stack(
      children: [
        // 1. 背景層
        widget.background,

        // 2. キャラクター層
        Positioned.fill(
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            alignment: isMobile
                ? Alignment.bottomCenter
                : (_isProfileVisible
                      ? const Alignment(-0.3, 1.0)
                      : Alignment.bottomCenter),
            child: Image.asset(
              "assets/images/${charPrefix}_normal.webp",
              height: isMobile ? screenHeight * 0.80 : screenHeight * 0.90,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // 3. プロフィール層
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
                themeColor, // ★ 色を渡す
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
            foregroundColor: themeColor, // ★ ボタンのアイコン色を連動
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
    Color themeColor,
  ) {
    return Container(
      width: isMobile ? double.infinity : screenWidth * 0.42,
      height: isMobile ? screenHeight * 0.48 : double.infinity,
      margin: isMobile
          ? const EdgeInsets.fromLTRB(15, 0, 15, 10)
          : const EdgeInsets.fromLTRB(0, 80, 30, 80),
      child: _buildProfileContent(isMobile, themeColor), // ★ 色を渡す
    );
  }

  Widget _buildProfileContent(bool isMobile, Color themeColor) {
    final lang = widget.replyService.language;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.1), // ★ 影の色を連動
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
              Expanded(
                child: Text(
                  widget.replyService.displayName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: themeColor, // ★ 名前色を連動
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _buildIntimacyBadge(themeColor), // ★ 色を渡す
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "${lang == 'ja' ? "本名" : "Full Name"}: ${widget.replyService.fullPersonalityName}",
            style: TextStyle(
              fontSize: 12,
              color: themeColor.withValues(alpha: 0.7), // ★ 本名の文字色を連動
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // スクロールエリア
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                    T.get('self_intro_title', lang),
                    themeColor,
                  ),
                  Text(
                    widget.replyService.selfIntro,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle(T.get('likes_title', lang), themeColor),
                  Text(
                    widget.replyService.likes,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  _buildSectionTitle(T.get('dislikes_title', lang), themeColor),
                  Text(
                    widget.replyService.dislikes,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildIntimacyBadge(Color themeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.1), // ★ バッジ背景を連動
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: themeColor, size: 18), // ★ ハートの色を連動
          const SizedBox(width: 6),
          Text(
            "${widget.replyService.intimacyScore}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeColor, // ★ スコアの色を連動
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: themeColor.withValues(alpha: 0.6), // ★ セクションタイトルの色を連動
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
