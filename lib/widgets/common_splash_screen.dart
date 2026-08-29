import 'package:flutter/material.dart';

class CommonSplashScreen extends StatelessWidget {
  const CommonSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.pinkAccent.withValues(alpha: 0.3),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage('assets/images/hau_icon.png'),
                child: Image.asset(
                  'assets/images/hau_icon.png',
                  errorBuilder: (c, e, s) => const Icon(
                    Icons.favorite,
                    size: 60,
                    color: Colors.pinkAccent,
                  ),
                  color: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Project NEST',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 120,
              height: 3,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.circular(10),
                color: Colors.pinkAccent.withValues(alpha: 0.6),
                backgroundColor: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
