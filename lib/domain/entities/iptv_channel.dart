class IptvChannel {
  final String name;
  final String url;
  final String? logo;
  final String? group;
  final String? tvgId;
  final String? resolverUrl;

  const IptvChannel({
    required this.name,
    required this.url,
    this.logo,
    this.group,
    this.tvgId,
    this.resolverUrl,
  });

  bool get needsResolution => resolverUrl != null;
}
