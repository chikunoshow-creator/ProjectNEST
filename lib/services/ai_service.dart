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

  // メンテナンス＆最新バージョン情報の取得
  Future<Map<String, dynamic>> fetchMaintenanceConfig() async {
    try {
      // キャッシュを避けるためにタイムスタンプを付与して maintenance.json を取得
      final ts = DateTime.now().millisecondsSinceEpoch;
      final response = await http.get(Uri.parse('maintenance.json?v=$ts'));
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print("Update check error: $e");
    }
    return {"enabled": false, "latest_version": "1.151"};
  }

  // 日記生成用
  Future<Map<String, String>> generateDiaryContent({
    required String apiKey,
    required String personality,
    required String nestName, // ★追加：NESTの名前
    required String userName, // ★追加：ユーザーの名前
    required String historyText,
    required String language,
  }) async {
    // 命令文を T.get で取得し、{nestName} と {userName} を実際の名前に置き換える
    final String systemPrompt = T
        .get('diary_ai_system_prompt', language)
        .replaceAll('{personality}', personality)
        .replaceAll('{nestName}', nestName) // ★ここでお前の名前は◯◯だと教える
        .replaceAll('{userName}', userName); // ★相手の名前は◯◯だと教える

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
