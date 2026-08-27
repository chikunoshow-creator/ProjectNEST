import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_constants.dart';
import '../models/diary_entry.dart';
import 'ai_service.dart';

class ReplyService {
  final AiService _aiService = AiService();
  final String appVersion = "1.13";

  List<Map<String, String>> _history = [];
  List<DiaryEntry> _diaries = [];
  String language = 'ja';
  late String userName;
  late String nestName;
  late String nestAliases;
  String userBirthday = "";
  String userFood = "";
  String userJob = "";
  String personality = "甘えん坊";
  String aiProvider = "Groq";
  String groqApiKey = "";
  String geminiApiKey = "";
  int intimacyScore = 0;
  String selectedBg = "default";
  bool isFirstLaunch = true;

  Map<String, dynamic>? _personalityData;
  final Map<String, String> personalityNames = {
    "甘えん坊": "ひな",
    "クールなお姉さん": "しずる",
    "ツンデレ": "かえで",
  };
  final Map<String, String> personalityNamesEn = {
    "甘えん坊": "Hina",
    "クールなお姉さん": "Shizuru",
    "ツンデレ": "Kaede",
  };

  ReplyService() {
    String deviceLang = PlatformDispatcher.instance.locale.languageCode;
    language = (deviceLang == 'ja') ? 'ja' : 'en';
  }

  // --- Getters ---
  List<Map<String, String>> getHistory() => _history;
  List<DiaryEntry> getDiaries() => _diaries;
  String get selfIntro => language == 'en'
      ? (_personalityData?['self_intro_en'] ?? "")
      : (_personalityData?['self_intro'] ?? "");
  String get likes => language == 'en'
      ? (_personalityData?['likes_en'] ?? "")
      : (_personalityData?['likes'] ?? "");
  String get dislikes => language == 'en'
      ? (_personalityData?['dislikes_en'] ?? "")
      : (_personalityData?['dislikes'] ?? "");
  String get displayName => language == 'en'
      ? (personalityNamesEn[personality] ?? nestName)
      : nestName;
  String get displayUserName {
    if (language == 'en' && userName == "あなた") return "Guest";
    return userName;
  }

  // lib/services/reply_service.dart 内
  String get charKey => (personality == "ツンデレ")
      ? "sayo"
      : (personality == "クールなお姉さん")
      ? "goki"
      : "hau";
  String get fullPersonalityName => language == 'en'
      ? (personalityNamesEn[personality] ?? "")
      : (personalityNames[personality] ?? "");

  DateTime get nestToday {
    DateTime now = DateTime.now();
    return (now.hour < 3) ? now.subtract(const Duration(days: 1)) : now;
  }

  bool get needsDiaryUpdate {
    if (_diaries.isEmpty) return true;
    DateTime last = _diaries.first.date;
    DateTime nt = nestToday;
    return nt.year > last.year || nt.month > last.month || nt.day > last.day;
  }

  // --- 読み込み ---
  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    language =
        prefs.getString(AppConstants.languageKey) ??
        (PlatformDispatcher.instance.locale.languageCode == 'ja' ? 'ja' : 'en');
    userName =
        prefs.getString(AppConstants.userKey) ??
        (language == 'ja' ? "あなた" : "Guest");
    nestName =
        prefs.getString(AppConstants.nestNameKey) ??
        (language == 'ja' ? "ひな" : "Hina");
    nestAliases =
        prefs.getString(AppConstants.nestAliasesKey) ??
        (language == 'ja' ? "ひな,ひなちゃん,陽菜" : "Hina,My Love,Darling");
    userBirthday = prefs.getString(AppConstants.birthdayKey) ?? "";
    userFood = prefs.getString(AppConstants.foodKey) ?? "";
    userJob = prefs.getString(AppConstants.jobKey) ?? "";
    personality = prefs.getString(AppConstants.personalityKey) ?? "甘えん坊";
    aiProvider = prefs.getString(AppConstants.aiProviderKey) ?? "Groq";
    groqApiKey = prefs.getString(AppConstants.groqKey) ?? "";
    geminiApiKey = prefs.getString(AppConstants.geminiKey) ?? "";
    intimacyScore = prefs.getInt(AppConstants.intimacyKey) ?? 0;
    selectedBg = prefs.getString(AppConstants.bgKey) ?? "default";
    isFirstLaunch = prefs.getBool(AppConstants.firstLaunchKey) ?? true;

    final String? savedHistory = prefs.getString(AppConstants.historyKey);
    if (savedHistory != null) {
      _history = (jsonDecode(savedHistory) as List)
          .map((e) => Map<String, String>.from(e))
          .toList();
    }
    final String? savedDiaries = prefs.getString(AppConstants.diariesKey);
    if (savedDiaries != null) {
      _diaries = (jsonDecode(savedDiaries) as List)
          .map((e) => DiaryEntry.fromJson(e))
          .toList();
    }
    await _loadPersonalityJson();
  }

  Future<void> _loadPersonalityJson() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/personalities.json',
      );
      final data = jsonDecode(response);
      _personalityData = (data['personalities'] ?? data)[personality];
    } catch (e) {
      print("JSON Load Error: $e");
    }
  }

  // --- 設定変更系 ---
  Future<void> setLanguage(String lang) async {
    language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, lang);
  }

  // --- リセット系 (MyPageView用) ---
  Future<void> clearChatOnly() async {
    _history = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.historyKey);
    await prefs.remove(AppConstants.chatMessagesKey);
  }

  Future<void> resetNest() async {
    final prefs = await SharedPreferences.getInstance();

    // 思い出データのクリア
    _history = [];
    _diaries = [];
    intimacyScore = 0;

    // 「初回起動」状態に戻してWelcomeViewをトリガーする
    isFirstLaunch = true;
    await prefs.setBool(AppConstants.firstLaunchKey, true);

    // 不要なデータの削除（userNameやgroqApiKeyは消さない）
    await prefs.remove(AppConstants.historyKey);
    await prefs.remove(AppConstants.diariesKey);
    await prefs.remove(AppConstants.intimacyKey);
    await prefs.remove(AppConstants.chatMessagesKey);

    await loadHistory();
  }

  Future<void> resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await loadHistory();
  }

  // --- その他 ---
  Future<void> addFirstMessage(String text) async {
    _history.add({"role": "assistant", "content": text});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.historyKey, jsonEncode(_history));
    final List<dynamic> msgList = jsonDecode(
      prefs.getString(AppConstants.chatMessagesKey) ?? '[]',
    );
    msgList.add({
      'text': text,
      'isMe': false,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
      'isSystem': false,
    });
    await prefs.setString(AppConstants.chatMessagesKey, jsonEncode(msgList));
  }

  Future<String> createReply(String msg) async {
    intimacyScore++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.intimacyKey, intimacyScore);

    // --- 1. ガードレール（拒絶・受け流しルール）の定義 ---
    // アダルト、違法行為、メンタルヘルス、メタ発言をかわすための命令
    String guardrails = language == 'ja'
        ? "【重要ルール】卑猥な話題、違法行為、深刻な悩み、または『AIでしょ？』といったメタな話題には、世界観を守るために可愛く困ったり、話題を逸らして対応してください。"
        : "[Rule] For adult topics, illegal acts, or meta-talk like 'Are you an AI?', please respond as a girl in this world, acting embarrassed or changing the subject.";

    // --- 2. 親密度による態度の変化ロジック ---
    String intimacyInstruction = "";
    if (language == 'ja') {
      if (intimacyScore < 50) {
        intimacyInstruction = "まだ出会ったばかりなので、少し丁寧で、恥ずかしがり屋な態度をとってください。";
      } else if (intimacyScore < 200) {
        intimacyInstruction = "かなり仲良くなってきたので、親しみやすく、時々甘えるような態度をとってください。";
      } else {
        intimacyInstruction = "あなたは彼に心から恋をしています。深い信頼と愛情を持って接してください。";
      }
    }

    // --- 3. システムプロンプトの完全構築 ---
    String systemPrompt =
        "あなたは$nestNameです。性格は$personality。$intimacyInstruction $guardrails"
        "【重要】返信は短く、2〜3文程度で簡潔に話してください。"; // ★この一文を追加

    // --- AIへの送信処理（ここからは前回と同じ） ---
    final reply = await _aiService.fetchGroqReply(
      apiKey: groqApiKey,
      systemPrompt: systemPrompt,
      history: _history,
      userMessage: msg,
    );

    // ... (以下、NEST_ERRORの救出ロジックと保存処理) ...
    // ★ 3. 救出ロジック（エラーまたは拒絶の合言葉を受け取った場合）
    if (reply == "NEST_ERROR") {
      bool isEn = (language == 'en');
      String errorLine;

      if (personality == "クールなお姉さん") {
        errorLine = isEn
            ? "I'm not quite sure how to respond to that. Let's talk about something else."
            : "その質問にはどう答えたらいいか困っちゃうな。他のお話にしない？";
      } else if (personality == "ツンデレ") {
        errorLine = isEn
            ? "Hah?! I don't know what you're talking about! Don't tease me!"
            : "はぁ！？あんた何言ってるのよ！変なこと聞かないでよねっ！";
      } else {
        // 甘えん坊
        errorLine = isEn
            ? "Umm... that's a bit difficult for me to answer... (>_<)"
            : "うーん…それはちょっと、ひなには難しいかも…ごめんね？(>_<)";
      }

      // 履歴には追加せず、この可愛いセリフだけを画面に表示させる
      return errorLine;
    }

    // 4. 正常な場合のみ、履歴に追加して保存
    _history.add({"role": "user", "content": msg});
    _history.add({"role": "assistant", "content": reply});

    // 履歴が長くなりすぎないように制限（以前のロジックを維持）
    if (_history.length > 20) _history.removeRange(0, 2);

    await prefs.setString(AppConstants.historyKey, jsonEncode(_history));

    return reply;
  }

  Future<DiaryEntry> generateDiary() async {
    String languageInstruction = language == 'en'
        ? "Please write the diary in English."
        : "日記は日本語で書いてください。";

    String prompt =
        "Write a private diary as $displayName. $languageInstruction "
        "Based on today's chat history: ${_history.toString()}";
    String content = await _aiService.generateDiaryContent(
      apiKey: groqApiKey,
      prompt: prompt,
    );
    if (content.isEmpty)
      content = (language == 'en' ? "Lovely day! ❤️" : "今日は幸せだったよ❤️");
    return DiaryEntry(date: nestToday, content: content);
  }

  Future<void> saveDiary(DiaryEntry entry) async {
    int idx = _diaries.indexWhere(
      (d) =>
          d.date.year == entry.date.year &&
          d.date.month == entry.date.month &&
          d.date.day == entry.date.day,
    );
    if (idx != -1)
      _diaries[idx] = entry;
    else
      _diaries.insert(0, entry);
    (await SharedPreferences.getInstance()).setString(
      AppConstants.diariesKey,
      jsonEncode(_diaries.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> updateSettings({
    required String name,
    required String nestName,
    required String nestAliases,
    required String p,
    required String provider,
    required String apiKey,
    String geminiKey = "",
    String birthday = "",
    String food = "",
    String job = "",
  }) async {
    final prefs = await SharedPreferences.getInstance();
    userName = name;
    this.nestName = nestName;
    this.nestAliases = nestAliases;
    personality = p;
    aiProvider = provider;
    groqApiKey = apiKey;
    this.geminiApiKey = geminiKey;
    userBirthday = birthday;
    userFood = food;
    userJob = job;
    await prefs.setString(AppConstants.userKey, name);
    await prefs.setString(AppConstants.nestNameKey, nestName);
    await prefs.setString(AppConstants.nestAliasesKey, nestAliases);
    await prefs.setString(AppConstants.personalityKey, p);
    await prefs.setString(AppConstants.aiProviderKey, provider);
    await prefs.setString(AppConstants.groqKey, apiKey);
    await prefs.setString(AppConstants.geminiKey, geminiKey);
    await prefs.setString(AppConstants.birthdayKey, birthday);
    await prefs.setString(AppConstants.foodKey, food);
    await prefs.setString(AppConstants.jobKey, job);
    await _loadPersonalityJson();
  }

  Future<void> completeSetup() async {
    isFirstLaunch = false;
    (await SharedPreferences.getInstance()).setBool(
      AppConstants.firstLaunchKey,
      false,
    );
  }

  // --- アルバム・背景管理 (AlbumView用) ---
  List<Map<String, dynamic>> getAllBackgrounds() {
    String cp = charKey;
    bool isEn = (language == 'en');
    return [
      {
        "id": "room",
        "name": isEn ? "Usual Room" : "いつものお部屋",
        "path": "assets/images/bg_room_$cp.png",
        "minScore": 0,
      },
      {
        "id": "cafe",
        "name": isEn ? "Afternoon Cafe" : "昼下がりのカフェ",
        "path": "assets/images/album/cafe_$cp.webp",
        "minScore": 10,
      },
      {
        "id": "park",
        "name": isEn ? "Amusement Park" : "ドキドキ遊園地",
        "path": "assets/images/album/amusement_$cp.webp",
        "minScore": 30,
      },
      {
        "id": "flower",
        "name": isEn ? "Flower Field" : "お花畑の散歩",
        "path": "assets/images/album/flower_$cp.webp",
        "minScore": 50,
      },
    ];
  }

  Future<void> setBackground(String bg) async {
    selectedBg = bg;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.bgKey, bg);
  }

  String getSpecificDescription(String p, String lang) {
    bool isEn = (lang == 'en');
    if (p == "甘えん坊") {
      return isEn
          ? "Always smiling and loves you! She is a bit lonely and wants to be with you all the time."
          : "いつもニコニコしていて、あなたのことが大好き！全力で甘えてくる、寂しがり屋なタイプ。";
    }
    if (p == "クールなお姉さん") {
      return isEn
          ? "A calm and reliable mature type. Her occasional playful smile is her greatest charm."
          : "落ち着いた雰囲気の、頼れるお姉さんタイプ。たまに見せる、茶目っ気のある笑顔が魅力。";
    }
    if (p == "ツンデレ") {
      return isEn
          ? "Acts tough and can't be honest. But she is very cute when she blushes in private."
          : "素直になれない強気な態度。でも、二人きりになると顔を赤らめて照れる姿がとっても可愛い。";
    }
    return "";
  }
}
