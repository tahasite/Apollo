import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/instagram_service.dart';
import '../../services/youtube_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/labeled_input.dart';

class PublishScreen extends StatefulWidget {
  const PublishScreen({super.key});

  @override
  State<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends State<PublishScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _ytTitleCtrl = TextEditingController();
  final _ytDescCtrl = TextEditingController();
  final _ytTagsCtrl = TextEditingController();
  final _igCaptionCtrl = TextEditingController();
  String _ytPrivacy = 'private';

  final YoutubeService _yt = YoutubeService();
  bool _busy = false;
  double _progress = 0;
  String _progressText = 'ready';
  final List<_LogEntry> _logs = [];

  String? _ytUserEmail;
  bool _ytConnected = false;
  bool _igTokenOk = false;
  String? _igUsername;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFromProject();
      _checkYoutubeAuth();
      _checkInstagramAuth();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ytTitleCtrl.dispose();
    _ytDescCtrl.dispose();
    _ytTagsCtrl.dispose();
    _igCaptionCtrl.dispose();
    super.dispose();
  }

  void _syncFromProject() {
    final p = context.read<ProjectProvider>().current;
    if (p == null) return;
    _ytTitleCtrl.text = p.aiYoutubeTitle;
    _ytDescCtrl.text = p.aiYoutubeDescription;
    _ytTagsCtrl.text = p.aiYoutubeHashtags;
    _igCaptionCtrl.text = '${p.aiInstagramCaption}\n\n${p.aiInstagramHashtags}'.trim();
    setState(() {});
  }

  Future<void> _checkYoutubeAuth() async {
    try {
      final email = await _yt.currentUserEmail();
      if (!mounted) return;
      setState(() {
        _ytConnected = email != null;
        _ytUserEmail = email;
      });
    } catch (_) {
      if (mounted) setState(() => _ytConnected = false);
    }
  }

  Future<void> _checkInstagramAuth() async {
    final config = context.read<ConfigProvider>().config;
    if (!config.isInstagramConfigured) {
      setState(() {
        _igTokenOk = false;
        _igUsername = null;
      });
      return;
    }
    try {
      final ig = InstagramService(
        accessToken: config.instagramAccessToken,
        userId: config.instagramUserId,
        appSecret: config.instagramAppSecret,
      );
      final data = await ig.verifyToken();
      if (!mounted) return;
      setState(() {
        _igTokenOk = true;
        _igUsername = data['username']?.toString();
      });
      _addLog('instagram verified: @$_igUsername', LogType.success);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _igTokenOk = false;
        _igUsername = null;
      });
      _addLog('instagram token issue: $e', LogType.error);
    }
  }

  Future<void> _connectYoutube() async {
    if (_busy) return;
    setState(() => _busy = true);
    _addLog('opening google sign in...', LogType.info);
    try {
      final account = await _yt.signIn();
      if (!mounted) return;
      setState(() {
        _ytConnected = account != null;
        _ytUserEmail = account?.email;
      });
      _addLog('youtube connected: ${account?.email}', LogType.success);
    } catch (e) {
      _addLog('youtube sign in failed: $e', LogType.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnectYoutube() async {
    await _yt.signOut();
    if (!mounted) return;
    setState(() {
      _ytConnected = false;
      _ytUserEmail = null;
    });
    _addLog('youtube disconnected', LogType.info);
  }

  Future<void> _publishYoutube() async {
    if (_busy) return;
    final project = context.read<ProjectProvider>().current;
    if (project == null) return _showWarn('load a project first');
    if (!File(project.outputPath).existsSync()) return _showWarn('render video first');
    if (_ytTitleCtrl.text.trim().isEmpty) return _showWarn('enter a title');

    setState(() {
      _busy = true;
      _progress = 0;
      _progressText = 'starting youtube upload...';
    });
    _addLog('starting youtube upload: ${_ytTitleCtrl.text}', LogType.info);

    try {
      final videoId = await _yt.uploadShort(
        videoPath: project.outputPath,
        title: _ytTitleCtrl.text.trim(),
        description: _ytDescCtrl.text.trim(),
        tagsText: _ytTagsCtrl.text.trim(),
        privacy: _ytPrivacy,
        onProgress: (v, t) {
          if (!mounted) return;
          setState(() {
            _progress = v;
            _progressText = t;
          });
          _addLog(t, LogType.info);
        },
      );
      _addLog('youtube complete: $videoId', LogType.success);
      _addLog('https://youtube.com/shorts/$videoId', LogType.link);
      _showSuccess('published to youtube!\nid: $videoId');
    } catch (e) {
      _addLog('youtube upload failed: $e', LogType.error);
      _showError('youtube upload failed');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progressText = 'ready';
        });
      }
    }
  }

  Future<void> _publishInstagram() async {
    if (_busy) return;
    final project = context.read<ProjectProvider>().current;
    final config = context.read<ConfigProvider>().config;
    if (project == null) return _showWarn('load a project first');
    if (!File(project.outputPath).existsSync()) return _showWarn('render video first');
    if (!config.isInstagramConfigured) return _showWarn('configure instagram in settings');
    if (!config.isCloudinaryConfigured) return _showWarn('configure cloudinary in settings');
    if (_igCaptionCtrl.text.trim().isEmpty) return _showWarn('enter a caption');

    setState(() {
      _busy = true;
      _progress = 0;
      _progressText = 'starting instagram publish...';
    });
    _addLog('starting instagram reel publish', LogType.info);

    try {
      final ig = InstagramService(
        accessToken: config.instagramAccessToken,
        userId: config.instagramUserId,
        appSecret: config.instagramAppSecret,
      );
      final mediaId = await ig.publishReel(
        videoPath: project.outputPath,
        caption: _igCaptionCtrl.text.trim(),
        cloudName: config.cloudinaryCloudName,
        cloudApiKey: config.cloudinaryApiKey,
        cloudApiSecret: config.cloudinaryApiSecret,
        onProgress: (v, t) {
          if (!mounted) return;
          setState(() {
            _progress = v;
            _progressText = t;
          });
          _addLog(t, LogType.info);
        },
      );
      _addLog('instagram published: $mediaId', LogType.success);
      _showSuccess('published to instagram!\nid: $mediaId');
    } catch (e) {
      _addLog('instagram publish failed: $e', LogType.error);
      _showError('instagram publish failed');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progressText = 'ready';
        });
      }
    }
  }

  void _addLog(String msg, LogType type) {
    setState(() {
      _logs.insert(0, _LogEntry(time: DateTime.now(), message: msg, type: type));
      if (_logs.length > 100) _logs.removeLast();
    });
  }

  void _clearLogs() => setState(() => _logs.clear());

  void _copyLogs() {
    final text = _logs.reversed.map((l) => '[${DateFormat('HH:mm:ss').format(l.time)}] ${l.message}').join('\n');
    Clipboard.setData(ClipboardData(text: text));
    _showInfo('logs copied');
  }

  void _showWarn(String msg) => _snack(msg, AppColors.accentAmber, Icons.warning_rounded);
  void _showError(String msg) => _snack(msg, AppColors.accentRed, Icons.error_rounded);
  void _showSuccess(String msg) => _snack(msg, AppColors.accentGreen, Icons.check_circle_rounded);
  void _showInfo(String msg) => _snack(msg, AppColors.accentBlue, Icons.info_rounded);

  void _snack(String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 18),
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
    final project = context.watch<ProjectProvider>().current;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProjectStatus(project),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildYoutubePanel(),
                  _buildInstagramPanel(),
                ],
              ),
            ),
            _buildProgressBar(),
            _buildLogPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.sunsetGradient,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('publish', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text('upload to social platforms', style: TextStyle(fontSize: 10, color: AppColors.textDim)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectStatus(dynamic project) {
    final hasProject = project != null;
    final hasOutput = hasProject && File(project.outputPath).existsSync();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderDim),
      ),
      child: Row(
        children: [
          Icon(
            hasOutput ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: hasOutput ? AppColors.accentGreen : AppColors.accentAmber,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              !hasProject ? 'no project loaded' : hasOutput ? 'output ready to publish' : 'render video first',
              style: TextStyle(
                color: hasOutput ? AppColors.accentGreen : AppColors.accentAmber,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(gradient: AppColors.blueGradient, borderRadius: BorderRadius.circular(10)),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textDim,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        tabs: const [
          Tab(text: '▶️ youtube'),
          Tab(text: '📸 instagram'),
        ],
      ),
    );
  }

  Widget _buildYoutubePanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthCard(
            icon: Icons.play_circle_filled_rounded,
            color: AppColors.accentRed,
            connected: _ytConnected,
            subtitle: _ytConnected ? (_ytUserEmail ?? 'connected') : 'not connected',
            onConnect: _connectYoutube,
            onDisconnect: _disconnectYoutube,
          ),
          const SizedBox(height: 16),
          LabeledInput(label: 'title', controller: _ytTitleCtrl),
          const SizedBox(height: 12),
          LabeledInput(label: 'description', controller: _ytDescCtrl, maxLines: 4),
          const SizedBox(height: 12),
          LabeledInput(label: 'hashtags', controller: _ytTagsCtrl, maxLines: 2),
          const SizedBox(height: 12),
          const Text('privacy', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              _privacyChip('private', Icons.lock_rounded),
              const SizedBox(width: 6),
              _privacyChip('unlisted', Icons.link_rounded),
              const SizedBox(width: 6),
              _privacyChip('public', Icons.public_rounded),
            ],
          ),
          const SizedBox(height: 20),
          GradientButton(
            text: 'upload to youtube shorts',
            icon: Icons.cloud_upload_rounded,
            gradient: const LinearGradient(colors: [AppColors.accentRed, Color(0xFFB91C1C)]),
            onPressed: _publishYoutube,
            loading: _busy,
            enabled: !_busy,
          ),
        ],
      ),
    );
  }

  Widget _buildInstagramPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthCard(
            icon: Icons.camera_alt_rounded,
            color: AppColors.accentPink,
            connected: _igTokenOk,
            subtitle: _igTokenOk ? '@${_igUsername ?? "connected"}' : 'not configured',
            onConnect: _checkInstagramAuth,
            onDisconnect: null,
            connectLabel: 'verify token',
          ),
          const SizedBox(height: 16),
          LabeledInput(label: 'caption & hashtags', controller: _igCaptionCtrl, maxLines: 8),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentCyan.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.accentCyan),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'video is temporarily uploaded to cloudinary, then instagram fetches it. auto-deleted after publish.',
                    style: TextStyle(color: AppColors.accentCyan, fontSize: 10, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GradientButton(
            text: 'publish to instagram',
            icon: Icons.send_rounded,
            gradient: const LinearGradient(colors: [AppColors.accentPink, AppColors.accentPurple]),
            onPressed: _publishInstagram,
            loading: _busy,
            enabled: !_busy,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard({
    required IconData icon,
    required Color color,
    required bool connected,
    required String subtitle,
    VoidCallback? onConnect,
    VoidCallback? onDisconnect,
    String connectLabel = 'connect',
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: connected ? color.withOpacity(0.4) : AppColors.borderDim),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(color: connected ? AppColors.accentGreen : AppColors.textDim, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      connected ? 'connected' : 'disconnected',
                      style: TextStyle(color: connected ? AppColors.accentGreen : AppColors.textDim, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (!connected)
            ElevatedButton(
              onPressed: onConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: color, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
              child: Text(connectLabel),
            )
          else if (onDisconnect != null)
            IconButton(
              onPressed: onDisconnect,
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.textDim),
              tooltip: 'disconnect',
            ),
        ],
      ),
    );
  }

  Widget _privacyChip(String value, IconData icon) {
    final selected = _ytPrivacy == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _ytPrivacy = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.blueGradient : null,
            color: selected ? null : AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? Colors.transparent : AppColors.borderDim),
          ),
          child: Column(
            children: [
              Icon(icon, size: 14, color: selected ? Colors.white : AppColors.textDim),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: selected ? Colors.white : AppColors.textDim, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    if (!_busy && _progress == 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              minHeight: 6,
              backgroundColor: AppColors.borderDim,
              valueColor: const AlwaysStoppedAnimation(AppColors.accentBlue),
            ),
          ),
          const SizedBox(height: 6),
          Text(_progressText, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildLogPanel() {
    return Container(
      height: 130,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDim),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderDim))),
            child: Row(
              children: [
                const Icon(Icons.terminal_rounded, size: 14, color: AppColors.textDim),
                const SizedBox(width: 6),
                const Text('log', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _copyLogs,
                  icon: const Icon(Icons.copy_rounded, size: 14, color: AppColors.textDim),
                ),
                const SizedBox(width: 10),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _clearLogs,
                  icon: const Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.textDim),
                ),
              ],
            ),
          ),
          Expanded(
            child: _logs.isEmpty
                ? const Center(child: Text('no activity yet', style: TextStyle(color: AppColors.textDim, fontSize: 11)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    itemCount: _logs.length,
                    itemBuilder: (_, i) {
                      final log = _logs[i];
                      Color c;
                      switch (log.type) {
                        case LogType.success: c = AppColors.accentGreen; break;
                        case LogType.error: c = AppColors.accentRed; break;
                        case LogType.link: c = AppColors.accentCyan; break;
                        default: c = AppColors.textSecondary;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('HH:mm:ss').format(log.time),
                              style: const TextStyle(color: AppColors.textDim, fontSize: 9, fontFamily: 'monospace'),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                log.message,
                                style: TextStyle(color: c, fontSize: 10, fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

enum LogType { info, success, error, link }

class _LogEntry {
  final DateTime time;
  final String message;
  final LogType type;
  _LogEntry({required this.time, required this.message, required this.type});
}