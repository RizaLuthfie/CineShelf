class CastMember {
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w185';

  final String name;
  final String character;
  final String profileUrl;

  const CastMember({
    required this.name,
    required this.character,
    required this.profileUrl,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    final String? profilePath = json['profile_path'];

    return CastMember(
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profileUrl: profilePath == null ? '' : '$imageBaseUrl$profilePath',
    );
  }
}
