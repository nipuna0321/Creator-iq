import 'package:createiq/core/config/supabase_config.dart';
import 'package:createiq/core/constants/app_constants.dart';
import 'package:createiq/models/user.dart';
import 'package:createiq/providers/core_providers.dart';
import 'package:createiq/providers/user_provider.dart';
import 'package:createiq/services/storage_service.dart';
import 'package:createiq/services/supabase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Supabase Configuration Tests', () {
    test('Supabase project URL is configured correctly', () {
      expect(SupabaseConfig.url, 'https://gbxanootobmhecidjvke.supabase.co');
      expect(Uri.parse(SupabaseConfig.url).host, 'gbxanootobmhecidjvke.supabase.co');
    });

    test('Supabase publishable key is configured correctly', () {
      expect(SupabaseConfig.publishableKey, 'sb_publishable_BdKpq7YvhTA6h2sGUnDGsA_DiTFD6NG');
      expect(SupabaseConfig.anonKey, SupabaseConfig.publishableKey);
    });

    test('SupabaseConfig.isConfigured returns true', () {
      expect(SupabaseConfig.isConfigured, isTrue);
    });
  });

  group('Supabase Service & Provider Tests', () {
    test('SupabaseService singleton exists and initializes safely', () async {
      final service = SupabaseService.instance;
      expect(service, isNotNull);

      // Verify init() completes without throwing exceptions
      await service.init();
      expect(service.isInitialized, isTrue);

      // Verify second init() call is idempotent
      await service.init();
      expect(service.isInitialized, isTrue);
    });

    test('Riverpod provides SupabaseService and SupabaseClient', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(supabaseServiceProvider);
      expect(service, equals(SupabaseService.instance));

      final client = container.read(supabaseClientProvider);
      expect(client, isNotNull);
      expect(client!.rest.url, contains('gbxanootobmhecidjvke.supabase.co'));
    });

    test('SignUpResult handles verification requirements correctly', () {
      const pendingResult = SignUpResult(
        requiresEmailConfirmation: true,
        email: 'creator@example.com',
      );
      expect(pendingResult.requiresEmailConfirmation, isTrue);
      expect(pendingResult.email, 'creator@example.com');
      expect(pendingResult.user, isNull);

      final activeResult = SignUpResult(
        requiresEmailConfirmation: false,
        email: 'creator@example.com',
        user: const User(id: '123', name: 'Alex', email: 'creator@example.com'),
      );
      expect(activeResult.requiresEmailConfirmation, isFalse);
      expect(activeResult.user?.name, 'Alex');
    });
  });

  group('User Authentication & Session Persistence Tests', () {
    test('Session restoration preserves user from local storage when offline', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.kLoggedIn: true,
        AppConstants.kUser: '{"id":"usr_mock","name":"Test Creator","email":"test@createiq.app","niche":"Tech","bio":"","accounts":[]}',
      });

      final storage = await StorageService.init();
      final container = ProviderContainer(
        overrides: [storageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      final user = container.read(userProvider);
      expect(user, isNotNull);
      expect(user!.id, 'usr_mock');
      expect(user.name, 'Test Creator');
      expect(user.email, 'test@createiq.app');
    });

    test('Logout clears user and storage session state', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.kLoggedIn: true,
        AppConstants.kUser: '{"id":"usr_mock","name":"Test Creator","email":"test@createiq.app","niche":"Tech","bio":"","accounts":[]}',
      });

      final storage = await StorageService.init();
      final container = ProviderContainer(
        overrides: [storageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      expect(container.read(userProvider), isNotNull);

      await container.read(userProvider.notifier).logout();

      expect(container.read(userProvider), isNull);
      expect(storage.getBool(AppConstants.kLoggedIn), isFalse);
      expect(storage.getJson(AppConstants.kUser), isNull);
    });
  });
}
