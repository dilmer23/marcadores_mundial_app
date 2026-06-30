import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:marcadores_mundial_app/core/errors/exceptions.dart';
import 'package:marcadores_mundial_app/data/models/notification_payload_model.dart';
import 'package:marcadores_mundial_app/domain/entities/notification_payload.dart';
import 'package:marcadores_mundial_app/domain/entities/notification_result.dart';
import 'package:marcadores_mundial_app/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClient _client;

  NotificationRepositoryImpl(this._client);

  @override
  Future<NotificationResult> send(NotificationPayload payload) async {
    try {
      final body = NotificationPayloadModel.toJson(payload);
      final res = await _client.functions.invoke('send-notification', body: body);
      final data = res.data is String ? jsonDecode(res.data as String) as Map<String, dynamic>? : res.data as Map<String, dynamic>?;
      if (data == null) throw const ServerException('Respuesta vacía');

      return NotificationResult(
        sent: data['sent'] as int? ?? 0,
        failed: data['failed'] as int? ?? 0,
        cleaned: data['cleaned'] as int? ?? 0,
      );
    } catch (e) {
      return NotificationResult(
        sent: 0,
        failed: 0,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
