import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/core_providers.dart';
import 'providers/settings_provider.dart';
import 'services/storage_service.dart';
import 'services/supabase_service.dart';

/// Entry point: initialise local storage & Supabase, then start the app inside a ProviderScope.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.init();
  await SupabaseService.instance.init();

  runApp(
    ProviderScope(
      overrides: [storageProvider.overrideWithValue(storage)],
      child: const CreateIQApp(),
    ),
  );
}

class CreateIQApp extends ConsumerWidget {
  const CreateIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: appRouter,
      // Clamp system text scaling so large-font settings don't break layouts.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.85,
        maxScaleFactor: 1.25,
        child: child!,
      ),
    );
  }
}
