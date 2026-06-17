import 'package:marcadores_mundial_app/core/errors/exceptions.dart';
import 'package:marcadores_mundial_app/domain/entities/banner.dart';
import 'package:marcadores_mundial_app/domain/repositories/banner_repository.dart';
import 'package:marcadores_mundial_app/data/models/banner_model.dart';
import 'package:marcadores_mundial_app/data/services/supabase_service.dart';

class BannerRepositoryImpl implements BannerRepository {
  final SupabaseService _supabaseService;

  BannerRepositoryImpl(this._supabaseService);

  @override
  Future<List<BannerAd>> fetchActiveBanners() async {
    try {
      final models = await _supabaseService.fetchActiveBanners();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<BannerAd>> fetchAllBanners() async {
    try {
      final models = await _supabaseService.fetchAllBanners();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<BannerAd> createBanner(BannerAd banner) async {
    try {
      final model = BannerModel(
        id: 0,
        imageUrl: banner.imageUrl,
        linkUrl: banner.linkUrl,
        title: banner.title,
        isActive: banner.isActive,
        displayOrder: banner.displayOrder,
      );
      final created = await _supabaseService.createBanner(model.toJson());
      return created.toEntity();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<BannerAd> updateBanner(BannerAd banner) async {
    try {
      final model = BannerModel(
        id: banner.id,
        imageUrl: banner.imageUrl,
        linkUrl: banner.linkUrl,
        title: banner.title,
        isActive: banner.isActive,
        displayOrder: banner.displayOrder,
      );
      final updated = await _supabaseService.updateBanner(banner.id, model.toJson());
      return updated.toEntity();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<String> uploadImage(List<int> bytes, String fileName) async {
    try {
      return await _supabaseService.uploadBannerImage(bytes, fileName);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteBanner(int id) async {
    try {
      await _supabaseService.deleteBanner(id);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
