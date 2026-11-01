import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../models/post.dart';
import 'core_providers.dart';
import 'user_provider.dart';

/// All posts: synced posts from connected platforms + manual entries.
///
/// Re-fetches whenever the set of connected platforms changes.
class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final key = ref.watch(connectedPlatformsKeyProvider);
    final connected = key.isEmpty ? <String>{} : key.split(',').toSet();

    final manual = _loadManual();
    if (connected.isEmpty) return _sorted(manual);

    final synced = await ref.read(apiServiceProvider).fetchPosts();
    return _sorted([
      ...synced.where((p) => connected.contains(p.platform.name)),
      ...manual,
    ]);
  }

  List<Post> _loadManual() =>
      ref.read(storageProvider).getJsonList(AppConstants.kPosts).map(Post.fromJson).toList();

  List<Post> _sorted(List<Post> posts) => posts..sort((a, b) => b.date.compareTo(a.date));

  Future<void> _persistManual(List<Post> all) => ref
      .read(storageProvider)
      .setJsonList(AppConstants.kPosts, all.where((p) => p.isManual).map((p) => p.toJson()).toList());

  /// Adds or replaces (by id) a manual post.
  Future<void> upsert(Post post) async {
    final current = state.value ?? [];
    final next = _sorted([
      for (final p in current)
        if (p.id != post.id) p,
      post,
    ]);
    state = AsyncData(next);
    await _persistManual(next);
  }

  Future<void> delete(String id) async {
    final next = [...?state.value]..removeWhere((p) => p.id == id);
    state = AsyncData(next);
    await _persistManual(next);
  }
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

/// Only the posts the user entered by hand, newest first.
final manualPostsProvider = Provider<List<Post>>((ref) {
  final posts = ref.watch(postsProvider).value ?? [];
  return posts.where((p) => p.isManual).toList();
});
