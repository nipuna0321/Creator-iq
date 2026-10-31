/// Supabase project configuration.
///
/// Can be overridden at build time using:
/// `--dart-define=SUPABASE_URL=https://...`
/// `--dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...`
///
/// Note: Only the public publishable key is stored here. Never include
/// a Supabase service-role secret key in the client application.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://gbxanootobmhecidjvke.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_BdKpq7YvhTA6h2sGUnDGsA_DiTFD6NG',
    ),
  );

  /// Convenient alias for compatibility.
  static String get anonKey => publishableKey;

  /// Returns true if the client has a non-empty URL and key configured.
  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
