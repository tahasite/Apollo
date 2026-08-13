import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/config_service.dart';
import '../theme/app_colors.dart';
import 'setup_wizard/setup_wizard_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final isSetupComplete = await ConfigService.instance.isSetupComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => isSetupComplete ? const MainScreen() : const SetupWizardScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(colors: [Color(0xFF1A1A2E), Color(0xFF0A0A0F)], radius: 1.2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: AppColors.accentPurple.withOpacity(0.4), blurRadius: 40, spreadRadius: 10)],
                ),
                child: const Icon(Icons.play_arrow_rounded, size: 70, color: Colors.white),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).then().shimmer(duration: 1500.ms, color: Colors.white38),
              const SizedBox(height: 32),
              const Text('Apollo', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 2))
                  .animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 8),
              const Text('video editor · publisher', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, letterSpacing: 3))
                  .animate().fadeIn(delay: 800.ms, duration: 600.ms),
              const SizedBox(height: 60),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(AppColors.accentPurple.withOpacity(0.6))),
              ).animate().fadeIn(delay: 1200.ms),
            ],
          ),
        ),
      ),
    );
  }
}