import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import '../models/project_model.dart';

class VideoProcessor {
  static Future<String> processVideo({
    required ProjectModel project,
    Function(double, String)? onProgress,
  }) async {
    final videoPath = project.videoPath;
    final outputPath = project.outputPath;

    if (File(outputPath).existsSync()) {
      try {
        await File(outputPath).delete();
      } catch (_) {}
    }

    if (onProgress != null) onProgress(0.02, 'analyzing video...');

    final info = await VideoCompress.getMediaInfo(videoPath);
    if (info.duration == null) throw Exception('could not read video info');

    if (onProgress != null) onProgress(0.05, 'starting compression...');

    final subscription = VideoCompress.compressProgress$.subscribe((prog) {
      if (onProgress != null) {
        final p = (prog / 100.0).clamp(0.05, 0.98);
        onProgress(p, 'processing ${prog.toInt()}%');
      }
    });

    try {
      final compressed = await VideoCompress.compressVideo(
        videoPath,
        quality: VideoQuality.HighestQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 30,
      );

      if (compressed == null || compressed.path == null) {
        throw Exception('compression returned null');
      }

      if (onProgress != null) onProgress(0.95, 'saving output...');

      await File(compressed.path!).copy(outputPath);

      if (!File(outputPath).existsSync()) {
        throw Exception('output file was not created');
      }

      if (onProgress != null) onProgress(1.0, 'render complete');
      return outputPath;
    } finally {
      subscription.unsubscribe();
    }
  }

  static Future<Map<String, dynamic>?> getVideoInfo(String path) async {
    try {
      final info = await VideoCompress.getMediaInfo(path);
      return {
        'duration': (info.duration ?? 0) / 1000.0,
        'width': info.width ?? 0,
        'height': info.height ?? 0,
        'fps': 30.0,
      };
    } catch (_) {
      return null;
    }
  }
}