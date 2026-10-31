import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';

/// Local storage; overridden in `main()` with an initialised instance.
final storageProvider = Provider<StorageService>(
  (ref) => throw UnimplementedError('storageProvider must be overridden in main()'),
);

/// Supabase Service provider for dependency injection.
final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService.instance);

/// Exposes the initialized SupabaseClient for future Auth, Database, Storage, and AI modules.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return service.isInitialized ? service.client : null;
});

/// Backend gateway.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
