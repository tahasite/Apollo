import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StepHeader extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;

  const StepHeader({super.key, required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textDim)),
            ],
          ),
        ),
      ],
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;
  final String? hint;
  const FieldLabel({super.key, required this.text, this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(hint!, style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
        ],
      ],
    );
  }
}

class InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionText;
  final VoidCallback? onTap;

  const InfoBanner({super.key, required this.icon, required this.text, this.actionText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accentCyan.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentCyan.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accentCyan),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.accentCyan, fontSize: 13)),
          ),
          if (actionText != null)
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  children: [
                    Text(actionText!, style: const TextStyle(color: AppColors.accentCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.accentCyan),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}