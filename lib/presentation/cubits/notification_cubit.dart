import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/domain/entities/notification_payload.dart';
import 'package:marcadores_mundial_app/domain/entities/notification_result.dart';
import 'package:marcadores_mundial_app/domain/usecases/send_notification.dart';

class NotificationState {
  final bool isLoading;
  final NotificationResult? result;
  final String? errorMessage;

  const NotificationState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  NotificationState copyWith({
    bool? isLoading,
    NotificationResult? result,
    String? errorMessage,
    bool clearResult = false,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearResult ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class NotificationCubit extends Cubit<NotificationState> {
  final SendNotification _sendNotification;

  NotificationCubit(this._sendNotification) : super(const NotificationState());

  Future<void> send(NotificationPayload payload) async {
    emit(state.copyWith(isLoading: true, clearResult: true));
    final result = await _sendNotification(payload);
    emit(state.copyWith(
      isLoading: false,
      result: result,
      errorMessage: result.error,
    ));
  }

  void clearResult() => emit(state.copyWith(clearResult: true));
}
