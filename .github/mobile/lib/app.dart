import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

class ApolloApp extends StatelessWidget {
  const ApolloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apollo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}