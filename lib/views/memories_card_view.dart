import 'dart:html' as html;
import 'dart:js' as js; // ★ JS呼び出しのために追加
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

class MemoriesCardView extends StatefulWidget {
  final ReplyService replyService;
  const MemoriesCardView({super.key, required this.replyService});

  @override
  State<MemoriesCardView> createState() => _MemoriesCardViewState();
}

class _MemoriesCardViewState extends State<MemoriesCardView> {
  final GlobalKey _cardKey = GlobalKey();

  String _getShareText(String lang) {
    return T
        .get('card_share_template', lang)
        .replaceAll('{name}', widget.replyService.displayName)
        .replaceAll('{days}', widget.replyService.daysTogether.toString());
  }

  // --- 画像キャプチャの共通処理（フリーズ対策版） ---
  Future<Uint8List?> _capturePng() async {
    try {
      // ★ 描画（白い背景Containerなど）を確実に完了させるための待機
      await Future.delayed(const Duration(milliseconds: 100));

      RenderRepaintBoundary? boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      // 描画オブジェクトが見つからない場合は即座に終了
      if (boundary == null) {
        debugPrint("Boundary is null");
        return null;
      }

      // キャプチャ実行
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Capture Error: $e");
      return null;
    }
  }

  // --- 1. システム共有を実行するメインロジック ---
  // --- 1. システム共有を実行するメインロジック（安全版） ---
  Future<void> _shareMemories(BuildContext context, String lang) async {
    // キャプチャ開始
    Uint8List? pngBytes = await _capturePng();
    if (pngBytes == null) return;

    try {
      // ファイルオブジェクトの作成
      final blob = html.Blob([pngBytes], 'image/png');
      final fileName = "NEST_Card_${widget.replyService.displayName}.png";
      final file = html.File([blob], fileName, {'type': 'image/png'});

      final title = "Project NEST";
      final text = _getShareText(lang);

      // ★ JS呼び出し：結果を動的に受け取り、エラーを防止
      final result = await js.context.callMethod('shareFile', [
        file,
        title,
        text,
      ]);

      // JS側で false が返された（シェア非対応）場合は保存処理へ
      if (result == false) {
        await _saveImageLocally(pngBytes, context, lang, fallback: true);
      }
    } catch (e) {
      debugPrint("Share Logic Error: $e");
      // ★ 万が一JS連携でエラーが起きても、フリーズさせずに保存処理を実行
      await _saveImageLocally(pngBytes, context, lang, fallback: true);
    }
  }

  // --- 2. 純粋な画像保存（ダウンロード） ---
  Future<void> _saveImageLocally(
    Uint8List? bytes,
    BuildContext context,
    String lang, {
    bool fallback = false,
  }) async {
    Uint8List? pngBytes = bytes ?? await _capturePng();
    if (pngBytes == null) return;

    final blob = html.Blob([pngBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute(
        "download",
        "NEST_Card_${widget.replyService.displayName}.png",
      )
      ..click();
    html.Url.revokeObjectUrl(url);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fallback
                ? T.get('share_failed_fallback', lang)
                : T.get('backup_success', lang),
          ),
          backgroundColor: widget.replyService.themeColor,
        ),
      );
    }
  }

  // --- 3. テキストコピー ---
  void _copyText(BuildContext context, String lang) {
    Clipboard.setData(ClipboardData(text: _getShareText(lang)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(T.get('card_copy_success', lang)),
        backgroundColor: widget.replyService.themeColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.replyService.language;
    final charKey = widget.replyService.charKey;
    final themeColor = widget.replyService.themeColor;
    final scaffoldBg = themeColor.withOpacity(0.05);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          T.get('card_title', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        foregroundColor: themeColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Center(
              child: RepaintBoundary(
                key: _cardKey,
                // ★ 色のくすみ対策：キャプチャ対象を不透明な白Containerで包む
                child: Container(
                  color: Colors.white,
                  child: _buildCardUI(lang, charKey, themeColor),
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildNewActionArea(lang, context, themeColor),
          ],
        ),
      ),
    );
  }

  // カードUI自体は美しさを維持（変更なし）
  Widget _buildCardUI(String lang, String charKey, Color themeColor) {
    final rank = widget.replyService.intimacyRank;
    final isRankS = (rank == "S");
    String sinceDate = "2024.01.01";
    if (widget.replyService.startDate.isNotEmpty) {
      try {
        sinceDate = DateFormat(
          'yyyy.MM.dd',
        ).format(DateTime.parse(widget.replyService.startDate));
      } catch (e) {
        sinceDate = "2024.01.01";
      }
    }

    return Container(
      width: 380,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isRankS
              ? [
                  const Color(0xFFFFD700).withOpacity(0.2),
                  Colors.white,
                  const Color(0xFFDAA520).withOpacity(0.1),
                ]
              : [themeColor.withOpacity(0.15), Colors.white],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isRankS
              ? const Color(0xFFFFD700).withOpacity(0.5)
              : Colors.white,
          width: isRankS ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isRankS ? const Color(0xFFFFD700) : themeColor).withOpacity(
              0.1,
            ),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.favorite,
              size: 150,
              color: themeColor.withOpacity(0.03),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 5),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.grey[100],
                            backgroundImage: AssetImage(
                              "assets/images/${charKey}_icon.webp",
                            ),
                          ),
                        ),
                        Positioned(
                          right: -8,
                          bottom: 0,
                          child: _buildRankBadge(rank),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.replyService.displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isRankS ? const Color(0xFFB8860B) : themeColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        T.get('card_days_together', lang),
                        "${widget.replyService.daysTogether} ${T.get('card_days_unit', lang)}",
                        Icons.calendar_today_rounded,
                      ),
                      const SizedBox(height: 12),
                      _infoRow(
                        T.get('card_intimacy', lang),
                        "❤️ ${widget.replyService.intimacyScore}",
                        Icons.favorite_rounded,
                      ),
                      const SizedBox(height: 12),
                      _infoRow(
                        T.get('card_messages', lang),
                        "${widget.replyService.messageCount} msg",
                        Icons.chat_bubble_outline_rounded,
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              T.get('card_since', lang),
                              style: const TextStyle(
                                fontSize: 7,
                                color: Colors.black26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              sinceDate,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black45,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 新しいアクションエリア：ボタンを整理 ---
  Widget _buildNewActionArea(
    String lang,
    BuildContext context,
    Color themeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // 1. メインシェアボタン
          ElevatedButton.icon(
            onPressed: () => _shareMemories(context, lang),
            icon: const Icon(Icons.ios_share_rounded, size: 24),
            label: Text(
              T.get('share_memories_btn', lang),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
          ),
          const SizedBox(height: 20),

          // 2. 対応アイコンガイド
          // 2. 対応アイコンガイド（ブランドタグ形式）
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                T.get('share_compatible_apps', lang),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black38,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              _brandTag(Icons.close, "X", Colors.black),
              _brandTag(Icons.chat_bubble, "LINE", const Color(0xFF06C755)),
              _brandTag(
                Icons.phone_android,
                "WhatsApp",
                const Color(0xFF25D366),
              ),
              _brandTag(Icons.discord, "Discord", const Color(0xFF5865F2)),
            ],
          ),
          const SizedBox(height: 40),

          // 3. サブボタン（保存・コピー）
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _saveImageLocally(null, context, lang),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    T.get('share_save_only', lang),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeColor,
                    side: BorderSide(color: themeColor.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copyText(context, lang),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(
                    T.get('share_copy_text', lang),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: themeColor,
                    side: BorderSide(color: themeColor.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 改良版：ブランド名付きのタグ表示 ---
  Widget _brandTag(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --- ヘルパー群 ---
  Widget _buildRankBadge(String rank) {
    Color badgeColor = Colors.grey;
    if (rank == "S")
      badgeColor = const Color(0xFFFFD700);
    else if (rank == "A")
      badgeColor = const Color(0xFFFF4500);
    else if (rank == "B")
      badgeColor = Colors.purple;
    else if (rank == "C")
      badgeColor = Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Text(
        "Rank $rank",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: Colors.black26),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.black38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
