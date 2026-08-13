class ConfigModel {
  List<String> geminiApiKeys;
  String geminiModel;
  int geminiKeyIndex;

  String instagramAccessToken;
  String instagramUserId;
  String instagramAppSecret;

  String cloudinaryCloudName;
  String cloudinaryApiKey;
  String cloudinaryApiSecret;

  String youtubeClientId;
  String youtubeClientSecret;
  String youtubeJsonPath;

  String wmPath;
  double wmScale;
  double wmX;
  double wmY;

  String aiOutputLanguage;

  ConfigModel({
    this.geminiApiKeys = const [],
    this.geminiModel = 'gemini-2.0-flash-lite',
    this.geminiKeyIndex = 0,
    this.instagramAccessToken = '',
    this.instagramUserId = '',
    this.instagramAppSecret = '',
    this.cloudinaryCloudName = '',
    this.cloudinaryApiKey = '',
    this.cloudinaryApiSecret = '',
    this.youtubeClientId = '',
    this.youtubeClientSecret = '',
    this.youtubeJsonPath = '',
    this.wmPath = '',
    this.wmScale = 1.0,
    this.wmX = 50.0,
    this.wmY = 50.0,
    this.aiOutputLanguage = 'english',
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      geminiApiKeys: (json['gemini_api_keys'] as List?)?.map((e) => e.toString()).toList() ?? [],
      geminiModel: json['gemini_model']?.toString() ?? 'gemini-2.0-flash-lite',
      geminiKeyIndex: (json['gemini_key_index'] as num?)?.toInt() ?? 0,
      instagramAccessToken: json['instagram_access_token']?.toString() ?? '',
      instagramUserId: json['instagram_user_id']?.toString() ?? '',
      instagramAppSecret: json['instagram_app_secret']?.toString() ?? '',
      cloudinaryCloudName: json['cloudinary_cloud_name']?.toString() ?? '',
      cloudinaryApiKey: json['cloudinary_api_key']?.toString() ?? '',
      cloudinaryApiSecret: json['cloudinary_api_secret']?.toString() ?? '',
      youtubeClientId: json['youtube_client_id']?.toString() ?? '',
      youtubeClientSecret: json['youtube_client_secret']?.toString() ?? '',
      youtubeJsonPath: json['youtube_json_path']?.toString() ?? '',
      wmPath: json['wm_path']?.toString() ?? '',
      wmScale: (json['wm_scale'] as num?)?.toDouble() ?? 1.0,
      wmX: (json['wm_x'] as num?)?.toDouble() ?? 50.0,
      wmY: (json['wm_y'] as num?)?.toDouble() ?? 50.0,
      aiOutputLanguage: json['ai_output_language']?.toString() ?? 'english',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gemini_api_keys': geminiApiKeys,
      'gemini_model': geminiModel,
      'gemini_key_index': geminiKeyIndex,
      'instagram_access_token': instagramAccessToken,
      'instagram_user_id': instagramUserId,
      'instagram_app_secret': instagramAppSecret,
      'cloudinary_cloud_name': cloudinaryCloudName,
      'cloudinary_api_key': cloudinaryApiKey,
      'cloudinary_api_secret': cloudinaryApiSecret,
      'youtube_client_id': youtubeClientId,
      'youtube_client_secret': youtubeClientSecret,
      'youtube_json_path': youtubeJsonPath,
      'wm_path': wmPath,
      'wm_scale': wmScale,
      'wm_x': wmX,
      'wm_y': wmY,
      'ai_output_language': aiOutputLanguage,
    };
  }

  bool get isGeminiConfigured => geminiApiKeys.isNotEmpty;
  bool get isInstagramConfigured =>
      instagramAccessToken.isNotEmpty && instagramUserId.isNotEmpty && instagramAppSecret.isNotEmpty;
  bool get isCloudinaryConfigured =>
      cloudinaryCloudName.isNotEmpty && cloudinaryApiKey.isNotEmpty && cloudinaryApiSecret.isNotEmpty;
  bool get isYoutubeConfigured => youtubeClientId.isNotEmpty && youtubeClientSecret.isNotEmpty;

  static List<String> normalizeApiKeys(String raw) {
    return raw
        .replaceAll(',', '\n')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}