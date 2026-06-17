import 'package:marcadores_mundial_app/domain/entities/banner.dart';
import 'package:marcadores_mundial_app/domain/repositories/banner_repository.dart';

class FetchAllBanners {
  final BannerRepository repository;
  FetchAllBanners(this.repository);

  Future<List<BannerAd>> call() => repository.fetchAllBanners();
}
