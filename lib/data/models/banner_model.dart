import 'package:marcadores_mundial_app/domain/entities/banner.dart';

class BannerModel {
  final int id;
  final String imageUrl;
  final String? linkUrl;
  final String? title;
  final bool isActive;
  final int displayOrder;
  final String? createdBy;

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
    this.title,
    required this.isActive,
    this.displayOrder = 0,
    this.createdBy,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      linkUrl: json['link_url'] as String?,
      title: json['title'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      displayOrder: json['display_order'] as int? ?? 0,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'image_url': imageUrl,
        'link_url': linkUrl,
        'title': title,
        'is_active': isActive,
        'display_order': displayOrder,
        if (createdBy != null) 'created_by': createdBy,
      };

  BannerAd toEntity() => BannerAd(
        id: id,
        imageUrl: imageUrl,
        linkUrl: linkUrl,
        title: title,
        isActive: isActive,
        displayOrder: displayOrder,
        createdBy: createdBy,
      );
}
