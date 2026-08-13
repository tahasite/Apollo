import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ToolCard extends StatefulWidget {
  final String icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback? onTap;
  final bool enabled;
  final bool completed;

  const ToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.onTap,
    this.enabled = true,
    this.completed = false,
  });

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.enabled ? widget.color : AppColors.textDim;
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.completed ? effectiveColor.withOpacity(0.4) : AppColors.borderDim,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 46,
              decoration: BoxDecoration(
                gradient: widget.enabled
                    ? LinearGradient(
                        colors: [effectiveColor, effectiveColor.withOpacity(0.5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: widget.enabled ? null : AppColors.borderDim,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(widget.icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: widget.enabled ? AppColors.textPrimary : AppColors.textDim,
                        ),
                      ),
                      if (widget.completed) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.check_circle_rounded, size: 14, color: effectiveColor),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 11, color: AppColors.textDim),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: widget.enabled
                    ? LinearGradient(colors: [effectiveColor, effectiveColor.withOpacity(0.7)])
                    : null,
                color: widget.enabled ? null : AppColors.borderDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}