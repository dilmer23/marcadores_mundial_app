class NotificationPayload {
  final String title;
  final String body;
  final Map<String, String> data;
  final String targetType; // 'all', 'age_range', 'user'
  final String? userId;
  final int? minAge;
  final int? maxAge;

  const NotificationPayload({
    required this.title,
    required this.body,
    this.data = const {},
    required this.targetType,
    this.userId,
    this.minAge,
    this.maxAge,
  });
}
