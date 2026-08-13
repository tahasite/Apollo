import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart' show sha1;
import 'dart:convert';

class CloudinaryUploadResult {
  final String url;
  final String publicId;
  CloudinaryUploadResult({required this.url, required this.publicId});
}

class CloudinaryService {
  final String cloudName;
  final String apiKey;
  final String apiSecret;

  CloudinaryService({required this.cloudName, required this.apiKey, required this.apiSecret});

  String _generateSignature(Map<String, String> params) {
    final sorted = params.keys.toList()..sort();
    final toSign = sorted.map((k) => '$k=${params[k]}').join('&');
    final bytes = utf8.encode(toSign + apiSecret);
    return sha1.convert(bytes).toString();
  }

  Future<CloudinaryUploadResult> uploadVideo(String filePath, {Function(double, String)? onProgress}) async {
    if (onProgress != null) onProgress(0.05, 'preparing cloudinary upload...');
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final publicId = 'apollo_reel_$timestamp';
    final folder = 'apollo_uploads';

    final paramsToSign = <String, String>{
      'folder': folder,
      'public_id': publicId,
      'timestamp': timestamp,
    };
    final signature = _generateSignature(paramsToSign);

    final url = 'https://api.cloudinary.com/v1_1/$cloudName/video/upload';
    final dio = Dio();

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'api_key': apiKey,
      'timestamp': timestamp,
      'folder': folder,
      'public_id': publicId,
      'signature': signature,
    });

    final response = await dio.post(
      url,
      data: formData,
      onSendProgress: (sent, total) {
        if (total > 0 && onProgress != null) {
          final pct = sent / total;
          onProgress(0.1 + (pct * 0.35), 'uploading to cloudinary... ${(pct * 100).toInt()}%');
        }
      },
      options: Options(receiveTimeout: const Duration(minutes: 10)),
    );

    final data = response.data as Map<String, dynamic>;
    final secureUrl = data['secure_url']?.toString() ?? '';
    final returnedPublicId = data['public_id']?.toString() ?? '';

    if (secureUrl.isEmpty) {
      throw Exception('cloudinary upload failed: ${response.data}');
    }

    return CloudinaryUploadResult(url: secureUrl, publicId: returnedPublicId);
  }

  Future<bool> deleteVideo(String publicId) async {
    try {
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final paramsToSign = <String, String>{
        'public_id': publicId,
        'timestamp': timestamp,
      };
      final signature = _generateSignature(paramsToSign);
      final url = 'https://api.cloudinary.com/v1_1/$cloudName/video/destroy';
      final dio = Dio();
      await dio.post(url, data: FormData.fromMap({
        'public_id': publicId,
        'api_key': apiKey,
        'timestamp': timestamp,
        'signature': signature,
      }));
      return true;
    } catch (_) {
      return false;
    }
  }
}