// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeSlideCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    // Controller for both fade and slide
    _fadeSlideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Slide up from slightly below
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2), // 20% down the screen
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeSlideCtrl, curve: Curves.easeOut));

    // Fade in
    _fade = CurvedAnimation(parent: _fadeSlideCtrl, curve: Curves.easeOut);

    // Delay a bit so it comes after the Lottie starts
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fadeSlideCtrl.forward();
    });

    // Navigate away after splash time
    Future.delayed(const Duration(seconds: 2, milliseconds: 200), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/auth'); // or conditional '/home'
  }

  @override
  void dispose() {
    _fadeSlideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF06750B);

    return Scaffold(
      backgroundColor: green,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie animation
              Lottie.asset(
                'assets/animations/splash_animation.json',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),

              // Fade + Slide transition for the title
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    children: [
                      const Text(
                        'Todo App',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Opacity(
                        opacity: 0.85,
                        child: Text(
                          'Stay organized, daily.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
