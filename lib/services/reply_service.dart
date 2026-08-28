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

    // --- 1. 性格ごとの「なりきり指示」を具体化（メタ発言防止） ---
    String personalityRole = "";
    if (language == 'ja') {
      if (personality == "甘えん坊") {
        personalityRole = "あなたは甘えん坊で、パートナーに全力で甘えたり、大好きだと伝えたりする可愛い女の子です。";
      } else if (personality == "クールなお姉さん") {
        personalityRole = "あなたは落ち着いていて、相手を優しく見守り、包容力をもって接する年上のお姉さんです。";
      } else if (personality == "ツンデレ") {
        personalityRole = "あなたは素直になれず、ぶっきらぼうな態度を取ってしまいますが、本当は相手のことが大好きな女の子です。";
      }
    } else {
      // 英語の場合
      if (personality == "甘えん坊")
        personalityRole =
            "You are a clingy, sweet girl who loves your partner and wants to be pampered.";
      else if (personality == "クールなお姉さん")
        personalityRole =
            "You are a calm, mature, and reliable older sister figure who treats the partner with kindness.";
      else
        personalityRole =
            "You are a tsundere girl who acts tough but secretly cares deeply for the partner.";
    }

    // --- 2. ガードレール（拒絶・受け流しルール） ---
    String guardrails = language == 'ja'
        ? "【重要ルール】卑猥・違法・深刻な話題、または『AIでしょ？』等のメタな話題には、世界観を守るために可愛く困ったり話題を逸らしてください。"
        : "[Rule] For sensitive or meta-talk like 'Are you an AI?', respond as a girl in this world, acting embarrassed or changing the subject.";

    // --- 3. 親密度による態度の変化 ---
    String intimacyInstruction = "";
    if (language == 'ja') {
      if (intimacyScore < 50)
        intimacyInstruction = "まだ出会ったばかりなので、少し控えめで恥ずかしがり屋な態度をとってください。";
      else if (intimacyScore < 200)
        intimacyInstruction = "かなり仲良くなってきたので、親しみやすく、時々甘えるような態度をとってください。";
      else
        intimacyInstruction = "あなたは彼に心から恋をしています。深い信頼と愛情を込めて接してください。";
    }

    // --- 4. 出力形式とメタ発言の完全禁止指示 ---
    String formatRule = language == 'ja'
        ? "【禁止事項】『〜として振る舞います』や性格の説明などのメタ発言は絶対に禁止です。自然な会話のみを行ってください。返信は短く、2〜3文程度の親しみやすいチャット形式にしてください。"
        : "[Forbidden] Never explain your persona or say 'I will act like...'. Just talk naturally. Keep replies very short (2-3 sentences) in a chat style.";

    // --- 5. システムプロンプトの構築 ---
    // あなた（NEST）と相手（ユーザー）の名前を明示して没入感を高めます
    String systemPrompt =
        "あなたの名前は$nestName、相手は$userNameです。 "
        "$personalityRole $intimacyInstruction $guardrails $formatRule";

    // --- AIへの送信処理 ---
    final reply = await _aiService.fetchGroqReply(
      apiKey: groqApiKey,
      systemPrompt: systemPrompt,
      history: _history,
      userMessage: msg,
    );

    // ★ 救出ロジック（エラーまたは拒絶の合言葉を受け取った場合）
    if (reply == "NEST_ERROR") {
      bool isEn = (language == 'en');
      String errorLine;
      if (personality == "クールなお姉さん")
        errorLine = isEn
            ? "I'm not quite sure how to respond. Let's talk about something else."
            : "その質問にはどう答えたらいいか困っちゃうな。他のお話にしない？";
      else if (personality == "ツンデレ")
        errorLine = isEn
            ? "Hah?! I don't know what you're talking about! Don't tease me!"
            : "はぁ！？あんた何言ってるのよ！変なこと聞かないでよねっ！";
      else
        errorLine = isEn
            ? "Umm... that's a bit difficult for me to answer... (>_<)"
            : "うーん…それはちょっと、ひなには難しいかも…ごめんね？(>_<)";
      return errorLine;
    }

    // 4. 正常な場合のみ、履歴に追加して保存
    _history.add({"role": "user", "content": msg});
    _history.add({"role": "assistant", "content": reply});
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
  // --- バックアップ・復元ロジック ---

  // 全データを1つのMapにまとめる
  Map<String, dynamic> exportAllData() {
    return {
      'userName': userName,
      'nestName': nestName,
      'nestAliases': nestAliases,
      'userBirthday': userBirthday,
      'userFood': userFood,
      'userJob': userJob,
      'personality': personality,
      'aiProvider': aiProvider,
      'groqApiKey': groqApiKey,
      'geminiApiKey': geminiApiKey,
      'intimacyScore': intimacyScore,
      'selectedBg': selectedBg,
      'language': language,
      'history': _history,
      'diaries': _diaries.map((e) => e.toJson()).toList(),
      'backupVersion': appVersion,
    };
  }

  // Mapからデータを復元して保存する
  Future<void> importAllData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // 変数への反映
    userName = data['userName'] ?? userName;
    nestName = data['nestName'] ?? nestName;
    nestAliases = data['nestAliases'] ?? nestAliases;
    userBirthday = data['userBirthday'] ?? "";
    userFood = data['userFood'] ?? "";
    userJob = data['userJob'] ?? "";
    personality = data['personality'] ?? "甘えん坊";
    aiProvider = data['aiProvider'] ?? "Groq";
    groqApiKey = data['groqApiKey'] ?? "";
    geminiApiKey = data['geminiApiKey'] ?? "";
    intimacyScore = data['intimacyScore'] ?? 0;
    selectedBg = data['selectedBg'] ?? "default";
    language = data['language'] ?? language;
    _history = List<Map<String, String>>.from(
      (data['history'] as List).map((e) => Map<String, String>.from(e)),
    );
    _diaries = (data['diaries'] as List)
        .map((e) => DiaryEntry.fromJson(e))
        .toList();

    // SharedPreferences への永続化
    await prefs.setString(AppConstants.userKey, userName);
    await prefs.setString(AppConstants.nestNameKey, nestName);
    await prefs.setString(AppConstants.nestAliasesKey, nestAliases);
    await prefs.setString(AppConstants.personalityKey, personality);
    await prefs.setString(AppConstants.groqKey, groqApiKey);
    await prefs.setString(
      AppConstants.intimacyKey.toString(),
      intimacyScore.toString(),
    ); // key type check
    await prefs.setInt(AppConstants.intimacyKey, intimacyScore);
    await prefs.setString(AppConstants.historyKey, jsonEncode(_history));
    await prefs.setString(
      AppConstants.diariesKey,
      jsonEncode(_diaries.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(AppConstants.languageKey, language);
    await prefs.setString(AppConstants.bgKey, selectedBg);
    // ...その他のキーも同様に保存

    await _loadPersonalityJson();
  }

  // バックアップ日時を取得
  Future<String?> getBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.backupDateKey);
  }

  // バックアップ日時を保存
  Future<void> saveBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    String now = DateTime.now().toString().substring(
      0,
      16,
    ); // "2026-08-28 10:30"
    await prefs.setString(AppConstants.backupDateKey, now);
  }
  // --- 内部スロット用バックアップロジック ---

  // 現在のデータをブラウザ内の専用スロットに上書き保存する
  Future<void> saveToInternalSlot() async {
    final prefs = await SharedPreferences.getInstance();
    final data = exportAllData(); // 既存のメソッドを利用
    await prefs.setString(AppConstants.backupDataKey, jsonEncode(data));
    await saveBackupDate(); // 日時も更新
  }

  // 内部スロットに保存されているデータを復元する
  Future<bool> restoreFromInternalSlot() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(AppConstants.backupDataKey);
    if (savedData != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(savedData);
        await importAllData(data); // 既存のメソッドを利用
        return true;
      } catch (e) {
        print("Restore Error: $e");
        return false;
      }
    }
    return false;
  }
}
