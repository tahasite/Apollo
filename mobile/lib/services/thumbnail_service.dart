import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ThumbnailService {
  static Future<String?> generateThumbnail(String videoPath) async {
    try {
      final dir = await getTemporaryDirectory();
      final outputPath = p.join(dir.path, 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final result = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: outputPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1080,
        quality: 95,
      );
      return result;
    } catch (_) {
      return null;
    }
  }

  static Future<Uint8List?> generateThumbnailBytes(String videoPath) async {
    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1080,
        quality: 95,
      );
      return bytes;
    } catch (_) {
      return null;
    }
  }
}