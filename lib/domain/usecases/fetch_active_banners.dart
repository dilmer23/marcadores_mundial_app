import 'package:marcadores_mundial_app/domain/entities/banner.dart';
import 'package:marcadores_mundial_app/domain/repositories/banner_repository.dart';

class FetchActiveBanners {
  final BannerRepository repository;
  FetchActiveBanners(this.repository);

  Future<List<BannerAd>> call() => repository.fetchActiveBanners();
}
