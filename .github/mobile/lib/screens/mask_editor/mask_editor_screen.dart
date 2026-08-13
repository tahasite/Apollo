import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../services/thumbnail_service.dart';
import '../../theme/app_colors.dart';

class MaskEditorScreen extends StatefulWidget {
  const MaskEditorScreen({super.key});

  @override
  State<MaskEditorScreen> createState() => _MaskEditorScreenState();
}

class _MaskEditorScreenState extends State<MaskEditorScreen> {
  Uint8List? _thumbBytes;
  ui.Image? _thumbImage;
  int _origWidth = 0;
  int _origHeight = 0;
  bool _loading = true;
  String? _error;

  final List<_Stroke> _strokes = [];
  final List<List<_Stroke>> _history = [];
  double _brushSize = 40;
  double _canvasScale = 1.0;
  Offset _canvasOffset = Offset.zero;
  bool _panning = false;
  Offset _lastFocalPoint = Offset.zero;
  double _baseScale = 1.0;

  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadThumbnail());
  }

  Future<void> _loadThumbnail() async {
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
      if (bytes == null) throw Exception('failed to generate thumbnail');
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      if (File(project.maskPath).existsSync()) {
        await _loadExistingMask(project.maskPath, image.width, image.height);
      }

      setState(() {
        _thumbBytes = bytes;
        _thumbImage = image;
        _origWidth = image.width;
        _origHeight = image.height;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadExistingMask(String path, int w, int h) async {}

  void _addStroke(Offset localPos, Size canvasSize) {
    if (_thumbImage == null) return;
    final imgPos = _canvasToImage(localPos, canvasSize);
    if (imgPos == null) return;
    _strokes.add(_Stroke(position: imgPos, size: _brushSize));
    setState(() {});
  }

  Offset? _canvasToImage(Offset localPos, Size canvasSize) {
    if (_thumbImage == null) return null;
    final imgW = _origWidth.toDouble();
    final imgH = _origHeight.toDouble();
    final fitScale = _computeFitScale(canvasSize, imgW, imgH);
    final displayedW = imgW * fitScale * _canvasScale;
    final displayedH = imgH * fitScale * _canvasScale;
    final imgOffsetX = (canvasSize.width - displayedW) / 2 + _canvasOffset.dx;
    final imgOffsetY = (canvasSize.height - displayedH) / 2 + _canvasOffset.dy;
    final relX = (localPos.dx - imgOffsetX) / (fitScale * _canvasScale);
    final relY = (localPos.dy - imgOffsetY) / (fitScale * _canvasScale);
    if (relX < 0 || relY < 0 || relX > imgW || relY > imgH) return null;
    return Offset(relX, relY);
  }

  double _computeFitScale(Size canvas, double imgW, double imgH) {
    final scaleX = canvas.width / imgW;
    final scaleY = canvas.height / imgH;
    return scaleX < scaleY ? scaleX : scaleY;
  }

  void _pushHistory() {
    _history.add(List.from(_strokes));
    if (_history.length > 30) _history.removeAt(0);
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      _strokes
        ..clear()
        ..addAll(_history.removeLast());
    });
  }

  void _clearAll() {
    if (_strokes.isEmpty) return;
    _pushHistory();
    setState(() => _strokes.clear());
  }

  Future<void> _saveMask() async {
    final project = context.read<ProjectProvider>().current;
    if (project == null || _thumbImage == null) return;

    HapticFeedback.mediumImpact();

    try {
      final maskImg = img.Image(width: _origWidth, height: _origHeight);
      img.fill(maskImg, color: img.ColorRgba8(0, 0, 0, 255));

      for (final stroke in _strokes) {
        img.fillCircle(
          maskImg,
          x: stroke.position.dx.toInt(),
          y: stroke.position.dy.toInt(),
          radius: stroke.size.toInt(),
          color: img.ColorRgba8(255, 255, 255, 255),
        );
      }

      final grayscale = img.grayscale(maskImg);
      final pngBytes = img.encodePng(grayscale);
      await File(project.maskPath).writeAsBytes(pngBytes);

      project.status = 'mask_ready';
      await context.read<ProjectProvider>().save();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 18),
              SizedBox(width: 10),
              Text('mask saved successfully', style: TextStyle(color: AppColors.textPrimary)),
            ],
          ),
          backgroundColor: AppColors.bgCard,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.accentGreen.withOpacity(0.3))),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('save failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _loading ? _loadingView() : _error != null ? _errorView() : _canvasView()),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.borderDim)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          ),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.accentAmber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(child: Text('🎭', style: TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('mask editor', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                Text('paint over areas to remove', style: TextStyle(color: AppColors.textDim, fontSize: 10)),
              ],
            ),
          ),
          if (_strokes.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentAmber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${_strokes.length} strokes',
                style: const TextStyle(color: AppColors.accentAmber, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: AppColors.accentGreen,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: _saveMask,
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

  Widget _loadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.accentAmber, strokeWidth: 3),
          SizedBox(height: 16),
          Text('loading video frame...', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_rounded, color: AppColors.accentRed, size: 48),
            const SizedBox(height: 12),
            Text(_error ?? 'unknown error', style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _canvasView() {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onScaleStart: (details) {
            _panning = details.pointerCount >= 2;
            _lastFocalPoint = details.focalPoint;
            _baseScale = _canvasScale;
            if (!_panning) _pushHistory();
          },
          onScaleUpdate: (details) {
            if (details.pointerCount >= 2) {
              setState(() {
                _canvasScale = (_baseScale * details.scale).clamp(0.5, 5.0);
                _canvasOffset += details.focalPoint - _lastFocalPoint;
                _lastFocalPoint = details.focalPoint;
              });
            } else {
              final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
              if (box != null) {
                final local = box.globalToLocal(details.focalPoint);
                _addStroke(local, canvasSize);
              }
            }
          },
          onScaleEnd: (_) {
            _panning = false;
          },
          child: Container(
            key: _canvasKey,
            color: const Color(0xFF050508),
            child: CustomPaint(
              size: canvasSize,
              painter: _MaskPainter(
                image: _thumbImage,
                origWidth: _origWidth,
                origHeight: _origHeight,
                strokes: _strokes,
                canvasScale: _canvasScale,
                canvasOffset: _canvasOffset,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
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
                  const Icon(Icons.brush_rounded, size: 16, color: AppColors.accentAmber),
                  const SizedBox(width: 6),
                  const Text('brush', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.accentAmber,
                        inactiveTrackColor: AppColors.borderDim,
                        thumbColor: AppColors.accentAmber,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        min: 5, max: 200,
                        value: _brushSize,
                        onChanged: (v) => setState(() => _brushSize = v),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(6)),
                    child: Text('${_brushSize.toInt()}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  _actionBtn(Icons.undo_rounded, 'undo', _history.isNotEmpty, _undo),
                  const SizedBox(width: 6),
                  _actionBtn(Icons.delete_outline_rounded, 'clear', _strokes.isNotEmpty, _clearAll),
                  const SizedBox(width: 6),
                  _actionBtn(Icons.zoom_out_rounded, '', true, () => setState(() => _canvasScale = (_canvasScale - 0.2).clamp(0.5, 5.0))),
                  const SizedBox(width: 6),
                  _actionBtn(Icons.center_focus_strong_rounded, '', true, () {
                    setState(() {
                      _canvasScale = 1.0;
                      _canvasOffset = Offset.zero;
                    });
                  }),
                  const SizedBox(width: 6),
                  _actionBtn(Icons.zoom_in_rounded, '', true, () => setState(() => _canvasScale = (_canvasScale + 0.2).clamp(0.5, 5.0))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, bool enabled, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: enabled ? AppColors.bgSurface : AppColors.bgSurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderDim),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: enabled ? AppColors.textPrimary : AppColors.textDim),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(label, style: TextStyle(color: enabled ? AppColors.textSecondary : AppColors.textDim, fontSize: 9)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Stroke {
  final Offset position;
  final double size;
  _Stroke({required this.position, required this.size});
}

class _MaskPainter extends CustomPainter {
  final ui.Image? image;
  final int origWidth;
  final int origHeight;
  final List<_Stroke> strokes;
  final double canvasScale;
  final Offset canvasOffset;

  _MaskPainter({
    required this.image,
    required this.origWidth,
    required this.origHeight,
    required this.strokes,
    required this.canvasScale,
    required this.canvasOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;
    final imgW = origWidth.toDouble();
    final imgH = origHeight.toDouble();
    final fitScale = _fit(size, imgW, imgH);
    final displayedW = imgW * fitScale * canvasScale;
    final displayedH = imgH * fitScale * canvasScale;
    final offsetX = (size.width - displayedW) / 2 + canvasOffset.dx;
    final offsetY = (size.height - displayedH) / 2 + canvasOffset.dy;

    final src = Rect.fromLTWH(0, 0, imgW, imgH);
    final dst = Rect.fromLTWH(offsetX, offsetY, displayedW, displayedH);
    canvas.drawImageRect(image!, src, dst, Paint());

    final effectiveScale = fitScale * canvasScale;
    final overlayPaint = Paint()..color = const Color(0x80FF3333);
    for (final stroke in strokes) {
      final px = offsetX + stroke.position.dx * effectiveScale;
      final py = offsetY + stroke.position.dy * effectiveScale;
      canvas.drawCircle(Offset(px, py), stroke.size * effectiveScale, overlayPaint);
    }

    final borderPaint = Paint()
      ..color = const Color(0xFF444455)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(dst, borderPaint);
  }

  double _fit(Size canvas, double imgW, double imgH) {
    final sx = canvas.width / imgW;
    final sy = canvas.height / imgH;
    return sx < sy ? sx : sy;
  }

  @override
  bool shouldRepaint(covariant _MaskPainter old) => true;
}