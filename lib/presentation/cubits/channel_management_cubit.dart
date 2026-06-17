import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/domain/entities/channel.dart';
import 'package:marcadores_mundial_app/domain/usecases/fetch_all_channels.dart';
import 'package:marcadores_mundial_app/domain/usecases/create_channel.dart';
import 'package:marcadores_mundial_app/domain/usecases/update_channel.dart';
import 'package:marcadores_mundial_app/domain/usecases/delete_channel.dart';

class ChannelManagementState {
  final bool isLoading;
  final List<Channel> channels;
  final String? error;
  final String? success;

  const ChannelManagementState({
    this.isLoading = false,
    this.channels = const [],
    this.error,
    this.success,
  });

  ChannelManagementState copyWith({
    bool? isLoading,
    List<Channel>? channels,
    String? error,
    String? success,
  }) {
    return ChannelManagementState(
      isLoading: isLoading ?? this.isLoading,
      channels: channels ?? this.channels,
      error: error,
      success: success,
    );
  }
}

class ChannelManagementCubit extends Cubit<ChannelManagementState> {
  final FetchAllChannels _fetchAll;
  final CreateChannel _create;
  final UpdateChannel _update;
  final DeleteChannel _delete;

  ChannelManagementCubit(
    this._fetchAll,
    this._create,
    this._update,
    this._delete,
  ) : super(const ChannelManagementState());

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true, error: null, success: null));
    try {
      final channels = await _fetchAll();
      emit(state.copyWith(isLoading: false, channels: channels));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<bool> create(Channel channel) async {
    emit(state.copyWith(isLoading: true, error: null, success: null));
    try {
      await _create(channel);
      await loadAll();
      emit(state.copyWith(success: 'Channel created'));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<bool> update(Channel channel) async {
    emit(state.copyWith(isLoading: true, error: null, success: null));
    try {
      await _update(channel);
      await loadAll();
      emit(state.copyWith(success: 'Channel updated'));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<bool> delete(int id) async {
    emit(state.copyWith(isLoading: true, error: null, success: null));
    try {
      await _delete(id);
      await loadAll();
      emit(state.copyWith(success: 'Channel deleted'));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  void clearMessages() => emit(state.copyWith(error: null, success: null));
}
