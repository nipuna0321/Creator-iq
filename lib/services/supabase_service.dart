import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';

/// Reusable Supabase service and client manager.
///
/// Follows CreateIQ's singleton service pattern while being exposed
/// through Riverpod providers for dependency injection and future modules
/// (Auth, PostgreSQL database, Storage, and Edge Functions).
class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  bool _initialized = false;

  /// Returns true if the Supabase SDK has finished initializing.
  bool get isInitialized => _initialized;

  /// Returns the global SupabaseClient instance.
  SupabaseClient get client {
    if (!_initialized) {
      throw StateError('SupabaseService has not been initialized. Call init() first.');
    }
    return Supabase.instance.client;
  }

  /// Initialise the Supabase Flutter SDK safely, preventing duplicate calls.
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Prevent duplicate initialization if already active
      try {
        if (Supabase.instance.isInitialized) {
          _initialized = true;
          return;
        }
      } catch (_) {}

      // ignore: deprecated_member_use
      await Supabase.initialize(
        url: SupabaseConfig.url,
        // ignore: deprecated_member_use
        anonKey: SupabaseConfig.publishableKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      _initialized = true;

      if (kDebugMode) {
        final host = Uri.tryParse(SupabaseConfig.url)?.host ?? 'unknown-host';
        debugPrint('[Supabase] Successfully initialized for project host: $host');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Supabase] Initialization notice: $e');
      }
      try {
        _initialized = Supabase.instance.isInitialized;
      } catch (_) {}
    }
  }
}
