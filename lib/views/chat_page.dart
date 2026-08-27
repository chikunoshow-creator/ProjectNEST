import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_constants.dart';
import '../models/chat_message.dart';
import '../models/diary_entry.dart';
import '../services/reply_service.dart';
import '../services/translation_service.dart';

import 'album_view.dart'; // ★ これを追加
import 'nest/nest_view.dart';
import 'talk/talk_view.dart';
import 'mypage/mypage_view.dart';
import 'welcome_view.dart';
import 'diary_list_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ReplyService _replyService = ReplyService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _chatController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();

  int _currentTab = 1;
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  bool _isGeneratingDiary = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. 開始時間を記録
    DateTime startTime = DateTime.now();

    await _replyService.loadHistory();
    await _loadMessages();
    await _speechToText.initialize();
    await _checkAutoDiary();

    // 2. 最低でも 1.5秒はロゴを見せる
    int elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 1500) {
      await Future.delayed(Duration(milliseconds: 1500 - elapsed));
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // --- メッセージ・データの管理 ---
  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(AppConstants.chatMessagesKey);
    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);
      setState(() {
        _messages.clear();
        _messages.addAll(decoded.map((m) => ChatMessage.fromJson(m)).toList());
      });
      _scrollToBottom();
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.chatMessagesKey,
      jsonEncode(_messages.map((m) => m.toJson()).toList()),
    );
  }

  // --- ロジック: 日記生成 ---
  Future<void> _checkAutoDiary() async {
    if (_replyService.needsDiaryUpdate &&
        _replyService.getHistory().isNotEmpty) {
      DiaryEntry entry = await _replyService.generateDiary();
      await _replyService.saveDiary(entry);
      _addSystemMessage(
        T
            .get('diary_updated_msg', _replyService.language)
            .replaceAll('{name}', _replyService.displayName),
      );
    }
  }

  void _addSystemMessage(String text) {
    if (!mounted) return;
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isMe: false,
          timestamp: DateTime.now(),
          isSystem: true,
        ),
      );
      if (_currentTab != 1) {
        _unreadCount++;
      }
    });
    _saveMessages();
  }

  // --- ロジック: 送信処理 ---
  Future<void> _handleSend() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isTyping) return;

    // 1. ユーザーのメッセージを追加（この時はまだ既読ではない）
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isMe: true,
          timestamp: DateTime.now(),
          isRead: false,
        ),
      );
      _chatController.clear();
      // ここではまだ _isTyping = true にしないのが「間」のコツです
    });
    _scrollToBottom();
    _saveMessages();

    try {
      // 2. 「既読」がつくまでのタメを作る（例：2秒待機）
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          // 一番新しい自分のメッセージを既読にする
          if (_messages.isNotEmpty && _messages.last.isMe) {
            _messages.last.isRead = true;
          }
          // 3. 既読がついた直後に「入力中...」を開始
          _isTyping = true;
        });
        _scrollToBottom();
      }

      // 4. AIの返信を生成
      final reply = await _replyService.createReply(text);

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(text: reply, isMe: false, timestamp: DateTime.now()),
          );
        });
        _scrollToBottom();
        _saveMessages();
      }
    } catch (e) {
      if (mounted) setState(() => _isTyping = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildSplashScreen();
    }

    if (_replyService.isFirstLaunch) {
      return WelcomeView(
        replyService: _replyService,
        onComplete: () async {
          // ★ async に変更
          setState(() {
            _isLoading = true; // 一旦ローディング表示にする
          });

          // ★ 100ミリ秒だけ待つ（これでブラウザのフリーズを防ぎます）
          await Future.delayed(const Duration(milliseconds: 100));

          await _initApp(); // その後、初期化を実行

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      );
    }

    final lang = _replyService.language;
    final charKey = _replyService.charKey; // 'hau', 'goki', 'sayo' が入る

    // ★ ここを修正：キャラクターごとの背景画像を読み込む
    Widget commonBg = Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        "assets/images/bg_room_$charKey.png", // 例: assets/images/bg_room_hau.png
        fit: BoxFit.cover,
        // 画像が読み込めない時のためのフォールバック（予備）
        errorBuilder: (context, error, stackTrace) {
          return Container(color: const Color(0xFFFFF0F5));
        },
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      endDrawer: _buildDrawer(lang),
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentTab,
        children: [
          NestView(
            replyService: _replyService,
            isGeneratingDiary: _isGeneratingDiary,
            onCreateDiary: () async {
              setState(() => _isGeneratingDiary = true);
              final entry = await _replyService.generateDiary();
              await _replyService.saveDiary(entry);
              setState(() => _isGeneratingDiary = false);
              // ここで日記表示ダイアログ等の呼び出し
            },
            background: commonBg,
          ),
          TalkView(
            messages: _messages,
            replyService: _replyService,
            scrollController: _scrollController,
            chatController: _chatController,
            isTyping: _isTyping,
            speechToText: _speechToText,
            onSend: _handleSend,
            onMicStart: () {}, // 音声認識ロジックは別途分離可能
            onMicEnd: () {},
            onDeleteMessage: (i) => setState(() {
              _messages.removeAt(i);
              _saveMessages();
            }),
            background: commonBg,
          ),
          MyPageView(
            replyService: _replyService,
            onResetAll: () => setState(() {
              _messages.clear();
              // 一瞬だけローディングを挟むことで、WelcomeViewを安全に呼び出す
              _isLoading = true;
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) setState(() => _isLoading = false);
              });
            }),
            onSettingsUpdated: () => setState(() {}),
            onShowAlbum: () {},
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(lang),
    );
  }

  // --- UIコンポーネント: AppBar / BottomNav / Drawer ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      elevation: 1,
      title: const Text(
        "Project NEST",
        style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
      ),
      actions: [
        Center(child: Text("❤️ ${_replyService.intimacyScore} ")),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(String lang) {
    return BottomNavigationBar(
      currentIndex: _currentTab,
      onTap: (i) => setState(() {
        _currentTab = i;
        if (i == 1) _unreadCount = 0;
      }),
      selectedItemColor: Colors.pinkAccent,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: T.get('tab_nest', lang),
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text(_unreadCount.toString()),
            isLabelVisible: _unreadCount > 0,
            child: const Icon(Icons.chat_bubble),
          ),
          label: T.get('tab_talk', lang),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: T.get('tab_mypage', lang),
        ),
      ],
    );
  }

  Widget _buildDrawer(String lang) {
    final charKey = _replyService.charKey;

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
            // ヘッダー部分は以前と同様
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
                        .replaceAll('{name}', _replyService.displayName),
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
                              replyService: _replyService,
                              onBgChanged: () => setState(() {}),
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
                              diaries: _replyService.getDiaries(),
                              replyService: _replyService,
                            ),
                          ),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Colors.pinkAccent, thickness: 0.1),
                    ),

                    // ★ ご利用時の注意事項
                    _buildDrawerItem(
                      Icons.info_outline_rounded,
                      lang == 'ja' ? "ご利用時の注意事項" : "Precautions",
                      Colors.blueGrey,
                      () {
                        Navigator.pop(context);
                        _showPrecautions(lang);
                      },
                    ),

                    _buildDrawerItem(
                      Icons.install_mobile_rounded,
                      lang == 'ja' ? "アプリとしてインストール" : "Install App",
                      Colors.blueAccent,
                      () => _showPwaGuide(lang),
                    ),
                    _buildDrawerItem(
                      Icons.feedback_rounded,
                      lang == 'ja' ? "ご意見・バグ報告" : "Feedback",
                      Colors.tealAccent,
                      () async {
                        Navigator.pop(context);
                        // ★ GoogleフォームのURL（ご自身のURLに書き換えてください）
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

            // 下部のリセットセクション
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showTalkResetDialog();
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
                  // ★ 補足説明の追加
                  Text(
                    lang == 'ja'
                        ? "会話履歴のみ消去します。"
                        : "Conversation history only.",
                    style: const TextStyle(color: Colors.black26, fontSize: 10),
                  ),
                ],
              ),
            ),

            // クレジット表記
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 12),
              child: Column(
                children: [
                  const Divider(indent: 50, endIndent: 50, thickness: 0.5),
                  const SizedBox(height: 12),
                  Text(
                    "Project NEST Ver ${_replyService.appVersion}",
                    style: const TextStyle(
                      color: Colors.black26,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // ★ 配色を pinkAccent に変更
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

  void _showPrecautions(String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          lang == 'ja' ? "ご利用時の注意事項" : "Usage Precautions",
          style: const TextStyle(
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrecautionSection(
                  lang == 'ja' ? "【データの保存について】" : "[Data Storage]",
                  lang == 'ja'
                      ? "会話履歴や設定はブラウザのローカルストレージにのみ保存されます。ブラウザのキャッシュを削除するとデータも消えるので注意してね。"
                      : "Data is stored only in your browser. Clearing cache will delete your data.",
                ),
                _buildPrecautionSection(
                  lang == 'ja' ? "【APIキーの管理について】" : "[API Key Management]",
                  lang == 'ja'
                      ? "APIキーはあなたのブラウザ内でのみ使用され、外部サーバーに送信されることはありません。自己責任での管理をお願いします。"
                      : "Your API key is used only within the browser. Please manage it at your own risk.",
                ),
                _buildPrecautionSection(
                  lang == 'ja' ? "【免責事項】" : "[Disclaimers]",
                  lang == 'ja'
                      ? "AIの回答は必ずしも正確ではありません。NESTとの会話によって生じた不利益について、開発者は一切の責任を負いかねます。"
                      : "AI responses may not be accurate. The developer is not responsible for any issues arising from use.",
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang == 'ja' ? "了解" : "OK"), // ★ ここを修正
          ),
        ],
      ),
    );
  }

  Widget _buildPrecautionSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.pinkAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  // Drawer用の共通パーツ
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

  void _showPwaGuide(String lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          lang == 'ja' ? "アプリとしてインストール" : "Install App",
          style: const TextStyle(
            color: Colors.pinkAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepRow(
              "iPhone (Safari)",
              lang == 'ja'
                  ? "共有ボタンから「ホーム画面に追加」をタップしてね！"
                  : "Tap 'Share' and then 'Add to Home Screen'",
            ),
            const SizedBox(height: 12),
            _buildStepRow(
              "Android (Chrome)",
              lang == 'ja'
                  ? "メニューから「アプリをインストール」をタップしてね！"
                  : "Tap 'Menu' and then 'Install App'",
            ),
            const SizedBox(height: 20),
            Text(
              lang == 'ja'
                  ? "※ホーム画面からいつでもNESTに会えるようになります ❤️"
                  : "Meet NEST anytime from your home screen! ❤️",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
  // lib/views/chat_page.dart のクラス内に追加

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- 枠付きの丸いアイコン ---
            Container(
              padding: const EdgeInsets.all(4), // 枠と画像の間の隙間（これが枠線になります）
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pinkAccent.withValues(alpha: 0.3), // 枠の色
              ),
              child: CircleAvatar(
                radius: 60, // アイコンのサイズ
                backgroundColor: Colors.white, // 画像がない時の背景
                // backgroundImage で画像を指定
                backgroundImage: const AssetImage('assets/images/hau_icon.png'),
                // 画像が読み込めない、あるいはパスが間違っている時に表示される子要素
                child: Image.asset(
                  'assets/images/hau_icon.png',
                  errorBuilder: (context, error, stackTrace) {
                    // ここに画像が読み込めなかった時のアイコンを置く
                    return const Icon(
                      Icons.favorite,
                      size: 60,
                      color: Colors.pinkAccent,
                    );
                  },
                  // 画像がある場合は透明にして、backgroundImage を見せる
                  color: Colors.transparent,
                ),
              ),
            ),

            // ---------------------------
            const SizedBox(height: 32),
            const Text(
              'Project NEST',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 120,
              height: 3,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(10),
                color: Colors.pinkAccent.withValues(alpha: 0.6),
                backgroundColor: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String os, String msg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          os,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(msg, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }

  void _showTalkResetDialog() {
    final lang = _replyService.language;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(T.get('reset_talk', lang)),
        // ★ 警告メッセージを詳細化
        content: Text(
          lang == 'ja'
              ? "今まで積み上げてきた思い出（会話履歴）を消去するよ。\n\n⚠️ この操作は二度と戻せないけど、本当にいい？"
              : "Are you sure you want to delete your conversation history?\n\n⚠️ This operation cannot be undone.",
          style: const TextStyle(height: 1.5),
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
            onPressed: () async {
              await _replyService.clearChatOnly();
              if (!mounted) return;
              setState(() => _messages.clear());
              Navigator.pop(context);
              // 完了通知
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    lang == 'ja' ? "思い出をリセットしました。" : "History has been reset.",
                  ),
                ),
              );
            },
            child: Text(
              T.get('reset_btn', lang),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
