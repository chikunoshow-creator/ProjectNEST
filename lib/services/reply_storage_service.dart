import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_constants.dart';

class ReplyStorageService {
  // 全データを SharedPreferences に一括保存する
  Future<void> saveAllSettings(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // 文字列データ
    if (data.containsKey('userName'))
      await prefs.setString(AppConstants.userKey, data['userName']);
    if (data.containsKey('nestName'))
      await prefs.setString(AppConstants.nestNameKey, data['nestName']);
    if (data.containsKey('nestAliases'))
      await prefs.setString(AppConstants.nestAliasesKey, data['nestAliases']);
    if (data.containsKey('personality'))
      await prefs.setString(AppConstants.personalityKey, data['personality']);
    if (data.containsKey('groqApiKey'))
      await prefs.setString(AppConstants.groqKey, data['groqApiKey']);
    if (data.containsKey('language'))
      await prefs.setString(AppConstants.languageKey, data['language']);
    if (data.containsKey('selectedBg'))
      await prefs.setString(AppConstants.bgKey, data['selectedBg']);
    if (data.containsKey('startDate'))
      await prefs.setString(AppConstants.startDateKey, data['startDate']);

    // 数値・フラグ
    if (data.containsKey('intimacyScore'))
      await prefs.setInt(AppConstants.intimacyKey, data['intimacyScore']);
    if (data.containsKey('isFirstLaunch'))
      await prefs.setBool(AppConstants.firstLaunchKey, data['isFirstLaunch']);

    // プロフィール詳細
    if (data.containsKey('userBirthday'))
      await prefs.setString(AppConstants.birthdayKey, data['userBirthday']);
    if (data.containsKey('userFood'))
      await prefs.setString(AppConstants.foodKey, data['userFood']);
    if (data.containsKey('userJob'))
      await prefs.setString(AppConstants.jobKey, data['userJob']);

    // 履歴・日記（JSON化して保存）
    if (data.containsKey('history'))
      await prefs.setString(
        AppConstants.historyKey,
        jsonEncode(data['history']),
      );
    if (data.containsKey('diaries'))
      await prefs.setString(
        AppConstants.diariesKey,
        jsonEncode(data['diaries']),
      );
    if (data.containsKey('memories'))
      await prefs.setString(
        AppConstants.userMemoriesKey,
        jsonEncode(data['memories']),
      );
  }

  // 内部バックアップスロットへの保存
  Future<void> saveToInternalSlot(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.backupDataKey, jsonEncode(data));
    String now = DateTime.now().toString().substring(0, 16);
    await prefs.setString(AppConstants.backupDateKey, now);
  }

  // 全データの削除（初期化用）
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
