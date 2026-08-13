import 'package:dio/dio.dart';
import 'cloudinary_service.dart';

class InstagramService {
  final String accessToken;
  final String userId;
  final String appSecret;
  final String apiBase = 'https://graph.instagram.com';

  InstagramService({required this.accessToken, required this.userId, required this.appSecret});

  Future<Map<String, dynamic>> verifyToken() async {
    final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 30)));
    try {
      final response = await dio.get(
        '$apiBase/me',
        queryParameters: {'fields': 'id,username,account_type', 'access_token': accessToken},
      );
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('error')) {
        throw Exception('instagram error: ${(data['error'] as Map)['message']}');
      }
      return data;
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final d = e.response!.data as Map;
        if (d.containsKey('error')) throw Exception('instagram error: ${(d['error'] as Map)['message']}');
      }
      throw Exception('network error: ${e.message}');
    }
  }

  Future<String> _createReelContainer(String videoUrl, String caption) async {
    final dio = Dio();
    final response = await dio.post(
      '$apiBase/$userId/media',
      data: {
        'media_type': 'REELS',
        'video_url': videoUrl,
        'caption': caption,
        'share_to_feed': 'true',
        'access_token': accessToken,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final data = response.data as Map<String, dynamic>;
    if (data.containsKey('error')) throw Exception('container error: ${(data['error'] as Map)['message']}');
    final containerId = data['id']?.toString();
    if (containerId == null || containerId.isEmpty) throw Exception('no container id returned');
    return containerId;
  }

  Future<void> _waitForContainerReady(String containerId, {int maxWaitSeconds = 600}) async {
    final dio = Dio();
    final deadline = DateTime.now().add(Duration(seconds: maxWaitSeconds));
    int consecutiveErrors = 0;
    while (DateTime.now().isBefore(deadline)) {
      try {
        final response = await dio.get(
          '$apiBase/$containerId',
          queryParameters: {'fields': 'status_code,status,id', 'access_token': accessToken},
        );
        final data = response.data as Map<String, dynamic>;
        final statusCode = data['status_code']?.toString() ?? '';
        consecutiveErrors = 0;
        if (statusCode == 'FINISHED') return;
        if (statusCode == 'ERROR' || statusCode == 'EXPIRED') {
          throw Exception('instagram rejected video: ${data['status']}');
        }
      } catch (e) {
        if (e is Exception && e.toString().contains('rejected')) rethrow;
        consecutiveErrors++;
        if (consecutiveErrors >= 5) throw Exception('polling failed 5 times: $e');
      }
      await Future.delayed(const Duration(seconds: 8));
    }
    throw Exception('container did not finish within $maxWaitSeconds seconds');
  }

  Future<String> _publishContainer(String containerId) async {
    final dio = Dio();
    final response = await dio.post(
      '$apiBase/$userId/media_publish',
      data: {'creation_id': containerId, 'access_token': accessToken},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final data = response.data as Map<String, dynamic>;
    if (data.containsKey('error')) throw Exception('publish error: ${(data['error'] as Map)['message']}');
    final mediaId = data['id']?.toString();
    if (mediaId == null || mediaId.isEmpty) throw Exception('no media id returned');
    return mediaId;
  }

  Future<String> publishReel({
    required String videoPath,
    required String caption,
    required String cloudName,
    required String cloudApiKey,
    required String cloudApiSecret,
    Function(double, String)? onProgress,
  }) async {
    if (onProgress != null) onProgress(0.02, 'verifying instagram token...');
    await verifyToken();

    final uploader = CloudinaryService(cloudName: cloudName, apiKey: cloudApiKey, apiSecret: cloudApiSecret);
    final uploadResult = await uploader.uploadVideo(videoPath, onProgress: onProgress);

    try {
      if (onProgress != null) onProgress(0.45, 'creating reel container...');
      final containerId = await _createReelContainer(uploadResult.url, caption);
      if (onProgress != null) onProgress(0.5, 'waiting for instagram to process video...');
      await _waitForContainerReady(containerId);
      if (onProgress != null) onProgress(0.9, 'publishing reel...');
      final mediaId = await _publishContainer(containerId);
      if (onProgress != null) onProgress(1.0, 'published! id: $mediaId');
      await uploader.deleteVideo(uploadResult.publicId);
      return mediaId;
    } catch (e) {
      await uploader.deleteVideo(uploadResult.publicId);
      rethrow;
    }
  }
}