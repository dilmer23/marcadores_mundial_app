import 'package:marcadores_mundial_app/domain/repositories/banner_repository.dart';

class DeleteBanner {
  final BannerRepository repository;
  DeleteBanner(this.repository);

  Future<void> call(int id) => repository.deleteBanner(id);
}
