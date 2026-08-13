import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/gemini_service.dart';
import '../../services/project_service.dart';
import '../../services/video_processor.dart';
import '../../theme/app_colors.dart';
import '../../widgets/language_selector.dart';
import '../../widgets/tool_card.dart';
import '../mask_editor/mask_editor_screen.dart';
import '../watermark_editor/watermark_editor_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _noteCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();
  final _igCaptionCtrl = TextEditingController();
  final _igTagsCtrl = TextEditingController();
  final _ytTitleCtrl = TextEditingController();
  final _ytDescCtrl = TextEditingController();
  final _ytTagsCtrl = TextEditingController();

  bool _rendering = false;
  double _renderProgress = 0;
  String _renderStatus = 'ready';
  bool _aiRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final projectProvider = context.read<ProjectProvider>();
      await projectProvider.loadLatest();
      _syncUiFromProject();
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _topicCtrl.dispose();
    _igCaptionCtrl.dispose();
    _igTagsCtrl.dispose();
    _ytTitleCtrl.dispose();
    _ytDescCtrl.dispose();
    _ytTagsCtrl.dispose();
    super.dispose();
  }

  void _syncUiFromProject() {
    final proj = context.read<ProjectProvider>().current;
    if (proj == null) return;
    _noteCtrl.text = proj.noteText;
    _topicCtrl.text = proj.identifiedTopic;
    _igCaptionCtrl.text = proj.aiInstagramCaption;
    _igTagsCtrl.text = proj.aiInstagramHashtags;
    _ytTitleCtrl.text = proj.aiYoutubeTitle;
    _ytDescCtrl.text = proj.aiYoutubeDescription;
    _ytTagsCtrl.text = proj.aiYoutubeHashtags;
    setState(() {});
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.first.path;
    if (path == null) return;
    final project = await ProjectService.instance.loadOrCreate(path);
    if (!mounted) return;
    await context.read<ProjectProvider>().setProject(project);
    _syncUiFromProject();
  }

  void _copy(String text, String label) {
    if (text.trim().isEmpty) {
      _snack('$label is empty');
      return;
    }
    Clipboard.setData(ClipboardData(text: text));
    _snack('$label copied');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _startRender() async {
    final project = context.read<ProjectProvider>().current;
    if (project == null) return;
    if (_rendering) return;

    setState(() {
      _rendering = true;
      _renderProgress = 0;
      _renderStatus = 'preparing...';
    });

    try {
      final output = await VideoProcessor.processVideo(
        project: project,
        onProgress: (prog, status) {
          if (!mounted) return;
          setState(() {
            _renderProgress = prog;
            _renderStatus = status;
          });
        },
      );
      project.outputPath = output;
      project.status = 'processed';
      await context.read<ProjectProvider>().save();
      if (!mounted) return;
      _snack('✓ video exported successfully');
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Row(
            children: [
              Icon(Icons.error_rounded, color: AppColors.accentRed),
              SizedBox(width: 10),
              Text('render failed', style: TextStyle(color: AppColors.textPrimary)),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(e.toString(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ok', style: TextStyle(color: AppColors.accentBlue)),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _rendering = false;
          _renderStatus = 'ready';
        });
      }
    }
  }

  Future<void> _startAiGenerate() async {
    final project = context.read<ProjectProvider>().current;
    final config = context.read<ConfigProvider>().config;
    if (project == null) return;
    if (_aiRunning) return;

    if (!config.isGeminiConfigured) {
      _snack('add a gemini api key in settings first');
      return;
    }

    setState(() => _aiRunning = true);

    try {
      final result = await GeminiService.generate(
        config,
        _noteCtrl.text.trim(),
        p.basename(project.videoPath),
        config.aiOutputLanguage,
      );

      project.identifiedTopic = result.identifiedTopic;
      project.aiInstagramCaption = result.instagramCaption;
      project.aiInstagramHashtags = result.instagramHashtags;
      project.aiYoutubeTitle = result.youtubeTitle;
      project.aiYoutubeDescription = result.youtubeDescription;
      project.aiYoutubeHashtags = result.youtubeHashtags;
      project.status = 'ai_ready';
      await context.read<ProjectProvider>().save();

      _topicCtrl.text = result.identifiedTopic;
      _igCaptionCtrl.text = result.instagramCaption;
      _igTagsCtrl.text = result.instagramHashtags;
      _ytTitleCtrl.text = result.youtubeTitle;
      _ytDescCtrl.text = result.youtubeDescription;
      _ytTagsCtrl.text = result.youtubeHashtags;

      if (!mounted) return;
      _snack('✨ ai content generated');
    } catch (e) {
      if (!mounted) return;
      final err = e.toString();
      _snack('ai failed: ${err.substring(0, err.length > 100 ? 100 : err.length)}');
    } finally {
      if (mounted) setState(() => _aiRunning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final configProvider = context.watch<ConfigProvider>();
    final project = projectProvider.current;
    final hasProject = project != null;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(configProvider)),
            SliverToBoxAdapter(child: _buildProjectBar(project)),
            SliverToBoxAdapter(child: _buildToolsSection(hasProject)),
            SliverToBoxAdapter(child: _buildAiStudio(configProvider, project)),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ConfigProvider configProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: AppColors.accentPurple.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4)),
              ],
            ),
            child: const Icon(Icons.play_arrow_rounded, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('apollo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 0.5)),
                Text('video editor', style: TextStyle(fontSize: 11, color: AppColors.textDim, letterSpacing: 1)),
              ],
            ),
          ),
          _statusBadge(configProvider),
        ],
      ),
    );
  }

  Widget _statusBadge(ConfigProvider provider) {
    final c = provider.config;
    final okCount = [c.isGeminiConfigured, c.isInstagramConfigured, c.isCloudinaryConfigured, c.isYoutubeConfigured].where((e) => e).length;
    Color color;
    if (okCount == 4) {
      color = AppColors.accentGreen;
    } else if (okCount >= 2) {
      color = AppColors.accentAmber;
    } else {
      color = AppColors.accentRed;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$okCount/4', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProjectBar(dynamic project) {
    final hasProject = project != null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: hasProject
            ? const LinearGradient(
                colors: [AppColors.bgCard, AppColors.bgCardHover],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasProject ? null : AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDim),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (hasProject ? AppColors.accentBlue : AppColors.textDim).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasProject ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              color: hasProject ? AppColors.accentBlue : AppColors.textDim,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasProject ? p.basename(project.videoPath) : 'no video selected',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: hasProject ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  hasProject ? 'tap to change video' : 'pick a video to start',
                  style: const TextStyle(fontSize: 11, color: AppColors.textDim),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.accentBlue,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _pickVideo,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.folder_open_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('browse', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildToolsSection(bool hasProject) {
    final project = context.watch<ProjectProvider>().current;
    final hasMask = project != null && File(project.maskPath).existsSync();
    final hasWm = project != null && project.wmPath.isNotEmpty && File(project.wmPath).existsSync();
    final hasOutput = project != null && File(project.outputPath).existsSync();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3, height: 16,
                decoration: BoxDecoration(gradient: AppColors.purpleGradient, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              const Text('tools', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ToolCard(
            icon: '🎭', title: 'mask editor',
            description: 'remove watermarks',
            color: AppColors.accentAmber,
            enabled: hasProject && !_rendering && !_aiRunning,
            completed: hasMask,
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const MaskEditorScreen()));
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(height: 8),
          ToolCard(
            icon: '💧', title: 'watermark',
            description: 'add branding overlay',
            color: AppColors.accentCyan,
            enabled: hasProject && !_rendering && !_aiRunning,
            completed: hasWm,
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const WatermarkEditorScreen()));
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(height: 8),
          ToolCard(
            icon: '⚡', title: 'render & export',
            description: _rendering ? _renderStatus : 'process final video',
            color: AppColors.accentGreen,
            enabled: hasProject && !_rendering && !_aiRunning,
            completed: hasOutput,
            onTap: _startRender,
          ),
          const SizedBox(height: 8),
          ToolCard(
            icon: '✨', title: 'ai generate',
            description: _aiRunning ? 'generating...' : 'captions and hashtags',
            color: AppColors.accentPurple,
            enabled: hasProject && _noteCtrl.text.trim().isNotEmpty && !_rendering && !_aiRunning,
            completed: project?.identifiedTopic.isNotEmpty ?? false,
            onTap: _startAiGenerate,
          ),
          if (_rendering || _aiRunning) ...[
            const SizedBox(height: 12),
            _buildInlineProgress(),
          ],
        ],
      ),
    );
  }

  Widget _buildInlineProgress() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentBlue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _rendering ? _renderStatus : 'generating ai content...',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
              if (_rendering)
                Text(
                  '${(_renderProgress * 100).toInt()}%',
                  style: const TextStyle(color: AppColors.accentBlue, fontSize: 12, fontWeight: FontWeight.w700),
                ),
            ],
          ),
          if (_rendering) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _renderProgress,
                minHeight: 4,
                backgroundColor: AppColors.borderDim,
                valueColor: const AlwaysStoppedAnimation(AppColors.accentBlue),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiStudio(ConfigProvider configProvider, dynamic project) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3, height: 16,
                decoration: BoxDecoration(gradient: AppColors.purpleGradient, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              const Text('ai content studio', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 14),
          _labeledField(
            icon: '📝', label: 'video description',
            controller: _noteCtrl,
            hint: 'describe the video briefly...',
            maxLines: 3,
            onChanged: (v) {
              final proj = context.read<ProjectProvider>().current;
              if (proj != null) {
                proj.noteText = v;
                context.read<ProjectProvider>().updateAndNotify();
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.language_rounded, color: AppColors.textDim, size: 16),
              const SizedBox(width: 6),
              const Text('output language:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(width: 10),
              LanguageSelector(
                value: configProvider.config.aiOutputLanguage,
                onChanged: (v) {
                  configProvider.config.aiOutputLanguage = v;
                  configProvider.save();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _resultTabs(),
        ],
      ),
    );
  }

  Widget _resultTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(12)),
            child: TabBar(
              indicator: BoxDecoration(gradient: AppColors.purpleGradient, borderRadius: BorderRadius.circular(10)),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textDim,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: '📸 instagram'),
                Tab(text: '▶️ youtube'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 500,
            child: TabBarView(
              children: [
                SingleChildScrollView(child: _instagramFields()),
                SingleChildScrollView(child: _youtubeFields()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _instagramFields() {
    return Column(
      children: [
        _labeledField(
          icon: '🏷️', label: 'topic',
          controller: _topicCtrl, hint: 'identified topic', maxLines: 1,
          onChanged: (v) => _updateField((p) => p.identifiedTopic = v),
        ),
        const SizedBox(height: 12),
        _labeledField(
          icon: '✍️', label: 'caption',
          controller: _igCaptionCtrl, hint: 'instagram caption', maxLines: 5,
          onChanged: (v) => _updateField((p) => p.aiInstagramCaption = v),
        ),
        const SizedBox(height: 12),
        _labeledField(
          icon: '#️⃣', label: 'hashtags',
          controller: _igTagsCtrl, hint: '#hashtag1 #hashtag2', maxLines: 3,
          onChanged: (v) => _updateField((p) => p.aiInstagramHashtags = v),
        ),
      ],
    );
  }

  Widget _youtubeFields() {
    return Column(
      children: [
        _labeledField(
          icon: '🎬', label: 'title',
          controller: _ytTitleCtrl, hint: 'youtube title', maxLines: 2,
          onChanged: (v) => _updateField((p) => p.aiYoutubeTitle = v),
        ),
        const SizedBox(height: 12),
        _labeledField(
          icon: '📄', label: 'description',
          controller: _ytDescCtrl, hint: 'youtube description', maxLines: 5,
          onChanged: (v) => _updateField((p) => p.aiYoutubeDescription = v),
        ),
        const SizedBox(height: 12),
        _labeledField(
          icon: '#️⃣', label: 'hashtags',
          controller: _ytTagsCtrl, hint: '#hashtag1 #hashtag2', maxLines: 3,
          onChanged: (v) => _updateField((p) => p.aiYoutubeHashtags = v),
        ),
      ],
    );
  }

  void _updateField(Function(dynamic) apply) {
    final proj = context.read<ProjectProvider>().current;
    if (proj != null) {
      apply(proj);
      context.read<ProjectProvider>().updateAndNotify();
    }
  }

  Widget _labeledField({
    required String icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            InkWell(
              onTap: () => _copy(controller.text, label),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6)),
                child: const Row(
                  children: [
                    Icon(Icons.copy_rounded, size: 12, color: AppColors.textDim),
                    SizedBox(width: 4),
                    Text('copy', style: TextStyle(color: AppColors.textDim, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.all(12)),
          onChanged: onChanged,
        ),
      ],
    );
  }
}