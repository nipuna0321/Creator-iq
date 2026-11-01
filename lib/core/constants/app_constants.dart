/// App-wide constants: spacing, radii, storage keys and option lists.
class AppConstants {
  AppConstants._();

  static const String appName = 'CreateIQ';

  // --- Layout ---
  static const double radius = 20;
  static const double radiusSmall = 14;
  static const double gutter = 20;
  static const double gap = 16;

  /// Phones narrower than this get tighter spacing.
  static const double smallPhoneWidth = 360;

  // --- Mock network latency for AI calls ---
  static const Duration aiDelay = Duration(milliseconds: 1500);

  // --- shared_preferences keys ---
  static const String kThemeMode = 'theme_mode';
  static const String kOnboarded = 'onboarded';
  static const String kLoggedIn = 'logged_in';
  static const String kUser = 'user';
  static const String kPosts = 'manual_posts';
  static const String kQuestionnaire = 'questionnaire';
  static const String kNotifications = 'notifications';
  static const String kLanguage = 'language';
  static const String kSavedIdeas = 'saved_ideas';

  // --- Option lists ---
  static const List<String> niches = [
    'Fitness',
    'Tech',
    'Food',
    'Travel',
    'Fashion',
    'Education',
    'Other',
  ];

  static const List<String> goals = [
    'Grow followers',
    'More engagement',
    'Sales',
    'Brand awareness',
  ];

  static const List<String> ageRanges = ['13–17', '18–24', '25–34', '35–44', '45+'];

  static const List<String> languages = ['English', 'Español', 'Français', 'Deutsch', 'සිංහල'];

  static const List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// Time-of-day buckets used by the best-time heatmap (start hour, label).
  static const List<(int, String)> timeSlots = [
    (6, '6a'),
    (9, '9a'),
    (12, '12p'),
    (15, '3p'),
    (18, '6p'),
    (21, '9p'),
  ];
}
