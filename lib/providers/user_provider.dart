import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_auth;

import '../core/constants/app_constants.dart';
import '../models/post.dart';
import '../models/social_account.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
import 'core_providers.dart';

/// The signed-in user (null when logged out). Handles Supabase auth, persistent sessions, and account linking.
class UserNotifier extends Notifier<User?> {
  StreamSubscription<supabase_auth.AuthState>? _authSubscription;

  @override
  User? build() {
    final supabase = ref.watch(supabaseServiceProvider);

    // Clean up subscription when provider is disposed
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    // 1. Listen to Supabase authStateChanges for live authentication updates
    if (supabase.isInitialized) {
      _authSubscription?.cancel();
      _authSubscription = supabase.authStateChanges?.listen((data) {
        final session = data.session;
        final authUser = session?.user;
        if (authUser == null) {
          if (state != null) {
            state = null;
            ref.read(storageProvider).setBool(AppConstants.kLoggedIn, false);
            ref.read(storageProvider).remove(AppConstants.kUser);
          }
        } else {
          _syncUserFromAuth(authUser);
        }
      });
    }

    // 2. Preserve session from active Supabase user
    if (supabase.isInitialized && supabase.currentAuthUser != null) {
      final authUser = supabase.currentAuthUser!;
      final cachedJson = ref.read(storageProvider).getJson(AppConstants.kUser);
      final cached = cachedJson == null ? null : User.fromJson(cachedJson);

      // Async refresh profile safely (if profiles table exists)
      Future.microtask(() async {
        final profile = await supabase.fetchProfileSafely(authUser.id);
        if (profile != null && ref.mounted) {
          _save(profile);
        }
      });

      if (cached != null && cached.id == authUser.id) {
        return cached;
      }

      final name = (authUser.userMetadata?['name'] as String?) ??
          (authUser.email?.contains('@') == true ? authUser.email!.split('@').first : 'Creator');

      return User(
        id: authUser.id,
        name: name,
        email: authUser.email ?? '',
      );
    }

    // 3. Fallback to cached user in local storage
    final storage = ref.read(storageProvider);
    if (!storage.getBool(AppConstants.kLoggedIn)) return null;
    final json = storage.getJson(AppConstants.kUser);
    return json == null ? null : User.fromJson(json);
  }

  Future<void> _save(User user) async {
    state = user;
    final storage = ref.read(storageProvider);
    await storage.setJson(AppConstants.kUser, user.toJson());
    await storage.setBool(AppConstants.kLoggedIn, true);
  }

  Future<void> _syncUserFromAuth(supabase_auth.User authUser) async {
    final supabase = ref.read(supabaseServiceProvider);
    final profile = await supabase.fetchProfileSafely(authUser.id);
    if (profile != null) {
      await _save(profile);
      return;
    }
    final name = (authUser.userMetadata?['name'] as String?) ??
        (authUser.email?.contains('@') == true ? authUser.email!.split('@').first : 'Creator');
    final freshUser = User(
      id: authUser.id,
      name: name,
      email: authUser.email ?? '',
    );
    await _save(_mergeStored(freshUser));
  }

  /// Keeps account links from a previous session on this device, if any.
  User _mergeStored(User fresh) {
    final stored = ref.read(storageProvider).getJson(AppConstants.kUser);
    if (stored == null) return fresh;
    final old = User.fromJson(stored);
    return old.email == fresh.email ? old : fresh;
  }

  Future<void> login(String email, String password) async {
    final user = await ref.read(apiServiceProvider).login(email, password);
    await _save(_mergeStored(user));
  }

  Future<SignUpResult> signUp(String name, String email, String password) async {
    final result = await ref.read(apiServiceProvider).signUp(name, email, password);
    if (result.user != null && !result.requiresEmailConfirmation) {
      await _save(result.user!);
    }
    return result;
  }

  Future<void> signInWithGoogle() async {
    final user = await ref.read(apiServiceProvider).signInWithGoogle();
    await _save(_mergeStored(user));
  }

  Future<void> logout() async {
    state = null;
    await ref.read(apiServiceProvider).logout();
    await ref.read(storageProvider).setBool(AppConstants.kLoggedIn, false);
    await ref.read(storageProvider).remove(AppConstants.kUser);
  }

  Future<void> updateProfile({String? name, String? niche, String? bio}) async {
    final u = state;
    if (u == null) return;
    final updated = u.copyWith(name: name, niche: niche, bio: bio);
    await _save(updated);
    final supabase = ref.read(supabaseServiceProvider);
    if (supabase.isInitialized) {
      await supabase.upsertProfileSafely(updated);
    }
  }

  /// Runs the (mock) OAuth flow and marks the platform as connected.
  Future<void> connect(SocialPlatform platform) async {
    final account = await ref.read(apiServiceProvider).connectAccount(platform);
    _replaceAccount(account);
  }

  void disconnect(SocialPlatform platform) {
    final u = state;
    if (u == null) return;
    _replaceAccount(u.accountFor(platform).copyWith(connected: false));
  }

  void _replaceAccount(SocialAccount account) {
    final u = state;
    if (u == null) return;
    final accounts = [
      for (final p in SocialPlatform.values)
        p == account.platform ? account : u.accountFor(p),
    ];
    _save(u.copyWith(accounts: accounts));
    final supabase = ref.read(supabaseServiceProvider);
    if (supabase.isInitialized) {
      supabase.upsertProfileSafely(u.copyWith(accounts: accounts));
    }
  }
}

final userProvider = NotifierProvider<UserNotifier, User?>(UserNotifier.new);

/// Stable string key of connected platforms, e.g. "instagram,tiktok".
final connectedPlatformsKeyProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return '';
  return user.connectedAccounts.map((a) => a.platform.name).join(',');
});
