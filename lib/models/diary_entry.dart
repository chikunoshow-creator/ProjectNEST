class DiaryEntry {
  final DateTime date;
  final String content;

  DiaryEntry({required this.date, required this.content});

  // 保存用
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'content': content,
  };

  // 復元用
  factory DiaryEntry.fromJson(Map<String, dynamic> json) =>
      DiaryEntry(date: DateTime.parse(json['date']), content: json['content']);
}
