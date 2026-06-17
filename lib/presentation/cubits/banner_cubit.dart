import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/domain/entities/banner.dart';
import 'package:marcadores_mundial_app/domain/usecases/fetch_active_banners.dart';

class BannerState {
  final bool isLoading;
  final List<BannerAd> banners;
  final String? error;

  const BannerState({
    this.isLoading = false,
    this.banners = const [],
    this.error,
  });

  BannerState copyWith({
    bool? isLoading,
    List<BannerAd>? banners,
    String? error,
  }) {
    return BannerState(
      isLoading: isLoading ?? this.isLoading,
      banners: banners ?? this.banners,
      error: error,
    );
  }
}

class BannerCubit extends Cubit<BannerState> {
  final FetchActiveBanners _fetchActiveBanners;

  BannerCubit(this._fetchActiveBanners) : super(const BannerState());

  void loadBanners() async {
    if (state.banners.isNotEmpty) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final banners = await _fetchActiveBanners();
      emit(state.copyWith(isLoading: false, banners: banners));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
