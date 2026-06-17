import 'package:marcadores_mundial_app/domain/entities/banner.dart';
import 'package:marcadores_mundial_app/domain/repositories/banner_repository.dart';

class CreateBanner {
  final BannerRepository repository;
  CreateBanner(this.repository);

  Future<BannerAd> call(BannerAd banner) => repository.createBanner(banner);
}
