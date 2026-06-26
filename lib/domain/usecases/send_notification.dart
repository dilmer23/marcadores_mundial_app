import 'package:marcadores_mundial_app/domain/entities/notification_payload.dart';
import 'package:marcadores_mundial_app/domain/entities/notification_result.dart';
import 'package:marcadores_mundial_app/domain/repositories/notification_repository.dart';

class SendNotification {
  final NotificationRepository repository;
  SendNotification(this.repository);

  Future<NotificationResult> call(NotificationPayload payload) =>
      repository.send(payload);
}
