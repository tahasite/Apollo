import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/config_service.dart';
import '../../theme/app_colors.dart';
import 'step_common.dart';

class YoutubeStep extends StatefulWidget {
  final TextEditingController clientIdCtrl;
  final TextEditingController clientSecretCtrl;

  const YoutubeStep({super.key, required this.clientIdCtrl, required this.clientSecretCtrl});

  @override
  State<YoutubeStep> createState() => _YoutubeStepState();
}

class _YoutubeStepState extends State<YoutubeStep> {
  bool _hideSecret = true;
  bool _manualMode = false;
  String? _pickedFileName;
  String? _pickError;

  Future<void> _pickJson() async {
    setState(() => _pickError = null);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      String content;
      if (file.bytes != null) {
        content = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        setState(() => _pickError = 'could not read file');
        return;
      }
      final parsed = await ConfigService.instance.parseYoutubeJson(content);
      if (parsed == null) {
        setState(() => _pickError = 'invalid google oauth json file');
        return;
      }
      widget.clientIdCtrl.text = parsed['client_id'] ?? '';
      widget.clientSecretCtrl.text = parsed['client_secret'] ?? '';
      setState(() {
        _pickedFileName = file.name;
        _pickError = null;
      });
    } catch (e) {
      setState(() => _pickError = 'error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepHeader(
            icon: '▶️',
            title: 'youtube',
            subtitle: 'upload to youtube shorts',
            color: AppColors.accentRed,
          ),
          const SizedBox(height: 20),
          InfoBanner(
            icon: Icons.link_rounded,
            text: 'google cloud console',
            actionText: 'open',
            onTap: () => launchUrl(Uri.parse('https://console.cloud.google.com/')),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(child: _modeTab('upload json', 0, !_manualMode)),
                Expanded(child: _modeTab('manual entry', 1, _manualMode)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!_manualMode) _buildJsonMode() else _buildManualMode(),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDim),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accentAmber),
                    SizedBox(width: 8),
                    Text('quick steps:', style: TextStyle(color: AppColors.accentAmber, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  '1. create project in google cloud\n2. enable youtube data api v3\n3. create oauth client (desktop app)\n4. add your email as test user\n5. download the json file and upload it here',
                  style: TextStyle(color: AppColors.textDim, fontSize: 12, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeTab(String label, int index, bool selected) {
    return GestureDetector(
      onTap: () => setState(() => _manualMode = index == 1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.purpleGradient : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJsonMode() {
    final hasData = widget.clientIdCtrl.text.isNotEmpty && widget.clientSecretCtrl.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(
          text: 'client secret json file',
          hint: 'download from google cloud console',
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasData ? AppColors.accentGreen.withOpacity(0.4) : AppColors.borderDim,
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            children: [
              Icon(
                hasData ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                size: 42,
                color: hasData ? AppColors.accentGreen : AppColors.textDim,
              ),
              const SizedBox(height: 10),
              Text(
                hasData ? 'file loaded' : 'no file selected',
                style: TextStyle(
                  color: hasData ? AppColors.accentGreen : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_pickedFileName != null) ...[
                const SizedBox(height: 4),
                Text(
                  _pickedFileName!,
                  style: const TextStyle(color: AppColors.textDim, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (hasData) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.clientIdCtrl.text.length > 40
                        ? '${widget.clientIdCtrl.text.substring(0, 40)}...'
                        : widget.clientIdCtrl.text,
                    style: const TextStyle(
                      color: AppColors.textDim,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pickJson,
                  icon: Icon(hasData ? Icons.refresh_rounded : Icons.folder_open_rounded, size: 18),
                  label: Text(hasData ? 'change file' : 'browse json file'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              if (_pickError != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _pickError!,
                    style: const TextStyle(color: AppColors.accentRed, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManualMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel(text: 'client id', hint: 'from oauth 2.0 credentials'),
        const SizedBox(height: 8),
        TextField(
          controller: widget.clientIdCtrl,
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'xxxxx.apps.googleusercontent.com'),
        ),
        const SizedBox(height: 16),
        const FieldLabel(text: 'client secret'),
        const SizedBox(height: 8),
        TextField(
          controller: widget.clientSecretCtrl,
          obscureText: _hideSecret,
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'GOCSPX-xxxxxxxxxxxxx',
            suffixIcon: IconButton(
              icon: Icon(
                _hideSecret ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: AppColors.textDim,
                size: 20,
              ),
              onPressed: () => setState(() => _hideSecret = !_hideSecret),
            ),
          ),
        ),
      ],
    );
  }
}