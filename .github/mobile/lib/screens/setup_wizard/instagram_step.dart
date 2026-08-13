import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'step_common.dart';

class InstagramStep extends StatefulWidget {
  final TextEditingController tokenCtrl;
  final TextEditingController userIdCtrl;
  final TextEditingController secretCtrl;

  const InstagramStep({super.key, required this.tokenCtrl, required this.userIdCtrl, required this.secretCtrl});

  @override
  State<InstagramStep> createState() => _InstagramStepState();
}

class _InstagramStepState extends State<InstagramStep> {
  bool _hideSecret = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepHeader(
            icon: '📸',
            title: 'instagram',
            subtitle: 'publish reels automatically',
            color: AppColors.accentPink,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accentAmber.withOpacity(0.25)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accentAmber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'optional. you can skip and configure later.',
                    style: TextStyle(color: AppColors.accentAmber, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const FieldLabel(text: 'access token'),
          const SizedBox(height: 8),
          TextField(
            controller: widget.tokenCtrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'IGAAxxxxxxxxxxxxxxxxxxxxxxxxxxx'),
          ),
          const SizedBox(height: 16),
          const FieldLabel(text: 'business account id'),
          const SizedBox(height: 8),
          TextField(
            controller: widget.userIdCtrl,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: '17841xxxxxxxxxxxx'),
          ),
          const SizedBox(height: 16),
          const FieldLabel(text: 'app secret'),
          const SizedBox(height: 8),
          TextField(
            controller: widget.secretCtrl,
            obscureText: _hideSecret,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'your app secret',
              suffixIcon: IconButton(
                icon: Icon(_hideSecret ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AppColors.textDim, size: 20),
                onPressed: () => setState(() => _hideSecret = !_hideSecret),
              ),
            ),
          ),
        ],
      ),
    );
  }
}