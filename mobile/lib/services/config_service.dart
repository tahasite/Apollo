import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/config_model.dart';

class ConfigService {
  static ConfigService? _instance;
  static ConfigService get instance => _instance ??= ConfigService._();
  ConfigService._();

  ConfigModel? _cached;

  Future<String> _configFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'apollo_config.json');
  }

  Future<String> _setupFlagPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, '.setup_complete');
  }

  Future<ConfigModel> load() async {
    if (_cached != null) return _cached!;
    try {
      final file = File(await _configFilePath());
      if (await file.exists()) {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        _cached = ConfigModel.fromJson(json);
      } else {
        _cached = ConfigModel();
      }
    } catch (_) {
      _cached = ConfigModel();
    }
    return _cached!;
  }

  Future<void> save(ConfigModel config) async {
    final file = File(await _configFilePath());
    await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(config.toJson()));
    _cached = config;
  }

  Future<bool> isSetupComplete() async {
    final file = File(await _setupFlagPath());
    return file.exists();
  }

  Future<void> markSetupComplete() async {
    final file = File(await _setupFlagPath());
    await file.writeAsString('1');
  }

  Future<void> resetSetup() async {
    final file = File(await _setupFlagPath());
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Map<String, String>?> parseYoutubeJson(String jsonContent) async {
    try {
      final data = jsonDecode(jsonContent) as Map<String, dynamic>;
      Map<String, dynamic>? clientInfo;
      if (data.containsKey('installed')) {
        clientInfo = data['installed'] as Map<String, dynamic>;
      } else if (data.containsKey('web')) {
        clientInfo = data['web'] as Map<String, dynamic>;
      }
      if (clientInfo == null) return null;
      return {
        'client_id': clientInfo['client_id']?.toString() ?? '',
        'client_secret': clientInfo['client_secret']?.toString() ?? '',
      };
    } catch (_) {
      return null;
    }
  }
}
