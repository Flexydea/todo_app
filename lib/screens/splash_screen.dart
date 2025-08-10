import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _goNext() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final settings = Hive.box('settingsBox');
    final int? currentUserKey = settings.get('currentUser') as int?;

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      (currentUserKey != null) ? '/home' : '/auth',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06750B), // Green background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/splash_animation.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              onLoaded: (comp) {
                Future.delayed(comp.duration, _goNext);
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Todo App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
