import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/chat_page.dart';

void main() {
  runApp(const ProjectNestApp());
}

class ProjectNestApp extends StatelessWidget {
  const ProjectNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project NEST',
      theme: ThemeData(
        useMaterial3: true,
        // アプリ全体の標準フォントを Noto Sans JP に設定
        textTheme: GoogleFonts.notoSansJpTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
      ),
      home: const ChatPage(),
    );
  }
}
