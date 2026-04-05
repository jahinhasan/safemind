class SafeMindPost {
  const SafeMindPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.isAnonymous,
    required this.content,
    required this.category,
    required this.createdAt,
    required this.supportCount,
    required this.commentCount,
    required this.solved,
    required this.bestCommentId,
    required this.hasAdvisorResponse,
    this.authorMood,
  });

  final String id;
  final String authorId;
  final String authorName;
  final bool isAnonymous;
  final String content;
  final String category;
  final DateTime createdAt;
  final int supportCount;
  final int commentCount;
  final bool solved;
  final String? bestCommentId;
  final bool hasAdvisorResponse;
  final int? authorMood;

  SafeMindPost copyWith({
    String? authorId,
    String? authorName,
    bool? isAnonymous,
    String? content,
    String? category,
    DateTime? createdAt,
    int? supportCount,
    int? commentCount,
    bool? solved,
    String? bestCommentId,
    bool? hasAdvisorResponse,
    int? authorMood,
  }) {
    return SafeMindPost(
      id: id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      supportCount: supportCount ?? this.supportCount,
      commentCount: commentCount ?? this.commentCount,
      solved: solved ?? this.solved,
      bestCommentId: bestCommentId ?? this.bestCommentId,
      hasAdvisorResponse: hasAdvisorResponse ?? this.hasAdvisorResponse,
      authorMood: authorMood ?? this.authorMood,
    );
  }
}