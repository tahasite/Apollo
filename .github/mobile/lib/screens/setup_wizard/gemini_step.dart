import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import 'step_common.dart';

class GeminiStep extends StatelessWidget {
  final TextEditingController keysCtrl;
  final TextEditingController modelCtrl;

  const GeminiStep({super.key, required this.keysCtrl, required this.modelCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepHeader(
            icon: '🤖',
            title: 'gemini ai',
            subtitle: 'ai engine for captions and hashtags',
            color: AppColors.accentPurple,
          ),
          const SizedBox(height: 20),
          InfoBanner(
            icon: Icons.link_rounded,
            text: 'get free api keys',
            actionText: 'open',
            onTap: () => launchUrl(Uri.parse('https://aistudio.google.com/apikey')),
          ),
          const SizedBox(height: 20),
          const FieldLabel(text: 'api keys', hint: 'one per line for automatic rotation'),
          const SizedBox(height: 8),
          TextField(
            controller: keysCtrl,
            maxLines: 5,
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace', color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'AIzaSyxxxxxxxxxxxxxxxxxxx\nAIzaSyxxxxxxxxxxxxxxxxxxx'),
          ),
          const SizedBox(height: 20),
          const FieldLabel(text: 'model name', hint: 'default: gemini-2.0-flash-lite'),
          const SizedBox(height: 8),
          TextField(
            controller: modelCtrl,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'gemini-2.0-flash-lite'),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('https://ai.google.dev/gemini-api/docs/models')),
            child: const Row(
              children: [
                Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.accentCyan),
                SizedBox(width: 6),
                Text('browse available models', style: TextStyle(color: AppColors.accentCyan, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}