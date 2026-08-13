import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../theme/app_colors.dart';

class FinishStep extends StatelessWidget {
  const FinishStep({super.key});

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>().config;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppColors.greenGradient,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(color: AppColors.accentGreen.withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
              ],
            ),
            child: const Icon(Icons.check_rounded, size: 60, color: Colors.white),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          const Text('all set!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 8),
          const Text('here is your configuration status', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 28),
          _statusTile('🤖', 'gemini ai', config.isGeminiConfigured),
          _statusTile('📸', 'instagram', config.isInstagramConfigured),
          _statusTile('☁️', 'cloudinary', config.isCloudinaryConfigured),
          _statusTile('▶️', 'youtube', config.isYoutubeConfigured),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDim),
            ),
            child: const Row(
              children: [
                Icon(Icons.settings_rounded, color: AppColors.textDim, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text('you can update any setting later from the settings tab.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 20),
          const Text('crafted with ❤️ by tahasite', style: TextStyle(color: AppColors.textDim, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _statusTile(String icon, String name, bool ok) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ok ? AppColors.accentGreen.withOpacity(0.3) : AppColors.borderDim),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (ok ? AppColors.accentGreen : AppColors.textDim).withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(ok ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded, size: 14, color: ok ? AppColors.accentGreen : AppColors.textDim),
                  const SizedBox(width: 6),
                  Text(ok ? 'ready' : 'skip', style: TextStyle(color: ok ? AppColors.accentGreen : AppColors.textDim, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms + (name.length * 20).ms).slideX(begin: 0.2, end: 0);
  }
}