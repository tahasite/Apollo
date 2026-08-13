import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/project_model.dart';

class ProjectService {
  static ProjectService? _instance;
  static ProjectService get instance => _instance ??= ProjectService._();
  ProjectService._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'apollo_projects.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          create table projects (
            video_path text primary key,
            project_dir text not null,
            mask_path text not null,
            output_path text not null,
            note_text text default '',
            identified_topic text default '',
            ai_instagram_caption text default '',
            ai_instagram_hashtags text default '',
            ai_youtube_title text default '',
            ai_youtube_description text default '',
            ai_youtube_hashtags text default '',
            wm_path text default '',
            wm_scale real default 1.0,
            wm_x real default 50.0,
            wm_y real default 50.0,
            status text default 'video_selected',
            updated_at text not null
          )
        ''');
      },
    );
    return _db!;
  }

  Future<Map<String, String>> buildPaths(String videoPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final videoName = p.basenameWithoutExtension(videoPath);
    final projectDir = p.join(dir.path, 'projects', '${videoName}_project');
    return {
      'project_dir': projectDir,
      'mask_path': p.join(projectDir, 'mask.png'),
      'output_path': p.join(projectDir, 'final_export.mp4'),
    };
  }

  Future<ProjectModel> createDefault(String videoPath) async {
    final paths = await buildPaths(videoPath);
    final dir = Directory(paths['project_dir']!);
    if (!await dir.exists()) await dir.create(recursive: true);
    final project = ProjectModel(
      videoPath: videoPath,
      projectDir: paths['project_dir']!,
      maskPath: paths['mask_path']!,
      outputPath: paths['output_path']!,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await save(project);
    return project;
  }

  Future<void> save(ProjectModel project) async {
    project.updatedAt = DateTime.now().toIso8601String();
    final db = await database;
    await db.insert('projects', project.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<ProjectModel?> loadByVideo(String videoPath) async {
    final db = await database;
    final rows = await db.query('projects', where: 'video_path = ?', whereArgs: [videoPath], limit: 1);
    if (rows.isEmpty) return null;
    return ProjectModel.fromMap(rows.first);
  }

  Future<ProjectModel?> loadLatest() async {
    final db = await database;
    final rows = await db.query('projects', orderBy: 'updated_at desc', limit: 1);
    if (rows.isEmpty) return null;
    final project = ProjectModel.fromMap(rows.first);
    if (!await File(project.videoPath).exists()) return null;
    return project;
  }

  Future<ProjectModel> loadOrCreate(String videoPath) async {
    final existing = await loadByVideo(videoPath);
    if (existing != null) return existing;
    return createDefault(videoPath);
  }

  Future<List<ProjectModel>> loadAll() async {
    final db = await database;
    final rows = await db.query('projects', orderBy: 'updated_at desc');
    return rows.map((r) => ProjectModel.fromMap(r)).toList();
  }

  Future<void> delete(String videoPath) async {
    final db = await database;
    await db.delete('projects', where: 'video_path = ?', whereArgs: [videoPath]);
  }
}