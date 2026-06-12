import 'package:marcadores_mundial_app/domain/entities/iptv_channel.dart';

class M3uParser {
  static List<IptvChannel> parse(String content) {
    final channels = <IptvChannel>[];
    final lines = content.split('\n');

    String? currentName;
    String? currentLogo;
    String? currentGroup;
    String? currentTvgId;

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed.startsWith('#EXTINF:')) {
        // Parse attributes
        currentName = _extractAttribute(trimmed, 'tvg-name="', '"');
        currentName ??= _extractAttribute(trimmed, 'tvg-id="', '"');
        currentName ??= _extractLastValue(trimmed);
        currentLogo = _extractAttribute(trimmed, 'tvg-logo="', '"');
        currentGroup = _extractAttribute(trimmed, 'group-title="', '"');
        currentTvgId = _extractAttribute(trimmed, 'tvg-id="', '"');
      } else if (trimmed.startsWith('http') || trimmed.startsWith('rtmp') || trimmed.startsWith('rtsp')) {
        if (currentName != null) {
          channels.add(IptvChannel(
            name: currentName,
            url: trimmed,
            logo: currentLogo,
            group: currentGroup,
            tvgId: currentTvgId,
          ));
        }
        currentName = null;
        currentLogo = null;
        currentGroup = null;
        currentTvgId = null;
      }
    }

    return channels;
  }

  static String? _extractAttribute(String line, String prefix, String suffix) {
    final start = line.indexOf(prefix);
    if (start == -1) return null;
    final valueStart = start + prefix.length;
    final end = line.indexOf(suffix, valueStart);
    if (end == -1) return null;
    return line.substring(valueStart, end);
  }

  static String? _extractLastValue(String line) {
    final comma = line.lastIndexOf(',');
    if (comma == -1 || comma == line.length - 1) return null;
    return line.substring(comma + 1).trim();
  }
}
