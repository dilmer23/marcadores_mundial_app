import 'package:marcadores_mundial_app/domain/entities/banner.dart';

abstract class BannerRepository {
  Future<List<BannerAd>> fetchActiveBanners();
  Future<List<BannerAd>> fetchAllBanners();
  Future<BannerAd> createBanner(BannerAd banner);
  Future<BannerAd> updateBanner(BannerAd banner);
  Future<void> deleteBanner(int id);
  Future<String> uploadImage(List<int> bytes, String fileName);
}
