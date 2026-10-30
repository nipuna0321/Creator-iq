import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'views/main_navigation_view.dart';

class CreatorIqApp extends StatelessWidget {
  const CreatorIqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CreatorIQ - Social Media Intelligence',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationView(),
    );
  }
}

