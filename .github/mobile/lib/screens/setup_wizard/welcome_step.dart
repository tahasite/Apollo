import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.play_arrow_rounded, size: 64, color: Colors.white),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          const Text(
            'welcome to apollo',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 0.5),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          const Text(
            'professional video editor & publisher',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, letterSpacing: 2),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDim),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'features',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                SizedBox(height: 14),
                _Feature(icon: '🎭', text: 'remove watermarks intelligently'),
                _Feature(icon: '💧', text: 'add your custom branding watermark'),
                _Feature(icon: '✨', text: 'ai-powered captions and hashtags'),
                _Feature(icon: '📸', text: 'publish to instagram reels directly'),
                _Feature(icon: '▶️', text: 'upload to youtube shorts'),
                _Feature(icon: '⚡', text: 'enhance quality and upscale'),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accentBlue),
                SizedBox(width: 8),
                Text('this setup takes about 2 minutes', style: TextStyle(color: AppColors.accentBlue, fontSize: 12)),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final String icon;
  final String text;
  const _Feature({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}