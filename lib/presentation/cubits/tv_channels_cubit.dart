import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/data/models/channel_model.dart';
import 'package:marcadores_mundial_app/data/services/supabase_service.dart';

class TvChannelsState {
  final bool isLoading;
  final List<ChannelModel> channels;
  final String? error;

  const TvChannelsState({
    this.isLoading = false,
    this.channels = const [],
    this.error,
  });

  TvChannelsState copyWith({
    bool? isLoading,
    List<ChannelModel>? channels,
    String? error,
  }) {
    return TvChannelsState(
      isLoading: isLoading ?? this.isLoading,
      channels: channels ?? this.channels,
      error: error,
    );
  }
}

class TvChannelsCubit extends Cubit<TvChannelsState> {
  final SupabaseService _service;

  TvChannelsCubit(this._service) : super(const TvChannelsState());

  void loadChannels() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final channels = await _service.fetchActiveChannels();
      emit(state.copyWith(isLoading: false, channels: channels));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
