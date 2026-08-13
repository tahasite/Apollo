class ProjectModel {
  String videoPath;
  String projectDir;
  String maskPath;
  String outputPath;
  String noteText;
  String identifiedTopic;
  String aiInstagramCaption;
  String aiInstagramHashtags;
  String aiYoutubeTitle;
  String aiYoutubeDescription;
  String aiYoutubeHashtags;
  String wmPath;
  double wmScale;
  double wmX;
  double wmY;
  String status;
  String updatedAt;

  ProjectModel({
    required this.videoPath,
    required this.projectDir,
    required this.maskPath,
    required this.outputPath,
    this.noteText = '',
    this.identifiedTopic = '',
    this.aiInstagramCaption = '',
    this.aiInstagramHashtags = '',
    this.aiYoutubeTitle = '',
    this.aiYoutubeDescription = '',
    this.aiYoutubeHashtags = '',
    this.wmPath = '',
    this.wmScale = 1.0,
    this.wmX = 50.0,
    this.wmY = 50.0,
    this.status = 'video_selected',
    this.updatedAt = '',
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      videoPath: map['video_path']?.toString() ?? '',
      projectDir: map['project_dir']?.toString() ?? '',
      maskPath: map['mask_path']?.toString() ?? '',
      outputPath: map['output_path']?.toString() ?? '',
      noteText: map['note_text']?.toString() ?? '',
      identifiedTopic: map['identified_topic']?.toString() ?? '',
      aiInstagramCaption: map['ai_instagram_caption']?.toString() ?? '',
      aiInstagramHashtags: map['ai_instagram_hashtags']?.toString() ?? '',
      aiYoutubeTitle: map['ai_youtube_title']?.toString() ?? '',
      aiYoutubeDescription: map['ai_youtube_description']?.toString() ?? '',
      aiYoutubeHashtags: map['ai_youtube_hashtags']?.toString() ?? '',
      wmPath: map['wm_path']?.toString() ?? '',
      wmScale: (map['wm_scale'] as num?)?.toDouble() ?? 1.0,
      wmX: (map['wm_x'] as num?)?.toDouble() ?? 50.0,
      wmY: (map['wm_y'] as num?)?.toDouble() ?? 50.0,
      status: map['status']?.toString() ?? 'video_selected',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'video_path': videoPath,
      'project_dir': projectDir,
      'mask_path': maskPath,
      'output_path': outputPath,
      'note_text': noteText,
      'identified_topic': identifiedTopic,
      'ai_instagram_caption': aiInstagramCaption,
      'ai_instagram_hashtags': aiInstagramHashtags,
      'ai_youtube_title': aiYoutubeTitle,
      'ai_youtube_description': aiYoutubeDescription,
      'ai_youtube_hashtags': aiYoutubeHashtags,
      'wm_path': wmPath,
      'wm_scale': wmScale,
      'wm_x': wmX,
      'wm_y': wmY,
      'status': status,
      'updated_at': updatedAt,
    };
  }
}