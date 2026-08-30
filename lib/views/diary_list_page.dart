import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/reply_service.dart';
import '../services/translation_service.dart';

class DiaryListPage extends StatelessWidget {
  final List<DiaryEntry> diaries;
  final ReplyService replyService;

  const DiaryListPage({
    super.key,
    required this.diaries,
    required this.replyService,
  });

  @override
  Widget build(BuildContext context) {
    final lang = replyService.language;
    final themeColor = replyService.themeColor;
    final scaffoldBg = themeColor.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: scaffoldBg, // 背景色を連動
      appBar: AppBar(
        title: Text(T.get('diary', lang)),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: themeColor, // 文字色を連動
      ),
      body: diaries.isEmpty
          ? _buildEmptyState(lang, themeColor) // 色を渡す
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: diaries.length,
              itemBuilder: (context, index) {
                return _buildDiaryCard(
                  context,
                  diaries[index],
                  lang,
                  themeColor,
                );
              },
            ),
    );
  }

  // 空の状態のデザイン
  Widget _buildEmptyState(String lang, Color themeColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 80,
            color: themeColor.withValues(alpha: 0.3), // アイコン色を連動
          ),
          const SizedBox(height: 20),
          Text(
            T.get('no_diary_title', lang),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            T.get('no_diary_msg', lang),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black45, height: 1.5),
          ),
        ],
      ),
    );
  }

  // 1日分の日記カード
  Widget _buildDiaryCard(
    BuildContext context,
    DiaryEntry entry,
    String lang,
    Color themeColor,
  ) {
    String dateStr = DateFormat('yyyy.MM.dd').format(entry.date);
    String dayStr = DateFormat('EEE').format(entry.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _showDiaryDetail(context, entry, lang, themeColor),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // 左端の線（性格カラーを優先しつつ、デフォルトをテーマ色に）
                Container(width: 6, color: _getThemeColor(themeColor)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dayStr,
                              style: TextStyle(
                                color: themeColor.withValues(
                                  alpha: 0.5,
                                ), // 曜日を連動
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              entry.mood,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.title.isNotEmpty ? entry.title : "......",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 詳細ダイアログ
  void _showDiaryDetail(
    BuildContext context,
    DiaryEntry entry,
    String lang,
    Color themeColor,
  ) {
    String dateStr = lang == 'ja'
        ? DateFormat('yyyy年 MM月 dd日').format(entry.date)
        : DateFormat('MMM dd, yyyy').format(entry.date);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        titlePadding: const EdgeInsets.only(top: 25, left: 20, right: 20),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(entry.mood, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    entry.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 12, color: Colors.black38),
            ),
            const SizedBox(height: 5),
            Text(
              T
                  .get('diary_owner_title', lang)
                  .replaceAll('{name}', replyService.displayName),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: themeColor, // タイトル色を連動
              ),
            ),
            const Divider(),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            entry.content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.8,
              letterSpacing: 0.5,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: TextStyle(color: themeColor)), // ボタン色を連動
          ),
        ],
      ),
    );
  }

  // カード横のアクセントカラー
  Color _getThemeColor(Color fallback) {
    switch (replyService.personality) {
      case "クールなお姉さん":
        return Colors.blueAccent.withValues(alpha: 0.5);
      case "ツンデレ":
        return Colors.orangeAccent.withValues(alpha: 0.5);
      default:
        // 「甘えん坊」かつブルーテーマの場合は、ピンクではなく現在のテーマ色を使う
        return fallback.withValues(alpha: 0.5);
    }
  }
}
