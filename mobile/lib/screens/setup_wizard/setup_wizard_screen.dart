import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/config_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/step_indicator.dart';
import '../main_screen.dart';
import 'welcome_step.dart';
import 'gemini_step.dart';
import 'instagram_step.dart';
import 'cloudinary_step.dart';
import 'youtube_step.dart';
import 'finish_step.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

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

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  void _loadExisting() {
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

  @override
  void dispose() {
    _pageController.dispose();
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

  void _saveCurrentStepData() {
    final provider = context.read<ConfigProvider>();
    final config = provider.config;
    if (_currentStep == 1) {
      config.geminiApiKeys = geminiKeysCtrl.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final m = geminiModelCtrl.text.trim();
      config.geminiModel = m.isEmpty ? 'gemini-2.0-flash-lite' : m;
    } else if (_currentStep == 2) {
      config.instagramAccessToken = igTokenCtrl.text.trim();
      config.instagramUserId = igUserIdCtrl.text.trim();
      config.instagramAppSecret = igSecretCtrl.text.trim();
    } else if (_currentStep == 3) {
      config.cloudinaryCloudName = cloudNameCtrl.text.trim();
      config.cloudinaryApiKey = cloudKeyCtrl.text.trim();
      config.cloudinaryApiSecret = cloudSecretCtrl.text.trim();
    } else if (_currentStep == 4) {
      config.youtubeClientId = ytClientIdCtrl.text.trim();
      config.youtubeClientSecret = ytClientSecretCtrl.text.trim();
    }
    provider.save();
  }

  void _goNext() {
    _saveCurrentStepData();
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  void _goBack() {
    _saveCurrentStepData();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic);
    }
  }

  Future<void> _finish() async {
    _saveCurrentStepData();
    await ConfigService.instance.markSetupComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF0A0A0F)],
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'step ${_currentStep + 1} of $_totalSteps',
                      style: const TextStyle(color: AppColors.textDim, fontSize: 12, letterSpacing: 1),
                    ),
                    const Spacer(),
                    if (_currentStep > 0 && _currentStep < _totalSteps - 1)
                      TextButton(
                        onPressed: _finish,
                        style: TextButton.styleFrom(foregroundColor: AppColors.textDim),
                        child: const Text('skip setup', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: StepIndicator(currentStep: _currentStep, totalSteps: _totalSteps),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const WelcomeStep(),
                    GeminiStep(keysCtrl: geminiKeysCtrl, modelCtrl: geminiModelCtrl),
                    InstagramStep(tokenCtrl: igTokenCtrl, userIdCtrl: igUserIdCtrl, secretCtrl: igSecretCtrl),
                    CloudinaryStep(nameCtrl: cloudNameCtrl, keyCtrl: cloudKeyCtrl, secretCtrl: cloudSecretCtrl),
                    YoutubeStep(clientIdCtrl: ytClientIdCtrl, clientSecretCtrl: ytClientSecretCtrl),
                    const FinishStep(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: _goBack,
                            icon: const Icon(Icons.arrow_back_rounded, size: 20),
                            label: const Text('back'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.borderDim),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GradientButton(
                        text: _currentStep == _totalSteps - 1 ? 'finish setup' : 'next',
                        icon: _currentStep == _totalSteps - 1 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                        onPressed: _goNext,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}