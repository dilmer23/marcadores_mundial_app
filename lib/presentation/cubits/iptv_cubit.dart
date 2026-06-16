import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:marcadores_mundial_app/domain/entities/iptv_channel.dart';
import 'package:marcadores_mundial_app/data/utils/m3u_parser.dart';

const kDefaultIptvUrl ='';

const kPinnedChannel = IptvChannel(
  name: 'DSPORT',
  url: 'https://videopro.juanjuistream.uk:1981/tve/index.fmp4.m3u8',
  group: 'Featured',
  logo: 'https://i.imgur.com/x3Ns7K5.png',
  resolverUrl: 'https://tvtvhd.com/canales.php?stream=dsports',
);

class IptvState {
  final List<IptvChannel> channels;
  final bool isLoading;
  final String? error;
  final String? currentUrl;
  final IptvChannel? currentChannel;
  final bool playerLoading;
  final String? resolvedStreamUrl;

  const IptvState({
    this.channels = const [],
    this.isLoading = false,
    this.error,
    this.currentUrl,
    this.currentChannel,
    this.playerLoading = false,
    this.resolvedStreamUrl,
  });

  IptvState copyWith({
    List<IptvChannel>? channels,
    bool? isLoading,
    String? error,
    String? currentUrl,
    IptvChannel? currentChannel,
    bool? playerLoading,
    String? resolvedStreamUrl,
  }) {
    return IptvState(
      channels: channels ?? this.channels,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentUrl: currentUrl ?? this.currentUrl,
      currentChannel: currentChannel ?? this.currentChannel,
      playerLoading: playerLoading ?? this.playerLoading,
      resolvedStreamUrl: resolvedStreamUrl ?? this.resolvedStreamUrl,
    );
  }
}

class IptvCubit extends Cubit<IptvState> {
  IptvCubit() : super(const IptvState()) {
    loadPlaylist(kDefaultIptvUrl);
  }

  Future<void> loadPlaylist(String url) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final channels = M3uParser.parse(response.body);
        emit(state.copyWith(
          channels: [kPinnedChannel, ...channels],
          isLoading: false,
          currentUrl: url,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to load playlist (${response.statusCode})',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Error loading playlist: $e',
      ));
    }
  }

  void loadLocalPlaylist(String rawM3u) {
    final channels = M3uParser.parse(rawM3u);
    emit(state.copyWith(
        channels: [kPinnedChannel, ...channels],
        isLoading: false,
        error: null));
  }

  /// Resuelve una URL de página web (tvtvhd, la18hd, etc.) extrayendo el playbackURL
  Future<String?> resolveStreamUrl(String pageUrl) async {
    try {
      final response = await http.get(
        Uri.parse(pageUrl),
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': '*/*',
        },
      );
      if (response.statusCode != 200) return null;

      var body = response.body;

      // Follow iframe if present (tvtvhd -> la18hd)
      final iframeMatch =
          RegExp(r'''<iframe[^>]+src="([^"]+canales[^"]*)"''')
              .firstMatch(body);
      if (iframeMatch != null) {
        final iframeUrl = iframeMatch.group(1)!;
        final iframeResponse = await http.get(
          Uri.parse(iframeUrl),
          headers: const {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Referer': 'https://tvtvhd.com/',
          },
        );
        if (iframeResponse.statusCode == 200) {
          body = iframeResponse.body;
        }
      }

      // Busca: var playbackURL = "..." o playbackURL = '...'
      final patterns = [
        RegExp(r'''playbackURL\s*=\s*"([^"]+)"'''),
        RegExp(r"""playbackURL\s*=\s*'([^']+)'"""),
        RegExp(r'''source:\s*"([^"]+\.m3u8[^"]*)"'''),
        RegExp(r"""source:\s*'([^']+\.m3u8[^']*)'"""),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(body);
        if (match != null) {
          final url = match.group(1)!;
          emit(state.copyWith(resolvedStreamUrl: url));
          return url;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void playChannel(IptvChannel channel) {
    emit(state.copyWith(
        currentChannel: channel, resolvedStreamUrl: null));
  }

  void setPlayerLoading(bool loading) {
    emit(state.copyWith(playerLoading: loading));
  }

  void stopPlayback() {
    emit(state.copyWith(
        currentChannel: null, playerLoading: false, resolvedStreamUrl: null));
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
