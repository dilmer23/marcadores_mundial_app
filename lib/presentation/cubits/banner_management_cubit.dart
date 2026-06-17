import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/domain/entities/banner.dart';
import 'package:marcadores_mundial_app/domain/usecases/fetch_all_banners.dart';
import 'package:marcadores_mundial_app/domain/usecases/create_banner.dart';
import 'package:marcadores_mundial_app/domain/usecases/update_banner.dart';
import 'package:marcadores_mundial_app/domain/usecases/delete_banner.dart';
import 'package:marcadores_mundial_app/domain/usecases/upload_banner_image.dart';
import 'package:marcadores_mundial_app/core/utils/image_compressor.dart';
import 'package:image_picker/image_picker.dart';

class BannerManagementState {
  final bool isLoading;
  final List<BannerAd> banners;
  final String? error;
  final String? success;
  final bool isUploading;
  final int uploadProgress;

  const BannerManagementState({
    this.isLoading = false,
    this.banners = const [],
    this.error,
    this.success,
    this.isUploading = false,
    this.uploadProgress = 0,
  });

  BannerManagementState copyWith({
    bool? isLoading,
    List<BannerAd>? banners,
    String? error,
    String? success,
    bool? isUploading,
    int? uploadProgress,
  }) {
    return BannerManagementState(
      isLoading: isLoading ?? this.isLoading,
      banners: banners ?? this.banners,
      error: error,
      success: success,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

class BannerManagementCubit extends Cubit<BannerManagementState> {
  final FetchAllBanners _fetchAll;
  final CreateBanner _create;
  final UpdateBanner _update;
  final DeleteBanner _delete;
  final UploadBannerImage _uploadBannerImage;

  BannerManagementCubit(
    this._fetchAll,
    this._create,
    this._update,
    this._delete,
    this._uploadBannerImage,
  ) : super(const BannerManagementState());

  Future<String?> uploadImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (picked == null) return null;

    emit(state.copyWith(isUploading: true, uploadProgress: 0));
    try {
      emit(state.copyWith(uploadProgress: 10));

      final rawBytes = await picked.readAsBytes();
      emit(state.copyWith(uploadProgress: 30));

      final compressed = ImageCompressor.compress(Uint8List.fromList(rawBytes));
      final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
      emit(state.copyWith(uploadProgress: 60));

      final url = await _uploadBannerImage(compressed, fileName);
      emit(state.copyWith(isUploading: false, uploadProgress: 100));
      return url;
    } catch (e) {
      emit(state.copyWith(
        isUploading: false,
        uploadProgress: 0,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
      return null;
    }
  }

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true, error: null, success: null));
    try {
      final banners = await _fetchAll();
      emit(state.copyWith(isLoading: false, banners: banners));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<bool> create(BannerAd banner) async {
    emit(state.copyWith(isLoading: true, error: null, success: null));
    try {
      await _create(banner);
      await loadAll();
      emit(state.copyWith(success: 'Banner created'));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    }
  }

  Future<bool> update(BannerAd banner) async {
    emit(state.copyWith(isLoading: true, error: null, success: null));
    try {
      await _update(banner);
      await loadAll();
      emit(state.copyWith(success: 'Banner updated'));
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
      emit(state.copyWith(success: 'Banner deleted'));
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
