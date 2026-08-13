import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import 'step_common.dart';

class CloudinaryStep extends StatefulWidget {
  final TextEditingController nameCtrl;
  final TextEditingController keyCtrl;
  final TextEditingController secretCtrl;

  const CloudinaryStep({super.key, required this.nameCtrl, required this.keyCtrl, required this.secretCtrl});

  @override
  State<CloudinaryStep> createState() => _CloudinaryStepState();
}

class _CloudinaryStepState extends State<CloudinaryStep> {
  bool _hideSecret = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepHeader(
            icon: '☁️',
            title: 'cloudinary',
            subtitle: 'temporary video hosting',
            color: AppColors.accentCyan,
          ),
          const SizedBox(height: 20),
          InfoBanner(
            icon: Icons.link_rounded,
            text: 'sign up for free (25gb)',
            actionText: 'open',
            onTap: () => launchUrl(Uri.parse('https://cloudinary.com/')),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.textDim),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'used to host videos temporarily for instagram publishing. auto-deleted after upload.',
                    style: TextStyle(color: AppColors.textDim, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const FieldLabel(text: 'cloud name'),
          const SizedBox(height: 8),
          TextField(
            controller: widget.nameCtrl,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'your cloud name'),
          ),
          const SizedBox(height: 16),
          const FieldLabel(text: 'api key'),
          const SizedBox(height: 8),
          TextField(
            controller: widget.keyCtrl,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'your api key'),
          ),
          const SizedBox(height: 16),
          const FieldLabel(text: 'api secret'),
          const SizedBox(height: 8),
          TextField(
            controller: widget.secretCtrl,
            obscureText: _hideSecret,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'your api secret',
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