import 'package:flutter/material.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';
import 'profile_edit_view.dart';
import 'nest_edit_view.dart';
import 'ai_system_view.dart';
import 'help_view.dart';
import 'privacy_policy_view.dart';
import 'placeholder_view.dart';
import 'backup_view.dart';

class MyPageView extends StatelessWidget {
  final ReplyService replyService;
  final VoidCallback onResetAll;
  final VoidCallback onSettingsUpdated;
  final VoidCallback onShowAlbum;
  final VoidCallback onCheckUpdate;

  const MyPageView({
    super.key,
    required this.replyService,
    required this.onResetAll,
    required this.onSettingsUpdated,
    required this.onShowAlbum,
    required this.onCheckUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final lang = replyService.language;
    final themeColor = replyService.themeColor;
    final scaffoldBg = themeColor.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: scaffoldBg, // 背景色を連動
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 100)),

          _buildSectionHeader(lang == 'ja' ? "アカウント設定" : "Account Settings"),

          SliverList(
            delegate: SliverChildListDelegate([
              _buildMenuTile(
                context,
                icon: Icons.cloud_sync_rounded,
                title: T.get('menu_backup_title', lang),
                subtitle: T.get('menu_backup_sub', lang),
                destination: BackupView(
                  replyService: replyService,
                  onRestored: () => onSettingsUpdated(),
                ),
              ),
              _buildMenuTile(
                context,
                icon: Icons.person_outline_rounded,
                title: T.get('menu_profile_title', lang),
                subtitle: T.get('menu_profile_sub', lang),
                destination: ProfileEditView(
                  replyService: replyService,
                  onSettingsUpdated: onSettingsUpdated,
                ),
              ),
              _buildMenuTile(
                context,
                icon: Icons.favorite_outline_rounded,
                title: T.get('menu_nest_title', lang),
                subtitle: T.get('menu_nest_sub', lang),
                destination: NestEditView(
                  replyService: replyService,
                  onSettingsUpdated: onSettingsUpdated,
                ),
              ),
              _buildMenuTile(
                context,
                icon: Icons.psychology_outlined,
                title: T.get('menu_ai_title', lang),
                subtitle: T.get('menu_ai_sub', lang),
                destination: AiSystemView(
                  replyService: replyService,
                  onSettingsUpdated: onSettingsUpdated,
                ),
              ),
            ]),
          ),

          _buildSectionHeader(lang == 'ja' ? "テーマ設定" : "Theme"),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: Colors.white, // カードを白に固定してスッキリさせる
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.palette_outlined, color: Colors.black26),
                      const SizedBox(width: 16),
                      _themeCircle(context, "pink", Colors.pinkAccent),
                      const SizedBox(width: 16),
                      _themeCircle(context, "blue", Colors.blueAccent),
                    ],
                  ),
                ),
              ),
            ),
          ),

          _buildSectionHeader(lang == 'ja' ? "サポート" : "Support"),

          SliverList(
            delegate: SliverChildListDelegate([
              _buildMenuTile(
                context,
                icon: Icons.help_outline_rounded,
                title: T.get('menu_help_title', lang),
                subtitle: T.get('menu_help_sub', lang),
                destination: HelpView(replyService: replyService),
              ),
              _buildMenuTile(
                context,
                icon: Icons.gavel_rounded,
                title: T.get('menu_policy_title', lang),
                subtitle: T.get('menu_policy_sub', lang),
                destination: PrivacyPolicyView(replyService: replyService),
              ),
              _buildMenuTile(
                context,
                icon: Icons.coffee_rounded,
                title: T.get('menu_support_title', lang),
                subtitle: T.get('menu_support_sub', lang),
                destination: PlaceholderView(
                  title: T.get('menu_support_title', lang),
                  replyService: replyService,
                ),
              ),
            ]),
          ),

          _buildSectionHeader(lang == 'ja' ? "アプリ情報" : "App Info"),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: themeColor,
                  ), // ★ アイコン色連動
                  title: const Text(
                    "Version",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Ver ${replyService.appVersion}"),
                  trailing: TextButton(
                    onPressed: onCheckUpdate,
                    child: Text(
                      T.get('version_check_btn', lang),
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          _buildSectionHeader(lang == 'ja' ? "重要な操作" : "Critical Actions"),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 0,
                color: Colors.redAccent.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                  ),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    T.get('history_reset', lang),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.redAccent,
                  ),
                  onTap: () => _showResetMenu(context, lang),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget destination,
  }) {
    final themeColor = replyService.themeColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        color: Colors.white, // ★ カード背景を白に固定してスッキリ
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withValues(
                alpha: 0.1,
              ), // ★ 色を少し濃く(0.05->0.1)して青を強調
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: themeColor, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.black12,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          ),
        ),
      ),
    );
  }

  // --- 内部メソッド（reset, themeCircle 等）は変更なし ---
  void _showResetMenu(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                T.get('reset_ask', lang),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            _buildResetTile(
              context,
              lang,
              Icons.chat_bubble_outline_rounded,
              Colors.blue,
              T.get('reset_talk', lang),
              T.get('reset_talk_sub', lang),
              onResetAll,
            ),
            _buildResetTile(
              context,
              lang,
              Icons.face_retouching_natural_rounded,
              Colors.pinkAccent,
              T.get('reset_nest', lang),
              T.get('reset_nest_sub', lang),
              () async {
                await replyService.resetNest();
                onResetAll();
              },
            ),
            _buildResetTile(
              context,
              lang,
              Icons.phonelink_erase_rounded,
              Colors.redAccent,
              T.get('reset_app', lang),
              T.get('reset_app_sub', lang),
              () async {
                await replyService.resetApp();
                onResetAll();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildResetTile(
    BuildContext context,
    String lang,
    IconData icon,
    Color color,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      onTap: () {
        Navigator.pop(context);
        _confirmReset(context, lang, title, onTap);
      },
    );
  }

  Widget _themeCircle(BuildContext context, String themeName, Color color) {
    bool isSelected = replyService.selectedTheme == themeName;
    return InkWell(
      onTap: () async {
        await replyService.setTheme(themeName);
        onSettingsUpdated();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }

  void _confirmReset(
    BuildContext context,
    String lang,
    String title,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          lang == 'ja'
              ? "この操作は二度と戻せないけど、本当にいい？"
              : "This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              T.get('cancel', lang),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: Text(
              T.get('reset_btn', lang),
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
