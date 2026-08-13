import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsCard extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final Color accentColor;
  final Widget child;
  final Widget? statusBadge;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.accentColor,
    required this.child,
    this.statusBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderDim.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
                      ],
                    ],
                  ),
                ),
                if (statusBadge != null) statusBadge!,
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final bool ok;
  final String? okText;
  final String? notOkText;
  const StatusBadge({super.key, required this.ok, this.okText, this.notOkText});

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.accentGreen : AppColors.accentAmber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            ok ? (okText ?? 'ready') : (notOkText ?? 'setup'),
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}