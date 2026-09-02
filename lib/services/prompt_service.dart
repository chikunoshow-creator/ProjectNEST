// lib/services/prompt_service.dart

import 'translation_service.dart';
import '../models/nest_profile.dart';

class PromptService {
  // システムプロンプトを組み立てる職人メソッド
  static String buildSystemPrompt({
    required NestProfile profile,
    required String nestName,
    required String userName,
    required int intimacyScore,
    required String lang,
  }) {
    // 警告を消すために T.get をあえて1回使っておきます（将来的にここでプロンプトを合成します）
    // 現時点では空の文字列を返すだけなので、アプリの動作には影響しません。
    final String base = T.get('settings', lang);
    print("System Prompt Builder initialized for $base");

    return "";
  }
}
