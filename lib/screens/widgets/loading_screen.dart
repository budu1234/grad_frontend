import 'package:flutter/material.dart';
import 'dart:async';
import 'package:schedule_planner/screens/welcome_page.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _fadeMaskController;
  late Animation<double> _revealAnimation;
  late Animation<double> _fadeMaskAnimation;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _fadeMaskController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _revealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.easeInOut),
    );
    _fadeMaskAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeMaskController, curve: Curves.easeInOut),
    );

    _revealController.forward();

    _revealAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _fadeMaskController.forward();
      }
    });

    // Navigate to WelcomePage after both animations
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => WelcomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _fadeMaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_revealAnimation, _fadeMaskAnimation]),
          builder: (context, child) {
            final reveal = _revealAnimation.value.clamp(0.0, 1.0);
            final opacity = _fadeMaskAnimation.value;
            if (opacity == 0.0) {
              // Show the full image after the mask is gone
              return Image.asset(
                'assets/img/kairos_logo.png',
                width: 300,
                height: 300,
              );
            }
            // Show the animated ShaderMask
            return Opacity(
              opacity: opacity,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      0.0,
                      reveal,
                      1.0,
                    ],
                    colors: [
                      Colors.transparent,
                      Colors.white,
                      Colors.white,
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstOut,
                child: Image.asset(
                  'assets/img/kairos_logo.png',
                  width: 300,
                  height: 300,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}