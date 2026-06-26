import 'package:marcadores_mundial_app/domain/entities/notification_payload.dart';

class NotificationPayloadModel {
  static Map<String, dynamic> toJson(NotificationPayload payload) {
    final target = <String, dynamic>{'type': payload.targetType};
    if (payload.userId != null) target['userId'] = payload.userId;
    if (payload.minAge != null) target['minAge'] = payload.minAge;
    if (payload.maxAge != null) target['maxAge'] = payload.maxAge;

    return {
      'title': payload.title,
      'body': payload.body,
      'data': payload.data,
      'target': target,
    };
  }
}
