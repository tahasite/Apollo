import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double height;
  final double? width;
  final bool loading;
  final bool enabled;

  const GradientButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.gradient = AppColors.purpleGradient,
    this.height = 52,
    this.width,
    this.loading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = !enabled || loading;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isDisabled ? null : gradient,
        color: isDisabled ? AppColors.borderDim : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: (gradient.colors.first).withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
                        style: TextStyle(
                          color: isDisabled ? AppColors.textDim : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}