class SafeMindUser {
  const SafeMindUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isAnonymous,
    this.isBanned = false,
    this.postCount = 0,
    this.joinedAt,
    this.moderationState = 'active',
  });

  final String id;
  final String name;
  final String? email;
  final String role;
  final bool isAnonymous;
  final bool isBanned;
  final int postCount;
  final DateTime? joinedAt;
  final String moderationState;

  SafeMindUser copyWith({String? name, String? email, String? role, bool? isAnonymous, bool? isBanned, int? postCount, DateTime? joinedAt, String? moderationState}) {
    return SafeMindUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isBanned: isBanned ?? this.isBanned,
      postCount: postCount ?? this.postCount,
      joinedAt: joinedAt ?? this.joinedAt,
      moderationState: moderationState ?? this.moderationState,
    );
  }
}