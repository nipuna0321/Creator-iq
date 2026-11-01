import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import 'core_providers.dart';

/// Light / dark / system theme, persisted across launches.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.read(storageProvider).getString(AppConstants.kThemeMode);
    return ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.light);
  }

  void setDark(bool dark) {
    state = dark ? ThemeMode.dark : ThemeMode.light;
    ref.read(storageProvider).setString(AppConstants.kThemeMode, state.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Push-notification preference (UI only for now).
class NotificationsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(storageProvider).getBool(AppConstants.kNotifications, fallback: true);

  void set(bool value) {
    state = value;
    ref.read(storageProvider).setBool(AppConstants.kNotifications, value);
  }
}

final notificationsProvider = NotifierProvider<NotificationsNotifier, bool>(NotificationsNotifier.new);

/// Display language preference (UI only for now).
class LanguageNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.read(storageProvider).getString(AppConstants.kLanguage) ?? AppConstants.languages.first;

  void set(String value) {
    state = value;
    ref.read(storageProvider).setString(AppConstants.kLanguage, value);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);
