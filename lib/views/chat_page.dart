import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/app_constants.dart';
import '../models/chat_message.dart';
import '../models/diary_entry.dart';
import '../services/reply_service.dart';
import '../services/translation_service.dart';

import 'nest/nest_view.dart';
import 'talk/talk_view.dart';
import 'mypage/mypage_view.dart';
import 'welcome_view.dart';
import '../widgets/common_splash_screen.dart'; // ★ これを追加
import '../widgets/main_drawer.dart';
import '../widgets/chat_dialogs.dart'; // ★ これを追加

//import 'diary_list_page.dart';
//import 'memories_card_view.dart';
//import 'package:url_launcher/url_launcher.dart';
//import 'album_view.dart'; // ★ これを追加

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
    DateTime startTime = DateTime.now();

    await _replyService.loadHistory();
    await _loadMessages();
    await _speechToText.initialize();

    // ★ 追加：アップデートチェック
    await _checkUpdate(isManual: false);

    await _checkAutoDiary();

    int elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 1500)
      await Future.delayed(Duration(milliseconds: 1500 - elapsed));
    if (mounted) setState(() => _isLoading = false);
  }

  // アップデートをチェックする機能
  Future<void> _checkUpdate({required bool isManual}) async {
    final config = await _replyService.aiService.fetchMaintenanceConfig();
    final String latest = config['latest_version'] ?? _replyService.appVersion;

    if (latest != _replyService.appVersion) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text("Update Available"),
          content: Text("Ver $latest が届いています。最新版に更新するね？"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("あとで"),
            ),
            ElevatedButton(
              onPressed: () async {
                // 1. 全てのService Workerを解除する
                final html.ServiceWorkerContainer swContainer =
                    html.window.navigator.serviceWorker!;
                final registrations = await swContainer.getRegistrations();
                for (var reg in registrations) {
                  await reg.unregister();
                  print("Service Worker Unregistered");
                }

                // 2. ブラウザのキャッシュを無視して強制リロード
                html.window.location.reload();
              },
              child: const Text("更新する"),
            ),
          ],
        ),
      );
    } else if (isManual) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("最新バージョンだよ！ ❤️")));
    }
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
  // class _ChatPageState 内
  Future<void> _checkAutoDiary() async {
    if (_replyService.needsDiaryUpdate &&
        _replyService.getHistory().isNotEmpty) {
      // ReplyService側の generateDiary を呼び出す
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
      return CommonSplashScreen(
        replyService: _replyService,
      ); // ★ 修正後（constを消して引数を渡す）
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
      endDrawer: MainDrawer(
        replyService: _replyService,
        onBgChanged: () => setState(() {}),
        // ChatDialogs を使うように変更
        onShowPrecautions: () => ChatDialogs.showPrecautions(context, lang),
        onShowPwaGuide: () => ChatDialogs.showPwaGuide(context, lang),
        onShowResetDialog: () => ChatDialogs.showTalkResetDialog(
          context,
          lang,
          _replyService,
          () => setState(() => _messages.clear()),
        ),
      ),
      appBar: _buildAppBar(),
      // ...
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
            onCheckUpdate: () => _checkUpdate(isManual: true), // ★この1行を追加
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(lang),
    );
  }

  // --- UIコンポーネント: AppBar / BottomNav / Drawer ---
  PreferredSizeWidget _buildAppBar() {
    final themeColor = _replyService.themeColor; // ★追加
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      elevation: 1,
      title: Text(
        "Project NEST",
        style: TextStyle(color: themeColor, fontWeight: FontWeight.bold), // ★修正
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
      selectedItemColor: _replyService.themeColor, // ★ここを修正
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
}
