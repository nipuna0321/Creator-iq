import 'package:createiq/core/config/supabase_config.dart';
import 'package:createiq/providers/core_providers.dart';
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
  });
}
