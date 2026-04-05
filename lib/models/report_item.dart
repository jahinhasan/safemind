class SafeMindReport {
  const SafeMindReport({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.targetAuthorId,
    required this.targetAuthorName,
    required this.reason,
    required this.reporterName,
    required this.createdAt,
    this.status = 'open',
    this.severity = 'medium',
  });

  final String id;
  final String targetType;
  final String targetId;
  final String? targetAuthorId;
  final String? targetAuthorName;
  final String reason;
  final String reporterName;
  final DateTime createdAt;
  final String status;
  final String severity;
}