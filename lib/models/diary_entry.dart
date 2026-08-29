class DiaryEntry {
  final DateTime date;
  final String content;
  final String title; // 追加：日記のタイトル
  final String mood; // 追加：その日の気分（絵文字など）

  DiaryEntry({
    required this.date,
    required this.content,
    this.title = "", // デフォルト値
    this.mood = "✨", // デフォルト値
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'content': content,
    'title': title,
    'mood': mood,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    date: DateTime.parse(json['date']),
    content: json['content'],
    // 古いデータにはtitle/moodがないので、?? で回避
    title: json['title'] ?? "",
    mood: json['mood'] ?? "✨",
  );
}
