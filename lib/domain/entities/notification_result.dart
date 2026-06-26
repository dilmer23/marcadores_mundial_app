class NotificationResult {
  final int sent;
  final int failed;
  final int cleaned;
  final String? error;

  const NotificationResult({
    required this.sent,
    required this.failed,
    this.cleaned = 0,
    this.error,
  });

  bool get isSuccess => error == null;
}
