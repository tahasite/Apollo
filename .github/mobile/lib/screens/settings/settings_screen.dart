import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../models/config_model.dart';
import '../../services/config_service.dart';
import '../../services/instagram_service.dart';
import '../../services/ip_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/labeled_input.dart';
import '../../widgets/settings_card.dart';
import '../setup_wizard/setup_wizard_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final geminiKeysCtrl = TextEditingController();
  final geminiModelCtrl = TextEditingController();
  final igTokenCtrl = TextEditingController();
  final igUserIdCtrl = TextEditingController();
  final igSecretCtrl = TextEditingController();
  final cloudNameCtrl = TextEditingController();
  final cloudKeyCtrl = TextEditingController();
  final cloudSecretCtrl = TextEditingController();
  final ytClientIdCtrl = TextEditingController();
  final ytClientSecretCtrl = TextEditingController();

  IpInfo? _ipInfo;
  bool _loadingIp = false;
  bool _testingIg = false;
  String? _igTestResult;
  bool? _igTestOk;
  String? _ytJsonFileName;

  @override
  void initState() {
    super.initState();
    _loadFromConfig();
    _loadIp();
  }

  @override
  void dispose() {
    geminiKeysCtrl.dispose();
    geminiModelCtrl.dispose();
    igTokenCtrl.dispose();
    igUserIdCtrl.dispose();
    igSecretCtrl.dispose();
    cloudNameCtrl.dispose();
    cloudKeyCtrl.dispose();
    cloudSecretCtrl.dispose();
    ytClientIdCtrl.dispose();
    ytClientSecretCtrl.dispose();
    super.dispose();
  }

  void _loadFromConfig() {
    final config = context.read<ConfigProvider>().config;
    geminiKeysCtrl.text = config.geminiApiKeys.join('\n');
    geminiModelCtrl.text = config.geminiModel;
    igTokenCtrl.text = config.instagramAccessToken;
    igUserIdCtrl.text = config.instagramUserId;
    igSecretCtrl.text = config.instagramAppSecret;
    cloudNameCtrl.text = config.cloudinaryCloudName;
    cloudKeyCtrl.text = config.cloudinaryApiKey;
    cloudSecretCtrl.text = config.cloudinaryApiSecret;
    ytClientIdCtrl.text = config.youtubeClientId;
    ytClientSecretCtrl.text = config.youtubeClientSecret;
  }

  Future<void> _loadIp() async {
    setState(() => _loadingIp = true);
    final info = await IpService.getInfo();
    if (!mounted) return;
    setState(() {
      _ipInfo = info;
      _loadingIp = false;
    });
  }

  Future<void> _saveAll() async {
    final provider = context.read<ConfigProvider>();
    final c = provider.config;
    c.geminiApiKeys = ConfigModel.normalizeApiKeys(geminiKeysCtrl.text);
    c.geminiModel = geminiModelCtrl.text.trim().isEmpty ? 'gemini-2.0-flash-lite' : geminiModelCtrl.text.trim();
    c.instagramAccessToken = igTokenCtrl.text.trim();
    c.instagramUserId = igUserIdCtrl.text.trim();
    c.instagramAppSecret = igSecretCtrl.text.trim();
    c.cloudinaryCloudName = cloudNameCtrl.text.trim();
    c.cloudinaryApiKey = cloudKeyCtrl.text.trim();
    c.cloudinaryApiSecret = cloudSecretCtrl.text.trim();
    c.youtubeClientId = ytClientIdCtrl.text.trim();
    c.youtubeClientSecret = ytClientSecretCtrl.text.trim();
    await provider.save();
    if (!mounted) return;
    _snack('all settings saved successfully', AppColors.accentGreen);
  }

  Future<void> _resetSettings() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.accentAmber),
            SizedBox(width: 10),
            Text('reset all?', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: const Text(
          'this will clear all your api keys and settings. this action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('cancel', style: TextStyle(color: AppColors.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('reset', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final provider = context.read<ConfigProvider>();
    await provider.update(ConfigModel());
    _loadFromConfig();
    setState(() {});
    _snack('all settings reset', AppColors.accentAmber);
  }

  Future<void> _pickYoutubeJson() async {
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
        _snack('could not read file', AppColors.accentRed);
        return;
      }
      final parsed = await ConfigService.instance.parseYoutubeJson(content);
      if (parsed == null) {
        _snack('invalid google oauth json', AppColors.accentRed);
        return;
      }
      ytClientIdCtrl.text = parsed['client_id'] ?? '';
      ytClientSecretCtrl.text = parsed['client_secret'] ?? '';
      setState(() => _ytJsonFileName = file.name);
      _snack('youtube credentials loaded', AppColors.accentGreen);
    } catch (e) {
      _snack('error: $e', AppColors.accentRed);
    }
  }

  Future<void> _testInstagram() async {
    if (igTokenCtrl.text.trim().isEmpty || igUserIdCtrl.text.trim().isEmpty || igSecretCtrl.text.trim().isEmpty) {
      setState(() {
        _igTestResult = 'fill all fields first';
        _igTestOk = false;
      });
      return;
    }
    setState(() {
      _testingIg = true;
      _igTestResult = null;
    });
    try {
      final ig = InstagramService(
        accessToken: igTokenCtrl.text.trim(),
        userId: igUserIdCtrl.text.trim(),
        appSecret: igSecretCtrl.text.trim(),
      );
      final data = await ig.verifyToken();
      final username = data['username']?.toString() ?? 'unknown';
      setState(() {
        _igTestOk = true;
        _igTestResult = 'connected as @$username';
      });
    } catch (e) {
      setState(() {
        _igTestOk = false;
        _igTestResult = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _testingIg = false);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == AppColors.accentGreen
                  ? Icons.check_circle_rounded
                  : color == AppColors.accentRed
                      ? Icons.error_rounded
                      : Icons.info_rounded,
              color: color, size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(color: AppColors.textPrimary))),
          ],
        ),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.3))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ConfigProvider>().config;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildNetworkCard(),
                    _buildGeminiCard(config),
                    _buildInstagramCard(config),
                    _buildCloudinaryCard(config),
                    _buildYoutubeCard(config),
                    _buildActionsBar(),
                    _buildFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.settings_rounded, color: AppColors.accentBlue, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text('manage all your api configurations', style: TextStyle(fontSize: 11, color: AppColors.textDim)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkCard() {
    return SettingsCard(
      icon: '🌐',
      title: 'network info',
      subtitle: 'ip used for all api connections',
      accentColor: AppColors.accentCyan,
      child: _loadingIp
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentCyan)),
            )
          : Column(
              children: [
                _ipRow(Icons.public_rounded, 'ip', _ipInfo?.ip ?? 'unknown', extra: _ipInfo?.flag),
                const SizedBox(height: 10),
                _ipRow(Icons.location_on_rounded, 'location',
                    '${_ipInfo?.city ?? ""}${_ipInfo?.city.isNotEmpty == true ? ", " : ""}${_ipInfo?.country ?? "unknown"}'),
                const SizedBox(height: 10),
                _ipRow(Icons.business_rounded, 'isp', _ipInfo?.isp ?? 'unknown'),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _loadIp,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('refresh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentCyan,
                      side: const BorderSide(color: AppColors.borderDim),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _ipRow(IconData icon, String label, String value, {String? extra}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textDim),
          const SizedBox(width: 8),
          Text('$label:', style: const TextStyle(color: AppColors.textDim, fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                if (extra != null) ...[Text(extra, style: const TextStyle(fontSize: 16)), const SizedBox(width: 6)],
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeminiCard(ConfigModel config) {
    return SettingsCard(
      icon: '🤖',
      title: 'gemini ai',
      subtitle: 'captions & hashtags engine',
      accentColor: AppColors.accentPurple,
      statusBadge: StatusBadge(ok: config.isGeminiConfigured),
      child: Column(
        children: [
          LabeledInput(
            label: 'api keys (one per line)',
            hint: 'AIzaSy...',
            controller: geminiKeysCtrl,
            maxLines: 4,
            monospace: true,
          ),
          const SizedBox(height: 12),
          LabeledInput(
            label: 'model name',
            hint: 'gemini-2.0-flash-lite',
            controller: geminiModelCtrl,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _linkButton(Icons.key_rounded, 'get keys', 'https://aistudio.google.com/apikey')),
              const SizedBox(width: 8),
              Expanded(child: _linkButton(Icons.library_books_rounded, 'models', 'https://ai.google.dev/gemini-api/docs/models')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstagramCard(ConfigModel config) {
    return SettingsCard(
      icon: '📸',
      title: 'instagram',
      subtitle: 'reel publishing api',
      accentColor: AppColors.accentPink,
      statusBadge: StatusBadge(ok: config.isInstagramConfigured),
      child: Column(
        children: [
          LabeledInput(label: 'access token', hint: 'IGAA...', controller: igTokenCtrl, maxLines: 3, monospace: true),
          const SizedBox(height: 12),
          LabeledInput(label: 'business account id', hint: '17841...', controller: igUserIdCtrl),
          const SizedBox(height: 12),
          LabeledInput(label: 'app secret', controller: igSecretCtrl, obscure: true),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _testingIg ? null : _testInstagram,
              icon: _testingIg
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.wifi_tethering_rounded, size: 16),
              label: Text(_testingIg ? 'testing...' : 'test connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
          if (_igTestResult != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (_igTestOk == true ? AppColors.accentGreen : AppColors.accentRed).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: (_igTestOk == true ? AppColors.accentGreen : AppColors.accentRed).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _igTestOk == true ? Icons.check_circle_rounded : Icons.error_rounded,
                    color: _igTestOk == true ? AppColors.accentGreen : AppColors.accentRed,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _igTestResult!,
                      style: TextStyle(
                        color: _igTestOk == true ? AppColors.accentGreen : AppColors.accentRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCloudinaryCard(ConfigModel config) {
    return SettingsCard(
      icon: '☁️',
      title: 'cloudinary',
      subtitle: 'temporary video hosting',
      accentColor: AppColors.accentCyan,
      statusBadge: StatusBadge(ok: config.isCloudinaryConfigured),
      child: Column(
        children: [
          LabeledInput(label: 'cloud name', controller: cloudNameCtrl),
          const SizedBox(height: 12),
          LabeledInput(label: 'api key', controller: cloudKeyCtrl),
          const SizedBox(height: 12),
          LabeledInput(label: 'api secret', controller: cloudSecretCtrl, obscure: true),
          const SizedBox(height: 10),
          _linkButton(Icons.open_in_new_rounded, 'get free account', 'https://cloudinary.com/'),
        ],
      ),
    );
  }

  Widget _buildYoutubeCard(ConfigModel config) {
    final hasData = ytClientIdCtrl.text.isNotEmpty && ytClientSecretCtrl.text.isNotEmpty;
    return SettingsCard(
      icon: '▶️',
      title: 'youtube',
      subtitle: 'upload to shorts',
      accentColor: AppColors.accentRed,
      statusBadge: StatusBadge(ok: config.isYoutubeConfigured),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasData ? AppColors.accentGreen.withOpacity(0.3) : AppColors.borderDim,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  hasData ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                  size: 32,
                  color: hasData ? AppColors.accentGreen : AppColors.textDim,
                ),
                const SizedBox(height: 6),
                Text(
                  hasData ? 'credentials loaded' : 'no json loaded',
                  style: TextStyle(
                    color: hasData ? AppColors.accentGreen : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_ytJsonFileName != null) ...[
                  const SizedBox(height: 3),
                  Text(_ytJsonFileName!, style: const TextStyle(color: AppColors.textDim, fontSize: 10)),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _pickYoutubeJson,
                    icon: Icon(hasData ? Icons.refresh_rounded : Icons.folder_open_rounded, size: 16),
                    label: Text(hasData ? 'change json' : 'upload json'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            iconColor: AppColors.textDim,
            collapsedIconColor: AppColors.textDim,
            title: const Text(
              'or enter manually',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            children: [
              const SizedBox(height: 8),
              LabeledInput(label: 'client id', controller: ytClientIdCtrl, monospace: true),
              const SizedBox(height: 12),
              LabeledInput(label: 'client secret', controller: ytClientSecretCtrl, obscure: true, monospace: true),
              const SizedBox(height: 10),
            ],
          ),
          _linkButton(Icons.open_in_new_rounded, 'google cloud console', 'https://console.cloud.google.com/'),
        ],
      ),
    );
  }

  Widget _linkButton(IconData icon, String label, String url) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderDim),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.accentCyan),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: Column(
        children: [
          GradientButton(
            text: 'save all settings',
            icon: Icons.save_rounded,
            onPressed: _saveAll,
            gradient: AppColors.greenGradient,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SetupWizardScreen()));
                  },
                  icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.accentPurple),
                  label: const Text('setup wizard', style: TextStyle(color: AppColors.accentPurple, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accentPurple.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetSettings,
                  icon: const Icon(Icons.restart_alt_rounded, size: 16, color: AppColors.accentRed),
                  label: const Text('reset', style: TextStyle(color: AppColors.accentRed, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accentRed.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('crafted with ', style: TextStyle(color: AppColors.textDim, fontSize: 11)),
          const Icon(Icons.favorite_rounded, size: 12, color: AppColors.accentPink),
          const Text(' by ', style: TextStyle(color: AppColors.textDim, fontSize: 11)),
          Text(
            'tahasite',
            style: TextStyle(color: AppColors.accentPurple, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}