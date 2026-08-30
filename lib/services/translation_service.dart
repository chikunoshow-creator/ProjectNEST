import 'translations/ja.dart';
import 'translations/en.dart';

class T {
  static String get(String key, String lang) {
    final Map<String, Map<String, String>> localizedValues = {
      'ja': ja,
      'en': en,
    };

    return localizedValues[lang]?[key] ?? key;
  }
}
