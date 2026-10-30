import 'post.dart';

/// A creator's account on one social platform.
class SocialAccount {
  const SocialAccount({
    required this.platform,
    this.handle = '',
    this.followers = 0,
    this.connected = false,
  });

  final SocialPlatform platform;
  final String handle;
  final int followers;
  final bool connected;

  SocialAccount copyWith({String? handle, int? followers, bool? connected}) => SocialAccount(
        platform: platform,
        handle: handle ?? this.handle,
        followers: followers ?? this.followers,
        connected: connected ?? this.connected,
      );

  Map<String, dynamic> toJson() => {
        'platform': platform.name,
        'handle': handle,
        'followers': followers,
        'connected': connected,
      };

  factory SocialAccount.fromJson(Map<String, dynamic> json) => SocialAccount(
        platform: SocialPlatform.fromName(json['platform'] as String),
        handle: json['handle'] as String? ?? '',
        followers: json['followers'] as int? ?? 0,
        connected: json['connected'] as bool? ?? false,
      );
}
