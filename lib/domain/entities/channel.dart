class Channel {
  final int id;
  final String name;
  final String channelUrl;
  final String? logoUrl;
  final bool isActive;

  const Channel({
    required this.id,
    required this.name,
    required this.channelUrl,
    this.logoUrl,
    required this.isActive,
  });
}
