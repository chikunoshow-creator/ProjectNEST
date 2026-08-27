import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/reply_service.dart';
import '../services/translation_service.dart'; // ★ インポート追加

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
    // 現在の言語を取得
    final lang = replyService.language;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        title: Text(T.get('diary', lang)), // ★ 辞書を使用
        backgroundColor: Colors.white.withValues(alpha: 0.9), // ★ 最新仕様に修正
        elevation: 0,
        foregroundColor: Colors.pinkAccent,
      ),
      body: diaries.isEmpty
          ? _buildEmptyState(lang) // ★ langを渡すように修正
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: diaries.length,
              itemBuilder: (context, index) {
                return _buildDiaryCard(context, diaries[index], lang);
              },
            ),
    );
  }

  // --- 日記が空の時のデザイン ---
  Widget _buildEmptyState(String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 80,
            color: Colors.pinkAccent.withValues(alpha: 0.3), // ★ 修正
          ),
          const SizedBox(height: 20),
          Text(
            T.get('no_diary_title', lang), // ★ 辞書を使用 (constを削除)
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent.withValues(alpha: 0.5), // ★ 修正
            ),
          ),
          const SizedBox(height: 10),
          Text(
            T.get('no_diary_msg', lang), // ★ 辞書を使用
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black45, height: 1.5),
          ),
        ],
      ),
    );
  }

  // --- 1日分の日記カード ---
  Widget _buildDiaryCard(BuildContext context, DiaryEntry entry, String lang) {
    String dateStr = DateFormat('yyyy.MM.dd').format(entry.date);
    String dayStr = DateFormat('EEE').format(entry.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), // ★ 修正
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _showDiaryDetail(context, entry, lang),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 6, color: _getThemeColor()),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dayStr,
                              style: TextStyle(
                                color: Colors.pinkAccent.withValues(
                                  alpha: 0.7,
                                ), // ★ 修正
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.pinkAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          entry.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
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

  // --- 日記の詳細表示（ダイアログ） ---
  void _showDiaryDetail(BuildContext context, DiaryEntry entry, String lang) {
    String dateStr = DateFormat('yyyy年 MM月 dd日').format(entry.date);
    if (lang == 'en') {
      dateStr = DateFormat('MMM dd, yyyy').format(entry.date);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Column(
          children: [
            Text(
              dateStr,
              style: const TextStyle(fontSize: 14, color: Colors.black45),
            ),
            const SizedBox(height: 5),
            Text(
              // ★ nestName ではなく displayName を使う
              "${replyService.displayName}${lang == 'ja' ? 'の日記' : '\'s Diary'}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const Divider(),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            entry.content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.8,
              letterSpacing: 0.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Color _getThemeColor() {
    switch (replyService.personality) {
      case "クールなお姉さん":
        return Colors.blueAccent.withValues(alpha: 0.5);
      case "ツンデレ":
        return Colors.orangeAccent.withValues(alpha: 0.5);
      default:
        return Colors.pinkAccent.withValues(alpha: 0.5);
    }
  }
}
