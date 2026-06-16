class ChannelModel {
  final int id;
  final String name;
  final String channelUrl;
  final String? logoUrl;
  final bool isActive;

  const ChannelModel({
    required this.id,
    required this.name,
    required this.channelUrl,
    this.logoUrl,
    required this.isActive,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      channelUrl: json['channel_url'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}
