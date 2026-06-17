class BannerAd {
  final int id;
  final String imageUrl;
  final String? linkUrl;
  final String? title;
  final bool isActive;
  final int displayOrder;
  final String? createdBy;

  const BannerAd({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
    this.title,
    required this.isActive,
    this.displayOrder = 0,
    this.createdBy,
  });
}
