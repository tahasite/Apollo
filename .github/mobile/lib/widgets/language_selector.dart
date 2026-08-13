import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LanguageSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const LanguageSelector({super.key, required this.value, required this.onChanged});

  static const List<Map<String, String>> languages = [
    {'code': 'english', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'persian', 'name': 'فارسی', 'flag': '🇮🇷'},
    {'code': 'arabic', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'turkish', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'spanish', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'french', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'german', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'portuguese', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'chinese', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'japanese', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'korean', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'russian', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'hindi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'indonesian', 'name': 'Indonesia', 'flag': '🇮🇩'},
  ];

  @override
  Widget build(BuildContext context) {
    final current = languages.firstWhere(
      (l) => l['code'] == value,
      orElse: () => languages.first,
    );
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgInput,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderDim),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current['flag']!, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(current['name']!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textDim),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: AppColors.borderDim, borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.language_rounded, color: AppColors.accentPurple, size: 20),
                    SizedBox(width: 8),
                    Text('output language', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: languages.length,
                  itemBuilder: (_, i) {
                    final lang = languages[i];
                    final selected = lang['code'] == value;
                    return ListTile(
                      leading: Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                      title: Text(lang['name']!, style: const TextStyle(color: AppColors.textPrimary)),
                      trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen) : null,
                      onTap: () {
                        onChanged(lang['code']!);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}