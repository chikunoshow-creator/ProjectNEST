import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ★ これを追加（スライド演出に必要）
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
        // アプリ全体の土台の色を「白」に固定
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,

        // フォント設定
        textTheme: GoogleFonts.notoSansJpTextTheme(Theme.of(context).textTheme),

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          surface: Colors.white,
        ),

        // ★ 修正点：const を外して、型を明示することでエラーを解消
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const ChatPage(),
    );
  }
}
