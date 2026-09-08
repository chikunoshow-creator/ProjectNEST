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
    // 1. 基本設定：名前とユーザーへの呼びかけ（くん/ちゃん）
    // 例：「あなたの名前はひな、相手はたかしくんです。」
    String suffixKey = _getUserSuffixKey(profile.userGender);
    String suffix = T.get(suffixKey, lang);
    String prompt = "あなたの名前は$nestName、相手は$userName$suffixです。";

    // 2. ユーザー性別による振る舞いのスパイス (Ver 1.45)
    // 女性ユーザーには「共感」、男性ユーザーには「信頼・応援」のスパイスを加える
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

    // 4. 柱：性格設定 (role_sweet, role_cool, role_tsun)
    String pKey = _getPersonalityKey(profile.personality);
    prompt += " ${T.get(pKey, lang)} ";

    // 5. 柱：関係性設定 (rel_lover, rel_bestFriend 等の詳細な指示)
    // 単なるラベルではなく、振る舞いに関する具体的なプロンプトを取得
    String relPromptKey = _getRelationshipPromptKey(profile.relationship);
    prompt += " ${T.get(relPromptKey, lang)} ";

    // 6. 共通ルール（ガードレールと出力フォーマット）
    prompt += " ${T.get('guardrails', lang)} ${T.get('format_rule', lang)}";

    return prompt;
  }

  // ユーザーの性別に応じた呼びかけの接尾辞キー（くん/ちゃん/さん）を返す
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

  // 関係性Enumから、詳細な振る舞い指示（プロンプト）の辞書キーを取得
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
