import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.85, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => user != null ? const HomeScreen() : const LoginScreen(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: Text('R',
                      style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                          fontSize: 40,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('REUNI',
                    style: AppTextStyles.h1.copyWith(
                        color: AppColors.white, letterSpacing: 1.2)),
                const SizedBox(height: AppSpacing.xs),
                Text('Second Hand, New Stories',
                    style: AppTextStyles.body.copyWith(color: AppColors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
