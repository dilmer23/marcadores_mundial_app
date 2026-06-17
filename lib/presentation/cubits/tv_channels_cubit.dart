import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/domain/entities/channel.dart';
import 'package:marcadores_mundial_app/domain/usecases/fetch_active_channels.dart';

class TvChannelsState {
  final bool isLoading;
  final List<Channel> channels;
  final String? error;

  const TvChannelsState({
    this.isLoading = false,
    this.channels = const [],
    this.error,
  });

  TvChannelsState copyWith({
    bool? isLoading,
    List<Channel>? channels,
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
  final FetchActiveChannels _fetchActiveChannels;

  TvChannelsCubit(this._fetchActiveChannels) : super(const TvChannelsState());

  void loadChannels() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final channels = await _fetchActiveChannels();
      emit(state.copyWith(isLoading: false, channels: channels));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
