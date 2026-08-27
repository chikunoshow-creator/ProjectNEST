import 'dart:convert';
import 'package:http/http.dart' as http;

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
  Future<String> generateDiaryContent({
    required String apiKey,
    required String prompt,
  }) async {
    // ...日記生成ロジック...
    return ""; // 実装略
  }
}
