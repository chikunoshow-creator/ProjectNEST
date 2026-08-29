// import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../services/reply_service.dart';
import '../services/translation_service.dart';

class MemoriesCardView extends StatelessWidget {
  final ReplyService replyService;
  final GlobalKey _cardKey = GlobalKey();

  MemoriesCardView({super.key, required this.replyService});

  // --- 共通：共有用テキストの作成 ---
  String _getShareText(String lang) {
    return T
        .get('card_share_template', lang)
        .replaceAll('{name}', replyService.displayName)
        .replaceAll('{days}', replyService.daysTogether.toString());
  }

  // --- 1. 画像のキャプチャとダウンロード処理 (共通) ---
  Future<void> _captureAndSave(
    BuildContext context,
    String lang, {
    bool showSnackBar = true,
  }) async {
    try {
      RenderRepaintBoundary boundary =
          _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final blob = html.Blob([pngBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "NEST_Memories_Card.png")
        ..click();
      html.Url.revokeObjectUrl(url);

      if (showSnackBar) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(T.get('backup_success', lang))));
      }
    } catch (e) {
      debugPrint("Capture Error: $e");
    }
  }

  // --- 2. 画像保存 ＋ SNSシェアを同時に行う ---
  Future<void> _captureAndShareSns(
    String platform,
    String lang,
    BuildContext context,
  ) async {
    // まず画像を保存（スナックバーは出さない）
    await _captureAndSave(context, lang, showSnackBar: false);

    // その後、SNSを開く
    final text = _getShareText(lang);
    String url = "";

    switch (platform) {
      case 'x':
        url =
            "https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}";
        break;
      case 'line':
        url = "https://line.me/R/msg/text/?${Uri.encodeComponent(text)}";
        break;
      case 'whatsapp':
        url = "https://wa.me/?text=${Uri.encodeComponent(text)}";
        break;
      case 'discord':
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(T.get('share_discord_done', lang))),
        );
        url = "https://discord.com/channels/@me";
        break;
    }

    if (url.isNotEmpty) {
      html.window.open(url, "_blank");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = replyService.language;
    final charKey = replyService.charKey;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        title: Text(
          T.get('card_title', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            // カード本体
            Center(
              child: RepaintBoundary(
                key: _cardKey,
                child: _buildCardUI(lang, charKey),
              ),
            ),
            const SizedBox(height: 40),

            // アクションエリア
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    T.get('card_share_hint', lang),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // SNSボタンのグリッド（画像保存 ＋ シェア）
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3.2,
                    children: [
                      _buildSnsButton(
                        Icons.close,
                        T.get('share_x', lang),
                        Colors.black,
                        () => _captureAndShareSns('x', lang, context),
                      ),
                      _buildSnsButton(
                        Icons.chat_bubble,
                        T.get('share_line', lang),
                        const Color(0xFF06C755),
                        () => _captureAndShareSns('line', lang, context),
                      ),
                      _buildSnsButton(
                        Icons.phone_android,
                        T.get('share_whatsapp', lang),
                        const Color(0xFF25D366),
                        () => _captureAndShareSns('whatsapp', lang, context),
                      ),
                      _buildSnsButton(
                        Icons.discord,
                        T.get('share_discord', lang),
                        const Color(0xFF5865F2),
                        () => _captureAndShareSns('discord', lang, context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  const Divider(),
                  const SizedBox(height: 20),

                  // 保存のみしたい人向けのボタン（下部に配置）
                  TextButton.icon(
                    onPressed: () => _captureAndSave(context, lang),
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.pinkAccent,
                      size: 20,
                    ),
                    label: Text(
                      T.get('share_save_btn', lang),
                      style: const TextStyle(
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: Colors.pinkAccent.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 以下、補助UIパーツ (_buildCardUI, _buildSnsButton 等は前回を継承) ---
  // ... (コードが重複するため省略しますが、実際のファイルには含めてください)
  // --- カードのデザイン本体（前回と同じですが整理しました） ---
  Widget _buildCardUI(String lang, String charKey) {
    return Container(
      width: 380,
      height: 220,
      decoration: BoxDecoration(
        // ★ カード全体の背景にグラデーションを設定
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.pinkAccent.withValues(alpha: 0.15), // 左端：淡いピンク
            Colors.white, // 右側：完全な白
          ],
          // ★ 0.0（左端）から 0.6（約2/3）にかけて白へ変化させ、残りは白にする設定
          stops: const [0.0, 0.6],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // --- 左側：キャラクタービジュアルエリア ---
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // アイコンを際立たせるための白い縁取り
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
                    radius: 45,
                    backgroundImage: AssetImage(
                      "assets/images/${charKey}_icon.png",
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  replyService.displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pinkAccent,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // --- 右側：ステータス情報エリア（背景は既に真っ白） ---
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _infoRow(
                    T.get('card_days_together', lang),
                    "${replyService.daysTogether}${T.get('card_days_unit', lang)}",
                    Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 18),
                  _infoRow(
                    T.get('card_intimacy', lang),
                    "❤️ ${replyService.intimacyScore}",
                    Icons.favorite_rounded,
                  ),
                  const Spacer(),
                  // 右下の公式クレジット
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Project NEST - Official Partner",
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.black12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          "Issued by Chiku",
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.pinkAccent.withValues(alpha: 0.25),
                            fontWeight: FontWeight.bold,
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
    );
  }

  // 右側セクション用の小パーツ
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
                fontSize: 10,
                color: Colors.black38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSnsButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
