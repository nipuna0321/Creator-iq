import 'post.dart';
import 'social_account.dart';

/// The signed-in creator.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.niche = 'Other',
    this.bio = '',
    this.accounts = const [],
  });

  final String id;
  final String name;
  final String email;
  final String niche;
  final String bio;
  final List<SocialAccount> accounts;

  /// First name, used in greetings.
  String get firstName => name.trim().split(' ').first;

  /// Up to two initials for the avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  List<SocialAccount> get connectedAccounts => accounts.where((a) => a.connected).toList();

  /// Total followers across connected accounts.
  int get totalFollowers => connectedAccounts.fold(0, (sum, a) => sum + a.followers);

  SocialAccount accountFor(SocialPlatform p) =>
      accounts.firstWhere((a) => a.platform == p, orElse: () => SocialAccount(platform: p));

  User copyWith({
    String? name,
    String? email,
    String? niche,
    String? bio,
    List<SocialAccount>? accounts,
  }) =>
      User(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        niche: niche ?? this.niche,
        bio: bio ?? this.bio,
        accounts: accounts ?? this.accounts,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'niche': niche,
        'bio': bio,
        'accounts': accounts.map((a) => a.toJson()).toList(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        niche: json['niche'] as String? ?? 'Other',
        bio: json['bio'] as String? ?? '',
        accounts: (json['accounts'] as List<dynamic>? ?? [])
            .map((a) => SocialAccount.fromJson(a as Map<String, dynamic>))
            .toList(),
      );
}
