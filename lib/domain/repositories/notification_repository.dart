import 'package:marcadores_mundial_app/domain/entities/notification_payload.dart';
import 'package:marcadores_mundial_app/domain/entities/notification_result.dart';

abstract class NotificationRepository {
  Future<NotificationResult> send(NotificationPayload payload);
}
