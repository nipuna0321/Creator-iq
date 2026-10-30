import '../models/social_post.dart';

/// Abstract contract for storing and querying SocialPost objects.
abstract interface class PostRepository {
  Future<List<SocialPost>> getAllPosts();
  Future<void> savePosts(List<SocialPost> posts);
  Future<void> addPost(SocialPost post);
  Future<void> deletePost(String id);
  Future<void> clearAll();
}

/// Robust In-Memory implementation of PostRepository for immediate, reactive offline frontend usage.
class InMemoryPostRepository implements PostRepository {
  final List<SocialPost> _posts = [];

  InMemoryPostRepository([List<SocialPost>? initialPosts]) {
    if (initialPosts != null) {
      _posts.addAll(initialPosts);
    }
  }

  @override
  Future<List<SocialPost>> getAllPosts() async {
    // Return a defensive unmodifiable or cloned copy
    return List.unmodifiable(_posts);
  }

  @override
  Future<void> savePosts(List<SocialPost> posts) async {
    for (final post in posts) {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index >= 0) {
        _posts[index] = post;
      } else {
        _posts.add(post);
      }
    }
  }

  @override
  Future<void> addPost(SocialPost post) async {
    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index >= 0) {
      _posts[index] = post;
    } else {
      _posts.insert(0, post);
    }
  }

  @override
  Future<void> deletePost(String id) async {
    _posts.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> clearAll() async {
    _posts.clear();
  }
}

