import 'package:flutter/material.dart';
import '../../services/reply_service.dart';
import '../../services/translation_service.dart';

class AlbumView extends StatelessWidget {
  final ReplyService replyService;
  final VoidCallback onBgChanged;

  const AlbumView({
    super.key,
    required this.replyService,
    required this.onBgChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lang = replyService.language;
    final backgrounds = replyService.getAllBackgrounds();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      // --- 修正点①：AppBarの「壁紙を外す」ボタン ---
      appBar: AppBar(
        title: Text(
          T.get('album', lang),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        foregroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            onPressed: () => _setAsBackground(context, "default"),
            // ★ アイコンを「画像なし（斜線付き）」に変更
            icon: const Icon(Icons.hide_image_outlined),
            tooltip: T.get('remove_wallpaper', lang),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          // アルバムの紹介文
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Text(
              lang == 'ja'
                  ? "二人で過ごした時間が、景色になっていく。"
                  : "The time we spent together turns into scenery.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.pinkAccent.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // 少し横幅に余裕を持たせる
              ),
              itemCount: backgrounds.length,
              itemBuilder: (context, index) {
                final bg = backgrounds[index];
                final bool isUnlocked =
                    replyService.intimacyScore >= bg['minScore'];
                return GestureDetector(
                  onTap: isUnlocked ? () => _showPreview(context, bg) : null,
                  child: _buildAlbumCard(bg, isUnlocked, lang),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 修正点②：_showPreview 内の画像位置の調整 ---
  void _showPreview(BuildContext context, Map<String, dynamic> bg) {
    final lang = replyService.language;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              bg['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    bg['path'],
                    fit: BoxFit.cover,
                    // ★ alignment を調整して、画像の「上端」から表示するようにします
                    // これにより、キャラの頭が切れるのを防ぎ、少し下げた位置（y=-0.8）を基準にします
                    alignment: const Alignment(0, -0.8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: ElevatedButton(
                onPressed: () {
                  _setAsBackground(context, bg['id']);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  T.get('set_wallpaper', lang),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AlbumView内 _buildAlbumCard を差し替え
  Widget _buildAlbumCard(
    Map<String, dynamic> bg,
    bool isUnlocked,
    String lang,
  ) {
    bool isSelected = replyService.selectedBg == bg['id'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Colors.pinkAccent.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
        border: isSelected
            ? Border.all(color: Colors.pinkAccent, width: 2)
            : null,
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  isUnlocked
                      ? Image.asset(bg['path'], fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              children: [
                Text(
                  isUnlocked ? bg['name'] : "？？？",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  isUnlocked
                      ? (lang == 'ja' ? "タップして拡大" : "Tap to zoom")
                      : (lang == 'ja'
                            ? "親密度 ${bg['minScore']} で解放"
                            : "Unlock at ${bg['minScore']}"),
                  style: TextStyle(
                    fontSize: 9,
                    color: isUnlocked ? Colors.black54 : Colors.pinkAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _setAsBackground(BuildContext context, String bgId) async {
    final lang = replyService.language;
    await replyService.setBackground(bgId);
    onBgChanged();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(T.get('wallpaper_set_msg', lang)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}
