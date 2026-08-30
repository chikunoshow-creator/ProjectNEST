import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_constants.dart';
import '../models/diary_entry.dart';
import 'ai_service.dart';
import 'translation_service.dart'; // ★追加
import 'reply_storage_service.dart'; // ★この1行を追加してください！

class ReplyService {
  final AiService _aiService = AiService();
  final ReplyStorageService _storage = ReplyStorageService(); // ★追加
  AiService get aiService => _aiService;
  final String appVersion = "1.154";

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
  int intimacyScore = 0;
  String selectedBg = "default";
  bool isFirstLaunch = true;
  String startDate = "";

  // 記憶保持用
  List<String> _userMemories = [];

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
  // 親密度ランクの判定
  String get intimacyRank {
    if (intimacyScore >= 1000) return "S";
    if (intimacyScore >= 500) return "A";
    if (intimacyScore >= 200) return "B";
    if (intimacyScore >= 100) return "C";
    if (intimacyScore >= 50) return "D";
    return "E";
  }

  // 累計メッセージ数（現在の履歴ベース）
  int get messageCount => _history.where((m) => m['role'] == 'user').length;
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

  int get daysTogether {
    if (startDate.isEmpty) return 1;
    try {
      final start = DateTime.parse(startDate);
      final now = DateTime.now();
      return now.difference(start).inDays + 1;
    } catch (e) {
      return 1;
    }
  }

  String get charKey => (personality == "ツンデレ")
      ? "sayo"
      : (personality == "クールなお姉さん")
      ? "goki"
      : "hau";

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
    groqApiKey = prefs.getString(AppConstants.groqKey) ?? "";
    intimacyScore = prefs.getInt(AppConstants.intimacyKey) ?? 0;
    selectedBg = prefs.getString(AppConstants.bgKey) ?? "default";
    isFirstLaunch = prefs.getBool(AppConstants.firstLaunchKey) ?? true;
    startDate = prefs.getString(AppConstants.startDateKey) ?? "";

    // ★ メモリーの読み込みを追加
    final String? savedMemories = prefs.getString(AppConstants.userMemoriesKey);
    if (savedMemories != null) {
      _userMemories = List<String>.from(jsonDecode(savedMemories));
    }

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

  // ★ 正しい位置（クラスの直下）に generateDiary を配置
  Future<DiaryEntry> generateDiary() async {
    String historyText = _history
        .map((m) {
          String role = (m['role'] == 'user') ? userName : displayName;
          return "$role: ${m['content']}";
        })
        .join("\n");

    // 記憶抽出
    List<String> newMemories = await _aiService.extractMemories(
      apiKey: groqApiKey,
      personality: personality,
      historyText: historyText,
      language: language,
    );

    _userMemories = newMemories;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.userMemoriesKey,
      jsonEncode(_userMemories),
    );

    // 記憶を注入して日記生成
    String memoryNote = "【あなたが気づいたパートナーのこと】\n${_userMemories.join('、')}\n\n";

    // lib/services/reply_service.dart 内の generateDiary メソッドの一部
    final Map<String, String> diaryData = await _aiService.generateDiaryContent(
      apiKey: groqApiKey,
      personality: personality,
      nestName: nestName, // ★追加
      userName: userName, // ★追加
      historyText: memoryNote + historyText,
      language: language,
    );
    return DiaryEntry(
      date: nestToday,
      title: diaryData['title'] ?? (language == 'en' ? "Today" : "今日の日記"),
      mood: diaryData['mood'] ?? "✨",
      content:
          diaryData['content'] ??
          (language == 'en' ? "Happy day! ❤️" : "幸せな一日だったよ❤️"),
    );
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

  // --- リセット系 ---
  Future<void> clearChatOnly() async {
    _history = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.historyKey);
    await prefs.remove(AppConstants.chatMessagesKey);
  }

  Future<void> resetNest() async {
    final prefs = await SharedPreferences.getInstance();
    _history = [];
    _diaries = [];
    _userMemories = []; // 記憶も消去
    intimacyScore = 0;
    isFirstLaunch = true;
    await prefs.setBool(AppConstants.firstLaunchKey, true);
    await prefs.remove(AppConstants.historyKey);
    await prefs.remove(AppConstants.diariesKey);
    await prefs.remove(AppConstants.intimacyKey);
    await prefs.remove(AppConstants.chatMessagesKey);
    await prefs.remove(AppConstants.userMemoriesKey);
    await loadHistory();
  }

  Future<void> resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await loadHistory();
  }

  // --- 会話系 ---
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
    final prefs = await SharedPreferences.getInstance();

    // 1. 性格Roleの決定 (T.get を使用)
    String pKey = (personality == "甘えん坊")
        ? 'role_sweet'
        : (personality == "クールなお姉さん" ? 'role_cool' : 'role_tsun');
    String personalityRole = T.get(pKey, language);

    // 2. 親密度による態度の決定
    String intimacyInstruction = (intimacyScore < 50)
        ? T.get('intimacy_low', language)
        : (intimacyScore < 200
              ? T.get('intimacy_mid', language)
              : T.get('intimacy_high', language));

    // 3. プロンプト構築
    String systemPrompt =
        "あなたの名前は$nestName、相手は$userNameです。 "
        "$personalityRole $intimacyInstruction ${T.get('guardrails', language)} ${T.get('format_rule', language)}";

    final reply = await _aiService.fetchGroqReply(
      apiKey: groqApiKey,
      systemPrompt: systemPrompt,
      history: _history,
      userMessage: msg,
    );

    // ★ 救出ロジック ＆ 親密度ペナルティ 部分を修正
    if (reply == "NEST_ERROR") {
      intimacyScore = (intimacyScore > 5) ? intimacyScore - 5 : 0;
      await prefs.setInt(AppConstants.intimacyKey, intimacyScore);

      // 性格ごとのエラーメッセージを T.get で取得
      final errorKey = (personality == "甘えん坊")
          ? 'error_sweet'
          : (personality == "クールなお姉さん" ? 'error_cool' : 'error_tsun');
      return T.get(errorKey, language);
    }

    // 正常な場合は親密度 +1
    intimacyScore++;
    await prefs.setInt(AppConstants.intimacyKey, intimacyScore);

    _history.add({"role": "user", "content": msg});
    _history.add({"role": "assistant", "content": reply});
    if (_history.length > 20) _history.removeRange(0, 2);
    await prefs.setString(AppConstants.historyKey, jsonEncode(_history));
    return reply;
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
    required String apiKey,
    String birthday = "",
    String food = "",
    String job = "",
  }) async {
    // 1. メモリ上の変数を更新
    userName = name;
    this.nestName = nestName;
    this.nestAliases = nestAliases;
    personality = p;
    groqApiKey = apiKey;
    userBirthday = birthday;
    userFood = food;
    userJob = job;

    // 2. ストレージサービスに丸投げ
    await _storage.saveAllSettings(exportAllData());
    await _loadPersonalityJson();
  }

  Future<void> completeSetup() async {
    isFirstLaunch = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.firstLaunchKey, false);
    if (startDate.isEmpty) {
      startDate = DateTime.now().toIso8601String();
      await prefs.setString(AppConstants.startDateKey, startDate);
    }
  }

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

  // --- バックアップ・復元 ---
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
      'intimacyScore': intimacyScore,
      'selectedBg': selectedBg,
      'language': language,
      'history': _history,
      'diaries': _diaries.map((e) => e.toJson()).toList(),
      'startDate': startDate,
      'backupVersion': appVersion,
    };
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    userName = data['userName'] ?? userName;
    nestName = data['nestName'] ?? nestName;
    nestAliases = data['nestAliases'] ?? nestAliases;
    userBirthday = data['userBirthday'] ?? "";
    userFood = data['userFood'] ?? "";
    userJob = data['userJob'] ?? "";
    personality = data['personality'] ?? "甘えん坊";
    aiProvider = data['aiProvider'] ?? "Groq";
    groqApiKey = data['groqApiKey'] ?? "";
    intimacyScore = data['intimacyScore'] ?? 0;
    selectedBg = data['selectedBg'] ?? "default";
    language = data['language'] ?? language;
    _history = List<Map<String, String>>.from(
      (data['history'] as List).map((e) => Map<String, String>.from(e)),
    );
    _diaries = (data['diaries'] as List)
        .map((e) => DiaryEntry.fromJson(e))
        .toList();
    startDate = data['startDate'] ?? "";

    await prefs.setString(AppConstants.userKey, userName);
    await prefs.setString(AppConstants.nestNameKey, nestName);
    await prefs.setString(AppConstants.nestAliasesKey, nestAliases);
    await prefs.setString(AppConstants.personalityKey, personality);
    await prefs.setString(AppConstants.groqKey, groqApiKey);
    await prefs.setInt(AppConstants.intimacyKey, intimacyScore);
    await prefs.setString(AppConstants.historyKey, jsonEncode(_history));
    await prefs.setString(
      AppConstants.diariesKey,
      jsonEncode(_diaries.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(AppConstants.languageKey, language);
    await prefs.setString(AppConstants.bgKey, selectedBg);
    await _loadPersonalityJson();
  }

  Future<String?> getBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.backupDateKey);
  }

  Future<void> saveBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    String now = DateTime.now().toString().substring(0, 16);
    await prefs.setString(AppConstants.backupDateKey, now);
  }

  // 内部スロットに保存
  Future<void> saveToInternalSlot() async {
    await _storage.saveToInternalSlot(exportAllData());
  }

  // 内部スロットから復元
  Future<bool> restoreFromInternalSlot() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(AppConstants.backupDataKey);
    if (savedData != null) {
      await importAllData(jsonDecode(savedData));
      return true;
    }
    return false;
  }

  // 性格のフルネーム（ひな / Hina など）を取得
  String get fullPersonalityName => language == 'en'
      ? (personalityNamesEn[personality] ?? "")
      : (personalityNames[personality] ?? "");

  // 性格ごとの詳細説明文（WelcomeViewなどで使用）を取得
  // 修正後：1行で完結
  String getSpecificDescription(String p, String lang) {
    final key = (p == "甘えん坊")
        ? 'desc_sweet'
        : (p == "クールなお姉さん" ? 'desc_cool' : 'desc_tsun');
    return T.get(key, lang);
  }
}
