import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/config_service.dart';
import 'services/project_service.dart';
import 'models/config_model.dart';
import 'models/project_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final config = await ConfigService.instance.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConfigProvider(config)),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: const ApolloApp(),
    ),
  );
}

class ConfigProvider extends ChangeNotifier {
  ConfigModel config;
  ConfigProvider(this.config);

  Future<void> update(ConfigModel newConfig) async {
    config = newConfig;
    await ConfigService.instance.save(config);
    notifyListeners();
  }

  Future<void> save() async {
    await ConfigService.instance.save(config);
    notifyListeners();
  }
}

class ProjectProvider extends ChangeNotifier {
  ProjectModel? current;

  Future<void> loadLatest() async {
    current = await ProjectService.instance.loadLatest();
    notifyListeners();
  }

  Future<void> setProject(ProjectModel project) async {
    current = project;
    await ProjectService.instance.save(project);
    notifyListeners();
  }

  Future<void> save() async {
    if (current != null) {
      await ProjectService.instance.save(current!);
      notifyListeners();
    }
  }

  void updateAndNotify() {
    if (current != null) {
      ProjectService.instance.save(current!);
      notifyListeners();
    }
  }
}