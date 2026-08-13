import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LabeledInput extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final int maxLines;
  final bool obscure;
  final bool monospace;
  final ValueChanged<String>? onChanged;

  const LabeledInput({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.maxLines = 1,
    this.obscure = false,
    this.monospace = false,
    this.onChanged,
  });

  @override
  State<LabeledInput> createState() => _LabeledInputState();
}

class _LabeledInputState extends State<LabeledInput> {
  late bool _hide;

  @override
  void initState() {
    super.initState();
    _hide = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          obscureText: _hide,
          onChanged: widget.onChanged,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontFamily: widget.monospace ? 'monospace' : null,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(_hide ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AppColors.textDim, size: 18),
                    onPressed: () => setState(() => _hide = !_hide),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}