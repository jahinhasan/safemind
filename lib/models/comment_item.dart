class SafeMindComment {
  const SafeMindComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.highlighted,
  });

  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String content;
  final DateTime createdAt;
  final int likes;
  final bool highlighted;

  SafeMindComment copyWith({
    String? authorId,
    String? authorName,
    String? authorRole,
    String? content,
    DateTime? createdAt,
    int? likes,
    bool? highlighted,
  }) {
    return SafeMindComment(
      id: id,
      postId: postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      highlighted: highlighted ?? this.highlighted,
    );
  }
}