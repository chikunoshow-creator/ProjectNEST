import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_constants.dart';
import '../models/diary_entry.dart';
import 'ai_service.dart';
import 'translation_service.dart';
import 'reply_storage_service.dart';
import 'package:flutter/material.dart';
import '../models/nest_profile.dart';
import 'prompt_service.dart';

class ReplyService {
  final AiService _aiService = AiService();
  final ReplyStorageService _storage = ReplyStorageService();
  AiService get aiService => _aiService;
  final String appVersion = "1.158";

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
  String selectedTheme = "pink";

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

  NestProfile partnerProfile = NestProfile();

  ReplyService() {
    String deviceLang = PlatformDispatcher.instance.locale.languageCode;
    language = (deviceLang == 'ja') ? 'ja' : 'en';
  }

  // --- 性格・性別ID管理システム ---

  // 性格に応じた英語IDを取得
  String get charId {
    if (personality == "ツンデレ") return "tsundere";
    if (personality == "クールなお姉さん") return "cool";
    return "clingy";
  }

  // 性別に応じた接尾辞（f または m）を取得
  String get genderKey =>
      (partnerProfile.nestGender == Gender.male) ? "m" : "f";

  // 【最重要】最終的なアセット検索キー (例: clingy_f)
  String get charKey => "${charId}_$genderKey";

  // --- 基本ゲッター ---

  String get intimacyRank {
    if (intimacyScore >= 1000) return "S";
    if (intimacyScore >= 500) return "A";
    if (intimacyScore >= 200) return "B";
    if (intimacyScore >= 100) return "C";
    if (intimacyScore >= 50) return "D";
    return "E";
  }

  int get messageCount => _history.where((m) => m['role'] == 'user').length;
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

  // --- データ読み書き ---

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
    selectedTheme = prefs.getString(AppConstants.themeKey) ?? "pink";
    await _loadPersonalityJson();
  }

  Color get themeColor =>
      (selectedTheme == "blue") ? Colors.blueAccent : Colors.pinkAccent;
  Color get themeSubColor => themeColor.withValues(alpha: 0.05);
  Color get scaffoldBg => themeColor.withValues(alpha: 0.05);
  Color get itemBg => themeColor.withValues(alpha: 0.1);

  Future<DiaryEntry> generateDiary() async {
    String historyText = _history
        .map((m) {
          String role = (m['role'] == 'user') ? userName : displayName;
          return "$role: ${m['content']}";
        })
        .join("\n");

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

    String memoryNote = "【あなたが気づいたパートナーのこと】\n${_userMemories.join('、')}\n\n";

    final Map<String, String> diaryData = await _aiService.generateDiaryContent(
      apiKey: groqApiKey,
      personality: personality,
      nestName: nestName,
      userName: userName,
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

  Future<void> setTheme(String themeName) async {
    selectedTheme = themeName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, themeName);
  }

  Future<void> _loadPersonalityJson() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/personalities.json',
      );
      final data = jsonDecode(response);
      _personalityData = (data['personalities'] ?? data)[personality];
    } catch (e) {
      debugPrint("JSON Load Error: $e");
    }
  }

  // --- 設定変更・リセット ---

  Future<void> setLanguage(String lang) async {
    language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, lang);
  }

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
    _userMemories = [];
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

  // --- 会話ロジック ---

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

    String memoryBlock = "";
    if (_userMemories.isNotEmpty) {
      memoryBlock = T
          .get('memory_context', language)
          .replaceAll('{memories}', _userMemories.join('、'));
    }

    String basePrompt = PromptService.buildSystemPrompt(
      profile: partnerProfile,
      nestName: nestName,
      userName: userName,
      intimacyScore: intimacyScore,
      lang: language,
    );

    String systemPrompt = basePrompt;
    if (memoryBlock.isNotEmpty) {
      systemPrompt = basePrompt.replaceFirst(
        T.get('guardrails', language),
        "$memoryBlock ${T.get('guardrails', language)}",
      );
    }

    final reply = await _aiService.fetchGroqReply(
      apiKey: groqApiKey,
      systemPrompt: systemPrompt,
      history: _history,
      userMessage: msg,
    );

    if (reply == "NEST_ERROR") {
      intimacyScore = (intimacyScore > 5) ? intimacyScore - 5 : 0;
      await prefs.setInt(AppConstants.intimacyKey, intimacyScore);
      final errorKey = (personality == "甘えん坊")
          ? 'error_sweet'
          : (personality == "クールなお姉さん" ? 'error_cool' : 'error_tsun');
      return T.get(errorKey, language);
    }

    intimacyScore++;
    await prefs.setInt(AppConstants.intimacyKey, intimacyScore);

    _history.add({"role": "user", "content": msg});
    _history.add({"role": "assistant", "content": reply});
    if (_history.length > 20) _history.removeRange(0, 2);
    await prefs.setString(AppConstants.historyKey, jsonEncode(_history));
    return reply;
  }

  // --- アルバム・背景 ---

  List<Map<String, dynamic>> getAllBackgrounds() {
    String cp = charKey; // 例: clingy_f
    // bool isEn = (language == 'en'); // ★ これは不要になります

    return [
      {
        "id": "room",
        "name": T.get('bg_room', language),
        "path": "assets/images/bg_room_$cp.webp",
        "minScore": 0,
      },
      {
        "id": "cafe",
        "name": T.get('bg_cafe', language),
        "path": "assets/images/album/cafe_$cp.webp",
        "minScore": 10,
      },
      {
        "id": "park",
        "name": T.get('bg_park', language),
        "path": "assets/images/album/amusement_$cp.webp",
        "minScore": 30,
      },
      {
        "id": "flower",
        "name": T.get('bg_flower', language),
        "path": "assets/images/album/flower_$cp.webp",
        "minScore": 50,
      },
    ];
  }
  // --- その他設定 ---

  Future<void> saveDiary(DiaryEntry entry) async {
    int idx = _diaries.indexWhere(
      (d) =>
          d.date.year == entry.date.year &&
          d.date.month == entry.date.month &&
          d.date.day == entry.date.day,
    );
    if (idx != -1) {
      _diaries[idx] = entry;
    } else {
      _diaries.insert(0, entry);
    }
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
    userName = name;
    this.nestName = nestName;
    this.nestAliases = nestAliases;
    personality = p;
    groqApiKey = apiKey;
    userBirthday = birthday;
    userFood = food;
    userJob = job;
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

  Future<void> saveToInternalSlot() async =>
      await _storage.saveToInternalSlot(exportAllData());
  Future<bool> restoreFromInternalSlot() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(AppConstants.backupDataKey);
    if (savedData != null) {
      await importAllData(jsonDecode(savedData));
      return true;
    }
    return false;
  }

  String get fullPersonalityName => language == 'en'
      ? (personalityNamesEn[personality] ?? "")
      : (personalityNames[personality] ?? "");

  String getSpecificDescription(String p, String lang) {
    final key = (p == "甘えん坊")
        ? 'desc_sweet'
        : (p == "クールなお姉さん" ? 'desc_cool' : 'desc_tsun');
    return T.get(key, lang);
  }
}
