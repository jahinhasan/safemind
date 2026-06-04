class SafeMindAdminActivity {
  const SafeMindAdminActivity({
    required this.id,
    required this.action,
    required this.subject,
    required this.actorName,
    required this.detail,
    required this.createdAt,
    this.kind = 'moderation',
  });

  final String id;
  final String action;
  final String subject;
  final String actorName;
  final String detail;
  final DateTime createdAt;
  final String kind;
}