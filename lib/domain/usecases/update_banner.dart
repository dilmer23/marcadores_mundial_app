import 'package:marcadores_mundial_app/domain/entities/banner.dart';
import 'package:marcadores_mundial_app/domain/repositories/banner_repository.dart';

class UpdateBanner {
  final BannerRepository repository;
  UpdateBanner(this.repository);

  Future<BannerAd> call(BannerAd banner) => repository.updateBanner(banner);
}
