import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _guides = const [
    _Guide(
      icon: '🤖', title: 'gemini ai',
      subtitle: 'ai captions & hashtags',
      color: AppColors.accentPurple,
      link: 'https://aistudio.google.com/apikey',
      linkLabel: 'get free api key',
      steps: [
        _Step('1', 'open google ai studio', 'go to aistudio.google.com/apikey'),
        _Step('2', 'sign in', 'use your google account'),
        _Step('3', 'create api key', 'tap create api key button'),
        _Step('4', 'copy the key', 'starts with AIzaSy...'),
        _Step('5', 'paste in settings', 'gemini section > api keys'),
      ],
      tips: [
        'add 2-3 keys for automatic rotation on rate limits',
        'default model: gemini-2.0-flash-lite (fast & cheap)',
        'you can change model in settings',
      ],
    ),
    _Guide(
      icon: '📸', title: 'instagram',
      subtitle: 'publish reels to instagram',
      color: AppColors.accentPink,
      link: 'https://developers.facebook.com/',
      linkLabel: 'meta for developers',
      steps: [
        _Step('1', 'business/creator account', 'personal accounts do not support api'),
        _Step('2', 'connect to facebook page', 'link your ig to a fb page'),
        _Step('3', 'create meta app', 'developers.facebook.com > my apps > create app'),
        _Step('4', 'add instagram api', 'use cases > content management'),
        _Step('5', 'permissions', 'instagram_business_basic + content_publish'),
        _Step('6', 'add tester', 'roles > instagram testers > your username'),
        _Step('7', 'accept invite', 'instagram > settings > apps & websites'),
        _Step('8', 'generate token', 'instagram api setup > generate access tokens'),
        _Step('9', 'copy 3 values', 'access token, business account id, app secret'),
      ],
      tips: [
        'development mode is fine for personal use',
        'tokens may expire, regenerate if errors occur',
        'never share access token or app secret',
      ],
    ),
    _Guide(
      icon: '☁️', title: 'cloudinary',
      subtitle: 'temporary video hosting',
      color: AppColors.accentCyan,
      link: 'https://cloudinary.com/',
      linkLabel: 'sign up free',
      steps: [
        _Step('1', 'create free account', 'sign up at cloudinary.com'),
        _Step('2', 'go to dashboard', 'you will see credentials'),
        _Step('3', 'copy cloud name', 'shown at top of dashboard'),
        _Step('4', 'copy api key', 'in api credentials section'),
        _Step('5', 'copy api secret', 'click reveal to see it'),
        _Step('6', 'paste in settings', 'cloudinary section'),
      ],
      tips: [
        'free tier: 25gb storage + 25gb bandwidth per month',
        'used only for instagram publishing',
        'videos auto-deleted after publish',
      ],
    ),
    _Guide(
      icon: '▶️', title: 'youtube',
      subtitle: 'upload to youtube shorts',
      color: AppColors.accentRed,
      link: 'https://console.cloud.google.com/',
      linkLabel: 'google cloud console',
      steps: [
        _Step('1', 'go to google cloud', 'console.cloud.google.com'),
        _Step('2', 'create project', 'name it apollo-youtube'),
        _Step('3', 'enable api', 'apis & services > enable youtube data api v3'),
        _Step('4', 'oauth consent', 'set app name, email, save'),
        _Step('5', 'add test user', 'your youtube channel email'),
        _Step('6', 'create credentials', 'oauth client id > android'),
        _Step('7', 'package name', 'com.tahasite.apollo'),
        _Step('8', 'add sha-1 fingerprint', 'from android studio > gradle > signing report'),
        _Step('9', 'connect in publish', 'tab publish > connect youtube account'),
      ],
      tips: [
        'select ANDROID app type when creating oauth client',
        'sha-1 is required for android sign-in',
        'shorts requirements: mp4, 9:16, under 3 minutes',
      ],
    ),
  ];

  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _buildGuideCard(_guides[i], i),
                  childCount: _guides.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.menu_book_rounded, color: AppColors.accentAmber, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('tutorials', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text('step by step guides for every api', style: TextStyle(fontSize: 11, color: AppColors.textDim)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(_Guide guide, int index) {
    final expanded = _expandedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: expanded ? guide.color.withOpacity(0.4) : AppColors.borderDim),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expandedIndex = expanded ? -1 : index),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: guide.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(guide.icon, style: const TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(guide.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(guide.subtitle, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: guide.color, size: 24),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(guide),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(_Guide guide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1, color: AppColors.borderDim, margin: const EdgeInsets.only(bottom: 14)),
          _sectionHeader('🚀', 'quick steps', guide.color),
          const SizedBox(height: 10),
          ...guide.steps.map((s) => _buildStep(s, guide.color)),
          const SizedBox(height: 16),
          if (guide.tips.isNotEmpty) ...[
            _sectionHeader('💡', 'tips', guide.color),
            const SizedBox(height: 8),
            ...guide.tips.map((t) => _buildTip(t)),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse(guide.link), mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: Text(guide.linkLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: guide.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05, end: 0);
  }

  Widget _sectionHeader(String icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(icon, style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildStep(_Step step, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(step.num, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(step.desc, style: const TextStyle(color: AppColors.textDim, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.accentGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _Guide {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final String link;
  final String linkLabel;
  final List<_Step> steps;
  final List<String> tips;

  const _Guide({
    required this.icon, required this.title, required this.subtitle,
    required this.color, required this.link, required this.linkLabel,
    required this.steps, required this.tips,
  });
}

class _Step {
  final String num;
  final String title;
  final String desc;
  const _Step(this.num, this.title, this.desc);
}