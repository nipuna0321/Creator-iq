import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../models/social_account.dart';
import '../models/user.dart' as model;

/// Result of an authentication registration attempt.
class SignUpResult {
  const SignUpResult({
    required this.requiresEmailConfirmation,
    this.email,
    this.user,
  });

  /// True if Supabase requires the user to click an email confirmation link.
  final bool requiresEmailConfirmation;
  final String? email;
  final model.User? user;
}

/// Reusable Supabase service and client manager.
///
/// Follows CreateIQ's singleton service pattern while being exposed
/// through Riverpod providers for dependency injection.
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
      if (Supabase.instance.isInitialized) {
        _initialized = true;
        return;
      }
    } catch (_) {}

    try {
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

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  User? get currentAuthUser => _initialized ? client.auth.currentUser : null;
  Session? get currentSession => _initialized ? client.auth.currentSession : null;
  Stream<AuthState>? get authStateChanges => _initialized ? client.auth.onAuthStateChange : null;

  /// Register a new user with email and password.
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final res = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    final authUser = res.user;
    if (authUser == null) {
      throw const AuthException('Registration failed. Please try again.');
    }

    // If session is null, email confirmation is required by the project.
    final requiresConfirmation = res.session == null;

    final createdUser = model.User(
      id: authUser.id,
      name: name,
      email: email,
    );

    // If session is active immediately, safely attempt profile creation if table exists
    if (!requiresConfirmation) {
      await upsertProfileSafely(createdUser);
    }

    return SignUpResult(
      requiresEmailConfirmation: requiresConfirmation,
      email: email,
      user: createdUser,
    );
  }

  /// Log in with email and password.
  Future<model.User> signIn({
    required String email,
    required String password,
  }) async {
    final res = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final authUser = res.user;
    if (authUser == null) {
      throw const AuthException('Could not sign in with provided credentials.');
    }

    // Safely retrieve profile if table exists, or fallback to auth metadata
    final existingProfile = await fetchProfileSafely(authUser.id);
    if (existingProfile != null) {
      return existingProfile;
    }

    final name = (authUser.userMetadata?['name'] as String?) ??
        (email.contains('@') ? email.split('@').first : 'Creator');

    return model.User(
      id: authUser.id,
      name: name,
      email: email,
    );
  }

  /// Log out from Supabase Auth session.
  Future<void> signOut() async {
    if (_initialized) {
      await client.auth.signOut();
    }
  }

  /// Send password reset link to user's email.
  Future<void> sendPasswordReset(String email) async {
    if (_initialized) {
      await client.auth.resetPasswordForEmail(email);
    }
  }

  // ---------------------------------------------------------------------------
  // Profile Management (Safely handles case where table does not exist)
  // ---------------------------------------------------------------------------

  /// Attempts to fetch profile from `profiles` table safely.
  /// Returns null if table does not exist or user has no profile row.
  Future<model.User?> fetchProfileSafely(String userId) async {
    if (!_initialized) return null;

    try {
      final res = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (res == null) return null;

      final accountsJson = res['connected_accounts'] as List<dynamic>? ?? [];
      final accounts = accountsJson
          .map((a) => SocialAccount.fromJson(a as Map<String, dynamic>))
          .toList();

      return model.User(
        id: res['id'] as String,
        name: res['name'] as String? ?? 'Creator',
        email: res['email'] as String? ?? '',
        niche: res['niche'] as String? ?? 'Other',
        bio: res['bio'] as String? ?? '',
        accounts: accounts,
      );
    } catch (e) {
      // Gracefully ignore if profiles table doesn't exist yet
      if (kDebugMode) {
        debugPrint('[SupabaseService] Note: profiles query skipped: $e');
      }
      return null;
    }
  }

  /// Safely attempts to upsert profile into `profiles` table if present,
  /// and updates Auth user metadata.
  Future<void> upsertProfileSafely(model.User user) async {
    if (!_initialized) return;

    // 1. Update Supabase Auth user metadata
    try {
      await client.auth.updateUser(
        UserAttributes(data: {
          'name': user.name,
          'niche': user.niche,
          'bio': user.bio,
        }),
      );
    } catch (_) {}

    // 2. Update `profiles` table if it exists
    try {
      await client.from('profiles').upsert({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'niche': user.niche,
        'bio': user.bio,
        'connected_accounts': user.accounts.map((a) => a.toJson()).toList(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SupabaseService] Note: profiles table upsert skipped: $e');
      }
    }
  }
}
