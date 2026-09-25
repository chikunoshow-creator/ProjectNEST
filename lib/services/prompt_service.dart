// lib/services/prompt_service.dart

import 'translation_service.dart';
import '../models/nest_profile.dart';

class PromptService {
  static String buildSystemPrompt({
    required NestProfile profile,
    required String nestName,
    required String userName,
    required int intimacyScore,
    required String lang,
    DateTime? now,
    String? weatherContext, // ★【Ver 1.27 Step 1】追加
  }) {
    // 1. 基本設定：名前とユーザーへの呼びかけ（くん/ちゃん）
    String suffixKey = _getUserSuffixKey(profile.userGender);
    String suffix = T.get(suffixKey, lang);
    String prompt = "あなたの名前は$nestName、相手は$userName$suffixです。";

    // 2. ユーザー性別による振る舞いのスパイス (Ver 1.45)
    if (profile.userGender == Gender.female) {
      prompt += " ${T.get('user_context_female', lang)} ";
    } else if (profile.userGender == Gender.male) {
      prompt += " ${T.get('user_context_male', lang)} ";
    }

    // 3. パートナー（NEST）自身の性別振る舞い
    if (profile.nestGender == Gender.male) {
      prompt += "あなたは男性として振る舞ってください。";
    } else if (profile.nestGender == Gender.female) {
      prompt += "あなたは女性として振る舞ってください。";
    }

    // ★【Ver 1.27】現在日時のコンテキスト注入（自然な時間感覚）
    final DateTime current = now ?? DateTime.now();
    final String formattedTime = _formatTimeContext(current, lang);
    prompt +=
        " ${T.get('time_context', lang).replaceAll('{time}', formattedTime)} ";

    // ★【Ver 1.27 Step 1】天気・環境コンテキスト注入（値がある場合のみ結合）
    if (weatherContext != null && weatherContext.trim().isNotEmpty) {
      prompt += " $weatherContext ";
    }

    // ★【Ver 1.23】NEST共通会話エンジン（11の原則：Base Conversation Style）
    prompt += " ${T.get('core_conversation_style', lang)} ";

    // 4. 柱：性格設定 (role_sweet, role_cool, role_tsun)
    String pKey = _getPersonalityKey(profile.personality);
    prompt += " ${T.get(pKey, lang)} ";

    // 5. 柱：関係性設定 (rel_lover, rel_bestFriend 等の詳細な指示)
    String relPromptKey = _getRelationshipPromptKey(profile.relationship);
    prompt += " ${T.get(relPromptKey, lang)} ";

    // 6. 共通ルール（ガードレールと出力フォーマット）
    prompt += " ${T.get('guardrails', lang)} ${T.get('format_rule', lang)}";

    return prompt;
  }

  // ★【Ver 1.27 Step 1】天気コンテキストの整形ヘルパー（翻訳辞書分離ルールを遵守）
  static String formatWeatherContext({
    required String location,
    required String weather,
    required String lang,
  }) {
    if (location.trim().isEmpty && weather.trim().isEmpty) return "";
    return T
        .get('weather_context', lang)
        .replaceAll(
          '{location}',
          location.isNotEmpty ? location : (lang == 'ja' ? '未設定' : 'Unknown'),
        )
        .replaceAll(
          '{weather}',
          weather.isNotEmpty ? weather : (lang == 'ja' ? '不明' : 'Unknown'),
        );
  }

  // 日時フォーマット用ヘルパー
  static String _formatTimeContext(DateTime dt, String lang) {
    const jaDays = ['月', '火', '水', '木', '金', '土', '日'];
    const enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final int dayIndex = dt.weekday - 1;
    final String dayStr = (lang == 'ja') ? jaDays[dayIndex] : enDays[dayIndex];

    final String y = dt.year.toString().padLeft(4, '0');
    final String m = dt.month.toString().padLeft(2, '0');
    final String d = dt.day.toString().padLeft(2, '0');
    final String hh = dt.hour.toString().padLeft(2, '0');
    final String mm = dt.minute.toString().padLeft(2, '0');
    final String tz = dt.timeZoneName.isNotEmpty ? " ${dt.timeZoneName}" : "";

    return "$y-$m-$d $hh:$mm ($dayStr)$tz";
  }

  static String _getUserSuffixKey(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'user_suffix_male';
      case Gender.female:
        return 'user_suffix_female';
      default:
        return 'user_suffix_none';
    }
  }

  static String _getPersonalityKey(String personality) {
    switch (personality) {
      case "クールなお姉さん":
        return 'role_cool';
      case "ツンデレ":
        return 'role_tsun';
      case "甘えん坊":
      default:
        return 'role_sweet';
    }
  }

  static String _getRelationshipPromptKey(Relationship rel) {
    switch (rel) {
      case Relationship.lover:
        return 'rel_lover';
      case Relationship.bestFriend:
        return 'rel_bestFriend';
      case Relationship.sibling:
        return 'rel_sibling';
      case Relationship.mentor:
        return 'rel_mentor';
    }
  }
}
