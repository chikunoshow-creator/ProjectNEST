import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/translation_service.dart'; // インポートを忘れずに

class AiService {
  final String groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> fetchGroqReply({
    required String apiKey,
    required String systemPrompt,
    required List<Map<String, String>> history,
    required String userMessage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(groqUrl),
        headers: {
          'Authorization': 'Bearer ${apiKey.trim()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "openai/gpt-oss-20b",
          "messages": [
            {"role": "system", "content": systemPrompt},
            ...history,
            {"role": "user", "content": userMessage},
          ],
          "temperature": 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        // ★ エラーコードを出す代わりに、救出ロジック用の合言葉を返す
        print("API Error: ${response.statusCode}");
        return "NEST_ERROR";
      }
    } catch (e) {
      print("Connection Error: $e");
      return "NEST_ERROR"; // ★ 通信エラー時も同様
    }
  }

  // 日記生成用
  // lib/services/ai_service.dart 内の実装
  Future<Map<String, String>> generateDiaryContent({
    required String apiKey,
    required String personality,
    required String historyText,
    required String language,
  }) async {
    // 命令文を T.get で取得
    final String systemPrompt = T
        .get('diary_ai_system_prompt', language)
        .replaceAll('{personality}', personality);
    final String userPrefix = T.get('diary_ai_user_prefix', language);

    // フォールバック用の値も T.get で準備
    final Map<String, String> fallback = {
      "title": T.get('diary_fallback_title', language),
      "mood": T.get('diary_fallback_mood', language),
      "content": T.get('diary_fallback_content', language),
    };

    try {
      final response = await http.post(
        Uri.parse(groqUrl),
        headers: {
          'Authorization': 'Bearer ${apiKey.trim()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "openai/gpt-oss-20b",
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": "$userPrefix$historyText"},
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String rawJson = data['choices'][0]['message']['content'];

        // JSON抽出ロジック（ハルシネーション対策）
        final start = rawJson.indexOf('{');
        final end = rawJson.lastIndexOf('}');
        if (start != -1 && end != -1) {
          rawJson = rawJson.substring(start, end + 1);
          final Map<String, dynamic> diaryMap = jsonDecode(rawJson);

          return {
            "title": diaryMap['title']?.toString() ?? fallback["title"]!,
            "mood": diaryMap['mood']?.toString() ?? fallback["mood"]!,
            "content": diaryMap['content']?.toString() ?? fallback["content"]!,
          };
        }
      }
    } catch (e) {
      print("Diary AI Error: $e");
    }

    // 全てのエラーケースで T.get から取得したフォールバックを返す
    return fallback;
  }

  Future<List<String>> extractMemories({
    required String apiKey,
    required String personality,
    required String historyText,
    required String language,
  }) async {
    final String systemPrompt = T
        .get('memory_extraction_prompt', language)
        .replaceAll('{personality}', personality);

    try {
      final response = await http.post(
        Uri.parse(groqUrl),
        headers: {
          'Authorization': 'Bearer ${apiKey.trim()}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "openai/gpt-oss-20b",
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": historyText},
          ],
          "temperature": 0.3, // 抽出なので低めの温度で正確に
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String rawJson = data['choices'][0]['message']['content'];

        // JSON抽出
        final start = rawJson.indexOf('{');
        final end = rawJson.lastIndexOf('}');
        if (start != -1 && end != -1) {
          rawJson = rawJson.substring(start, end + 1);
          final Map<String, dynamic> result = jsonDecode(rawJson);
          return List<String>.from(result['memories'] ?? []);
        }
      }
    } catch (e) {
      print("Memory Extraction Error: $e");
    }
    return [];
  }
}
