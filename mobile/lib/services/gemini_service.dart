import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/config_model.dart';
import 'config_service.dart';

class GeminiResult {
  final String identifiedTopic;
  final String instagramCaption;
  final String instagramHashtags;
  final String youtubeTitle;
  final String youtubeDescription;
  final String youtubeHashtags;

  GeminiResult({
    required this.identifiedTopic,
    required this.instagramCaption,
    required this.instagramHashtags,
    required this.youtubeTitle,
    required this.youtubeDescription,
    required this.youtubeHashtags,
  });
}

class GeminiService {
  static String _normalizeHashtags(dynamic value) {
    List<String> items = [];
    if (value is List) {
      items = value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    } else if (value is String) {
      items = value.replaceAll(',', ' ').replaceAll('\n', ' ').split(' ').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    final tags = <String>[];
    final seen = <String>{};
    for (var item in items) {
      var tag = item.trim();
      if (tag.isEmpty) continue;
      if (!tag.startsWith('#')) tag = '#$tag';
      tag = '#${tag.substring(1).replaceAll(' ', '').replaceAll('#', '')}';
      if (tag.length > 1 && !seen.contains(tag.toLowerCase())) {
        seen.add(tag.toLowerCase());
        tags.add(tag);
      }
    }
    return tags.join(' ');
  }

  static String _cleanupJson(String text) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceAll('```json', '').replaceAll('```', '').trim();
    }
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start != -1 && end != -1) {
      cleaned = cleaned.substring(start, end + 1);
    }
    return cleaned;
  }

  static String _buildPrompt(String description, String videoFileName, String language) {
    return '''You are an expert social media strategist for viral short videos, instagram reels, and youtube shorts.

Your task:
1. Analyze the user description and video filename to understand the content.
2. Create a high engagement instagram reel caption with strong hook energy.
3. Create an seo friendly youtube shorts package.
4. Use plenty of relevant emojis naturally throughout all text fields.
5. Keep it clean, viral, and realistic.
6. Write ALL output text in $language language.
7. The user may describe the video in any language. always produce output in $language regardless of input language.

Return valid json only with this exact structure:
{
  "identified_topic": "short clear topic summary with emojis",
  "instagram_caption": "2 to 5 short lines with emojis, punchy and scroll stopping",
  "instagram_hashtags": ["12 to 18 relevant hashtags"],
  "youtube_title": "seo friendly shorts title under 100 characters with emojis",
  "youtube_description": "2 to 4 short lines with emojis, energy and context",
  "youtube_hashtags": ["8 to 12 strong hashtags"]
}

Video filename:
$videoFileName

User description:
$description''';
  }

  static Future<GeminiResult> _callApi(String apiKey, String model, String prompt) async {
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';
    final dio = Dio();
    final response = await dio.post(
      url,
      data: {
        'contents': [{'parts': [{'text': prompt}]}],
        'generationConfig': {'temperature': 0.8, 'topP': 0.95, 'responseMimeType': 'application/json'}
      },
      options: Options(headers: {'Content-Type': 'application/json'}, receiveTimeout: const Duration(seconds: 45)),
    );
    final data = response.data as Map;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) throw Exception('empty gemini response');
    final parts = (candidates.first['content']?['parts']) as List?;
    if (parts == null || parts.isEmpty) throw Exception('missing response parts');
    final text = parts.first['text']?.toString() ?? '';
    if (text.isEmpty) throw Exception('empty text payload');
    final cleaned = _cleanupJson(text);
    final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
    return GeminiResult(
      identifiedTopic: parsed['identified_topic']?.toString() ?? '',
      instagramCaption: parsed['instagram_caption']?.toString() ?? '',
      instagramHashtags: _normalizeHashtags(parsed['instagram_hashtags']),
      youtubeTitle: parsed['youtube_title']?.toString() ?? '',
      youtubeDescription: parsed['youtube_description']?.toString() ?? '',
      youtubeHashtags: _normalizeHashtags(parsed['youtube_hashtags']),
    );
  }

  static Future<GeminiResult> generate(ConfigModel config, String description, String videoFileName, String language) async {
    if (config.geminiApiKeys.isEmpty) {
      throw Exception('no gemini api keys. add at least one key in settings.');
    }
    final keys = config.geminiApiKeys;
    final startIndex = config.geminiKeyIndex % keys.length;
    final prompt = _buildPrompt(description, videoFileName, language);
    final errors = <String>[];
    for (var step = 0; step < keys.length; step++) {
      final idx = (startIndex + step) % keys.length;
      try {
        final result = await _callApi(keys[idx], config.geminiModel, prompt);
        config.geminiKeyIndex = (idx + 1) % keys.length;
        await ConfigService.instance.save(config);
        return result;
      } catch (e) {
        errors.add('key ${idx + 1}: $e');
      }
    }
    throw Exception('all gemini api keys failed\n${errors.join('\n')}');
  }
}