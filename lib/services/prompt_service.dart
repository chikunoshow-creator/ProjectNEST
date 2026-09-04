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
  }) {
    String prompt = "あなたの名前は$nestName、相手は$userNameです。";

    // 柱1 & 2: 性別設定 (male, female, other に対応)
    if (profile.nestGender == Gender.male) {
      prompt += "あなたは男性として振る舞ってください。";
    } else if (profile.nestGender == Gender.female) {
      prompt += "あなたは女性として振る舞ってください。";
    }

    if (profile.userGender == Gender.male) {
      prompt += "相手は男性です。";
    } else if (profile.userGender == Gender.female) {
      prompt += "相手は女性です。";
    } else if (profile.userGender == Gender.other) {
      prompt += "相手の性別は中性的、あるいは非公開です。";
    }

    // 柱3: 性格設定 (ReplyServiceの判定ロジックと同期)
    String pKey = _getPersonalityKey(profile.personality);
    prompt += " ${T.get(pKey, lang)} ";

    // 柱4: 関係性設定
    String relLabel = _getRelationshipLabel(profile.relationship);
    prompt += " 二人の関係性は「$relLabel」です。その距離感を大切にして会話してください。";

    // 共通ルール（ガードレールと出力フォーマット）
    prompt += " ${T.get('guardrails', lang)} ${T.get('format_rule', lang)}";

    return prompt;
  }

  // 性格名から翻訳用のキーを特定
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

  // 関係性Enumから日本語のラベルを取得
  static String _getRelationshipLabel(Relationship rel) {
    switch (rel) {
      case Relationship.lover:
        return "恋人";
      case Relationship.bestFriend:
        return "親友";
      case Relationship.sibling:
        return "家族のような存在";
      case Relationship.mentor:
        return "導き手と教え子";
    }
    // ここで default は不要（全ケース網羅済みのため警告が出なくなります）
  }
}
