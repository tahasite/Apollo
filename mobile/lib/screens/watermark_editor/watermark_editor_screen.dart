import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/thumbnail_service.dart';
import '../../theme/app_colors.dart';

class WatermarkEditorScreen extends StatefulWidget {
  const WatermarkEditorScreen({super.key});

  @override
  State<WatermarkEditorScreen> createState() => _WatermarkEditorScreenState();
}

class _WatermarkEditorScreenState extends State<WatermarkEditorScreen> {
  ui.Image? _thumbImage;
  ui.Image? _wmImage;
  int _origWidth = 0;
  int _origHeight = 0;
  int _wmWidth = 0;
  int _wmHeight = 0;
  bool _loading = true;
  String? _error;
  String? _wmPath;

  double _wmScale = 1.0;
  double _wmX = 50.0;
  double _wmY = 50.0;
  double _canvasScale = 1.0;
  Offset _canvasOffset = Offset.zero;
  bool _dragging = false;
  double _baseCanvasScale = 1.0;
  Offset _lastFocalPoint = Offset.zero;

  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final project = context.read<ProjectProvider>().current;
    if (project == null) {
      setState(() {
        _loading = false;
        _error = 'no project loaded';
      });
      return;
    }
    try {
      final bytes = await ThumbnailService.generateThumbnailBytes(project.videoPath);
      if (bytes == null) throw Exception('failed to load frame');
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      _wmPath = project.wmPath;
      _wmScale = project.wmScale;
      _wmX = project.wmX;
      _wmY = project.wmY;

      ui.Image? wm;
      int ww = 0, wh = 0;
      if (_wmPath != null && _wmPath!.isNotEmpty && File(_wmPath!).existsSync()) {
        final wmBytes = await File(_wmPath!).readAsBytes();
        final wmCodec = await ui.instantiateImageCodec(wmBytes);
        final wmFrame = await wmCodec.getNextFrame();
        wm = wmFrame.image;
        ww = wm.width;
        wh = wm.height;
      }

      setState(() {
        _thumbImage = image;
        _origWidth = image.width;
        _origHeight = image.height;
        _wmImage = wm;
        _wmWidth = ww;
        _wmHeight = wh;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _pickWatermark() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) return;

    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      setState(() {
        _wmImage = frame.image;
        _wmWidth = frame.image.width;
        _wmHeight = frame.image.height;
        _wmPath = file.path;
        _wmX = _origWidth / 2 - (_wmWidth / 2);
        _wmY = _origHeight / 2 - (_wmHeight / 2);
        _wmScale = 1.0;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('image load failed: $e')));
    }
  }

  Offset? _canvasToImage(Offset localPos, Size canvasSize) {
    final imgW = _origWidth.toDouble();
    final imgH = _origHeight.toDouble();
    final fitScale = _computeFitScale(canvasSize, imgW, imgH);
    final displayedW = imgW * fitScale * _canvasScale;
    final displayedH = imgH * fitScale * _canvasScale;
    final imgOffsetX = (canvasSize.width - displayedW) / 2 + _canvasOffset.dx;
    final imgOffsetY = (canvasSize.height - displayedH) / 2 + _canvasOffset.dy;
    final relX = (localPos.dx - imgOffsetX) / (fitScale * _canvasScale);
    final relY = (localPos.dy - imgOffsetY) / (fitScale * _canvasScale);
    return Offset(relX, relY);
  }

  double _computeFitScale(Size canvas, double imgW, double imgH) {
    final scaleX = canvas.width / imgW;
    final scaleY = canvas.height / imgH;
    return scaleX < scaleY ? scaleX : scaleY;
  }

  bool _isInsideWatermark(Offset imgPos) {
    if (_wmImage == null) return false;
    final w = _wmWidth * _wmScale;
    final h = _wmHeight * _wmScale;
    return imgPos.dx >= _wmX && imgPos.dx <= _wmX + w && imgPos.dy >= _wmY && imgPos.dy <= _wmY + h;
  }

  Future<void> _save() async {
    final project = context.read<ProjectProvider>().current;
    if (project == null) return;
    if (_wmPath == null || _wmPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('select a watermark image first')),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    project.wmPath = _wmPath!;
    project.wmScale = _wmScale;
    project.wmX = _wmX;
    project.wmY = _wmY;
    project.status = 'watermark_ready';
    await context.read<ProjectProvider>().save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 18),
            SizedBox(width: 10),
            Text('watermark saved', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        backgroundColor: AppColors.bgCard,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.accentGreen.withOpacity(0.3))),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accentCyan))
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.accentRed)))
                      : _canvasView(),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(color: AppColors.bgCard, border: Border(bottom: BorderSide(color: AppColors.borderDim))),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          ),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: AppColors.accentCyan.withOpacity(0.15), borderRadius: BorderRadius.circular(9)),
            child: const Center(child: Text('💧', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('watermark', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                Text('drag · pinch to zoom', style: TextStyle(color: AppColors.textDim, fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            onPressed: _pickWatermark,
            icon: const Icon(Icons.image_rounded, color: AppColors.accentCyan, size: 20),
            tooltip: 'change image',
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: AppColors.accentGreen,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: _save,
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('save', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _canvasView() {
    if (_wmImage == null) return _pickWatermarkPrompt();
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onScaleStart: (details) {
            _lastFocalPoint = details.focalPoint;
            _baseCanvasScale = _canvasScale;
            if (details.pointerCount == 1) {
              final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
              if (box != null) {
                final local = box.globalToLocal(details.focalPoint);
                final imgPos = _canvasToImage(local, canvasSize);
                if (imgPos != null && _isInsideWatermark(imgPos)) {
                  _dragging = true;
                }
              }
            } else {
              _dragging = false;
            }
          },
          onScaleUpdate: (details) {
            if (details.pointerCount >= 2) {
              setState(() {
                _canvasScale = (_baseCanvasScale * details.scale).clamp(0.5, 5.0);
                _canvasOffset += details.focalPoint - _lastFocalPoint;
                _lastFocalPoint = details.focalPoint;
              });
            } else if (_dragging) {
              final delta = details.focalPoint - _lastFocalPoint;
              final fitScale = _computeFitScale(canvasSize, _origWidth.toDouble(), _origHeight.toDouble());
              final effective = fitScale * _canvasScale;
              setState(() {
                _wmX += delta.dx / effective;
                _wmY += delta.dy / effective;
                _lastFocalPoint = details.focalPoint;
              });
            }
          },
          onScaleEnd: (_) => _dragging = false,
          child: Container(
            key: _canvasKey,
            color: const Color(0xFF050508),
            child: CustomPaint(
              size: canvasSize,
              painter: _WmPainter(
                bg: _thumbImage,
                wm: _wmImage,
                origWidth: _origWidth,
                origHeight: _origHeight,
                wmWidth: _wmWidth,
                wmHeight: _wmHeight,
                wmScale: _wmScale,
                wmX: _wmX,
                wmY: _wmY,
                canvasScale: _canvasScale,
                canvasOffset: _canvasOffset,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pickWatermarkPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentCyan.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.image_rounded, size: 40, color: AppColors.accentCyan),
            ),
            const SizedBox(height: 20),
            const Text('no watermark selected', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('pick a png/jpg image to use as watermark', style: TextStyle(color: AppColors.textDim, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickWatermark,
              icon: const Icon(Icons.folder_open_rounded, size: 16),
              label: const Text('browse image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    if (_wmImage == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderDim)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.aspect_ratio_rounded, size: 16, color: AppColors.accentCyan),
                  const SizedBox(width: 6),
                  const Text('scale', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.accentCyan,
                        inactiveTrackColor: AppColors.borderDim,
                        thumbColor: AppColors.accentCyan,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        min: 0.05, max: 3.0,
                        value: _wmScale,
                        onChanged: (v) => setState(() => _wmScale = v),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6)),
                    child: Text('${(_wmScale * 100).toInt()}%', style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          const Icon(Icons.my_location_rounded, size: 14, color: AppColors.textDim),
                          const SizedBox(height: 2),
                          Text('${_wmX.toInt()}, ${_wmY.toInt()}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _actionBtn(Icons.zoom_out_rounded, () => setState(() => _canvasScale = (_canvasScale - 0.2).clamp(0.5, 5.0))),
                  const SizedBox(width: 6),
                  _actionBtn(Icons.center_focus_strong_rounded, () {
                    setState(() {
                      _canvasScale = 1.0;
                      _canvasOffset = Offset.zero;
                    });
                  }),
                  const SizedBox(width: 6),
                  _actionBtn(Icons.zoom_in_rounded, () => setState(() => _canvasScale = (_canvasScale + 0.2).clamp(0.5, 5.0))),
                  const SizedBox(width: 6),
                  _actionBtn(Icons.filter_center_focus_rounded, () {
                    setState(() {
                      _wmX = _origWidth / 2 - (_wmWidth * _wmScale / 2);
                      _wmY = _origHeight / 2 - (_wmHeight * _wmScale / 2);
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.borderDim)),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _WmPainter extends CustomPainter {
  final ui.Image? bg;
  final ui.Image? wm;
  final int origWidth;
  final int origHeight;
  final int wmWidth;
  final int wmHeight;
  final double wmScale;
  final double wmX;
  final double wmY;
  final double canvasScale;
  final Offset canvasOffset;

  _WmPainter({
    required this.bg, required this.wm,
    required this.origWidth, required this.origHeight,
    required this.wmWidth, required this.wmHeight,
    required this.wmScale, required this.wmX, required this.wmY,
    required this.canvasScale, required this.canvasOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bg == null) return;
    final imgW = origWidth.toDouble();
    final imgH = origHeight.toDouble();
    final fitScale = _fit(size, imgW, imgH);
    final displayedW = imgW * fitScale * canvasScale;
    final displayedH = imgH * fitScale * canvasScale;
    final offsetX = (size.width - displayedW) / 2 + canvasOffset.dx;
    final offsetY = (size.height - displayedH) / 2 + canvasOffset.dy;

    canvas.drawImageRect(
      bg!,
      Rect.fromLTWH(0, 0, imgW, imgH),
      Rect.fromLTWH(offsetX, offsetY, displayedW, displayedH),
      Paint(),
    );

    if (wm != null && wmWidth > 0 && wmHeight > 0) {
      final effective = fitScale * canvasScale;
      final wmDstW = wmWidth * wmScale * effective;
      final wmDstH = wmHeight * wmScale * effective;
      final wmDstX = offsetX + wmX * effective;
      final wmDstY = offsetY + wmY * effective;
      canvas.drawImageRect(
        wm!,
        Rect.fromLTWH(0, 0, wmWidth.toDouble(), wmHeight.toDouble()),
        Rect.fromLTWH(wmDstX, wmDstY, wmDstW, wmDstH),
        Paint(),
      );
      final border = Paint()
        ..color = const Color(0xFF06B6D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(Rect.fromLTWH(wmDstX, wmDstY, wmDstW, wmDstH), border);
    }

    final frameBorder = Paint()
      ..color = const Color(0xFF444455)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(offsetX, offsetY, displayedW, displayedH), frameBorder);
  }

  double _fit(Size c, double iW, double iH) {
    final sx = c.width / iW;
    final sy = c.height / iH;
    return sx < sy ? sx : sy;
  }

  @override
  bool shouldRepaint(covariant _WmPainter old) => true;
}