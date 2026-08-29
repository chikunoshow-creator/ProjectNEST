import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/reply_service.dart';
import '../services/translation_service.dart';
import '../views/album_view.dart';
import '../views/diary_list_page.dart';
import '../views/memories_card_view.dart';

class MainDrawer extends StatelessWidget {
  final ReplyService replyService;
  final VoidCallback onBgChanged;
  final VoidCallback onShowPrecautions;
  final VoidCallback onShowPwaGuide;
  final VoidCallback onShowResetDialog;

  const MainDrawer({
    super.key,
    required this.replyService,
    required this.onBgChanged,
    required this.onShowPrecautions,
    required this.onShowPwaGuide,
    required this.onShowResetDialog,
  });

  @override
  Widget build(BuildContext context) {
    final lang = replyService.language;
    final charKey = replyService.charKey;

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(40)),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F5), Colors.white],
          ),
        ),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.pink[50],
                      backgroundImage: AssetImage(
                        "assets/images/${charKey}_icon.png",
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    T
                        .get('nest_toolbox', lang)
                        .replaceAll('{name}', replyService.displayName),
                    style: const TextStyle(
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    _buildDrawerItem(
                      Icons.photo_library_rounded,
                      T.get('album', lang),
                      Colors.pinkAccent,
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => AlbumView(
                              replyService: replyService,
                              onBgChanged: onBgChanged,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      Icons.menu_book_rounded,
                      T.get('diary', lang),
                      Colors.orangeAccent,
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => DiaryListPage(
                              diaries: replyService.getDiaries(),
                              replyService: replyService,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      Icons.card_membership_rounded,
                      T.get('menu_memories_card', lang),
                      Colors.purpleAccent,
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) =>
                                MemoriesCardView(replyService: replyService),
                          ),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Colors.pinkAccent, thickness: 0.1),
                    ),
                    _buildDrawerItem(
                      Icons.info_outline_rounded,
                      T.get('precautions', lang),
                      Colors.blueGrey,
                      () {
                        Navigator.pop(context);
                        onShowPrecautions();
                      },
                    ),
                    _buildDrawerItem(
                      Icons.install_mobile_rounded,
                      T.get('install', lang),
                      Colors.blueAccent,
                      () {
                        Navigator.pop(context);
                        onShowPwaGuide();
                      },
                    ),
                    _buildDrawerItem(
                      Icons.feedback_rounded,
                      T.get('report', lang),
                      Colors.tealAccent,
                      () async {
                        Navigator.pop(context);
                        const url =
                            "https://docs.google.com/forms/d/e/1FAIpQLSemVkpoQhlTJOGK6HIc6ljjavGWSy9K6idlscnNVzutUuWf5g/viewform?pli=1";
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            // 下部のリセットセクション（修正箇所のみ抜粋）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onShowResetDialog();
                    },
                    icon: const Icon(
                      Icons.history_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                    label: Text(
                      T.get('history_reset', lang),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  Text(
                    T.get('talk_reset_note', lang), // ★ 辞書化
                    style: const TextStyle(color: Colors.black26, fontSize: 10),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 12),
              child: Column(
                children: [
                  const Divider(indent: 50, endIndent: 50, thickness: 0.5),
                  const SizedBox(height: 12),
                  Text(
                    "Project NEST Ver ${replyService.appVersion}",
                    style: const TextStyle(
                      color: Colors.black26,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Developed by Chiku",
                    style: TextStyle(
                      color: Colors.pinkAccent.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "©2026 Chiku",
                    style: TextStyle(color: Colors.black26, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 16,
        color: Colors.black26,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}
