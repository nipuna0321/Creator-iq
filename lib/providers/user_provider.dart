import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../models/post.dart';
import '../models/social_account.dart';
import '../models/user.dart';
import 'core_providers.dart';

/// The signed-in user (null when logged out). Handles mock auth and account linking.
class UserNotifier extends Notifier<User?> {
  @override
  User? build() {
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

  Future<void> signUp(String name, String email, String password) async {
    final user = await ref.read(apiServiceProvider).signUp(name, email, password);
    await _save(user);
  }

  Future<void> signInWithGoogle() async {
    final user = await ref.read(apiServiceProvider).signInWithGoogle();
    await _save(_mergeStored(user));
  }

  Future<void> logout() async {
    state = null;
    await ref.read(storageProvider).setBool(AppConstants.kLoggedIn, false);
  }

  Future<void> updateProfile({String? name, String? niche, String? bio}) async {
    final u = state;
    if (u == null) return;
    await _save(u.copyWith(name: name, niche: niche, bio: bio));
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
  }
}

final userProvider = NotifierProvider<UserNotifier, User?>(UserNotifier.new);

/// Stable string key of connected platforms, e.g. "instagram,tiktok".
///
/// Being a String, it only notifies listeners when the set actually changes,
/// so editing the profile name doesn't trigger a posts re-fetch.
final connectedPlatformsKeyProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return '';
  return user.connectedAccounts.map((a) => a.platform.name).join(',');
});
