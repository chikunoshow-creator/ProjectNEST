import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

class BackupView extends StatefulWidget {
  final ReplyService replyService;
  final VoidCallback onRestored;

  const BackupView({
    super.key,
    required this.replyService,
    required this.onRestored,
  });

  @override
  State<BackupView> createState() => _BackupViewState();
}

class _BackupViewState extends State<BackupView> {
  String? _backupDate;

  @override
  void initState() {
    super.initState();
    _loadDate();
  }

  Future<void> _loadDate() async {
    String? date = await widget.replyService.getBackupDate();
    setState(() => _backupDate = date);
  }

  void _createBackup() async {
    final lang = widget.replyService.language;
    final themeColor = widget.replyService.themeColor;

    await widget.replyService.saveToInternalSlot();
    _executeFileDownload();
    _loadDate();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(T.get('backup_success', lang)),
          backgroundColor: themeColor, // 通知の色を連動
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _executeFileDownload() {
    final data = widget.replyService.exportAllData();
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute(
        "download",
        "nest_backup_${widget.replyService.displayName}.json",
      )
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  void _restoreFromInternal() async {
    final lang = widget.replyService.language;
    final themeColor = widget.replyService.themeColor;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(T.get('restore_confirm_title', lang)),
        content: Text(T.get('restore_confirm_msg', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(
              T.get('cancel', lang),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text(
              T.get('restore_btn', lang),
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    bool success = await widget.replyService.restoreFromInternalSlot();
    if (success) {
      widget.onRestored();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(T.get('restore_success', lang)),
            backgroundColor: themeColor, // 通知の色を連動
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(T.get('no_backup_data', lang))));
      }
    }
  }

  void _restoreFromFile() {
    final lang = widget.replyService.language;
    final themeColor = widget.replyService.themeColor;
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.json';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;
      final reader = html.FileReader();
      reader.readAsText(files[0]);
      reader.onLoadEnd.listen((e) async {
        try {
          final Map<String, dynamic> data = jsonDecode(reader.result as String);
          await widget.replyService.importAllData(data);
          widget.onRestored();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(T.get('restore_success', lang)),
                backgroundColor: themeColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(T.get('restore_error', lang))),
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.replyService.language;
    final themeColor = widget.replyService.themeColor;
    final scaffoldBg = themeColor.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: scaffoldBg, // 背景色を連動
      appBar: AppBar(
        title: Text(
          T.get('menu_backup_title', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: themeColor, // 文字色を連動
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildInfoCard(lang, themeColor), // カード内のアイコン色を連動
          const SizedBox(height: 32),

          _buildSectionTitle(lang == 'ja' ? "保存する" : "Save"),
          _buildActionCard(
            title: T.get('backup_create', lang),
            desc: T.get('backup_create_sub', lang),
            icon: Icons.cloud_upload_rounded,
            onTap: _createBackup,
            color: themeColor, // メインアクションをテーマ色に
          ),

          const SizedBox(height: 32),
          _buildSectionTitle(lang == 'ja' ? "復元する" : "Restore"),
          _buildActionCard(
            title: lang == 'ja' ? "前回のデータから復元" : "Restore from App",
            desc: lang == 'ja'
                ? "アプリ内に保存された最新データに戻します。"
                : "Restore from the latest internal save.",
            icon: Icons.settings_backup_restore_rounded,
            onTap: _restoreFromInternal,
            color: Colors.blueAccent, // 復元は「戻す」イメージの青系で固定（またはテーマ色）
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            title: lang == 'ja' ? "ファイルを選択して復元" : "Restore from File",
            desc: lang == 'ja'
                ? "保存したjsonファイルから読み込みます。"
                : "Load data from a .json file.",
            icon: Icons.file_open_rounded,
            onTap: _restoreFromFile,
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black45,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String lang, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, color: themeColor), // アイコン色を連動
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                T.get('last_backup', lang),
                style: const TextStyle(fontSize: 12, color: Colors.black38),
              ),
              Text(
                _backupDate ?? T.get('no_backup_data', lang),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 10, color: Colors.black38),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black12),
          ],
        ),
      ),
    );
  }
}
