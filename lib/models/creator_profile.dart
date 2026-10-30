class CreatorProfile {
  final String id;
  final String name;
  final String handle;
  final String avatarUrl;
  final String primaryNiche;
  final int totalFollowers;

  const CreatorProfile({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.primaryNiche,
    required this.totalFollowers,
  });

  static const CreatorProfile defaultCreator = CreatorProfile(
    id: 'creator_01',
    name: 'Sarah Jenkins',
    handle: '@sarahcreates',
    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
    primaryNiche: 'Tech & Video Production',
    totalFollowers: 142500,
  );
}

