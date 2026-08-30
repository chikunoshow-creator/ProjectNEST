import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart'; // ← これはもう使わないので消してOKです
import 'package:google_fonts/google_fonts.dart';
import 'views/chat_page.dart';

void main() {
  runApp(const ProjectNestApp());
}

// ★ アニメーションをゼロにするための魔法のクラス
class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // アニメーションを介さず、そのまま子供（次の画面）を返す
    return child;
  }
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
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,

        textTheme: GoogleFonts.notoSansJpTextTheme(Theme.of(context).textTheme),

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          surface: Colors.white,
        ),

        // ★ 修正箇所：すべてのプラットフォームで「アニメーションなし」を適用
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: NoTransitionsBuilder(),
            TargetPlatform.iOS: NoTransitionsBuilder(),
            TargetPlatform.windows: NoTransitionsBuilder(),
            TargetPlatform.macOS: NoTransitionsBuilder(),
            TargetPlatform.linux: NoTransitionsBuilder(),
            TargetPlatform.fuchsia: NoTransitionsBuilder(),
          },
        ),
      ),
      home: const ChatPage(),
    );
  }
}
