import 'package:marcadores_mundial_app/domain/repositories/banner_repository.dart';

class UploadBannerImage {
  final BannerRepository repository;
  UploadBannerImage(this.repository);

  Future<String> call(List<int> bytes, String fileName) =>
      repository.uploadImage(bytes, fileName);
}