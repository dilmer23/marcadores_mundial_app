import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/presentation/cubits/iptv_cubit.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/domain/entities/iptv_channel.dart';
import 'package:marcadores_mundial_app/presentation/widgets/soccer_spinner.dart';

class IptvPage extends StatefulWidget {
  const IptvPage({super.key});

  @override
  State<IptvPage> createState() => _IptvPageState();
}

class _IptvPageState extends State<IptvPage> {
  final _urlController = TextEditingController();
  final _searchController = TextEditingController();
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _urlController.text = kDefaultIptvUrl;
  }

  @override
  void dispose() {
    _disposePlayer();
    _urlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _disposePlayer() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
  }

  Future<void> _playChannel(IptvChannel channel) async {
    _disposePlayer();
    final cubit = context.read<IptvCubit>();
    cubit.playChannel(channel);
    cubit.setPlayerLoading(true);

    var streamUrl = channel.url;

    // Resolve via web page (tvtvhd, etc.) if configured; fall back to direct URL
    if (channel.needsResolution) {
      final resolved = await cubit.resolveStreamUrl(channel.resolverUrl!);
      if (resolved != null) {
        streamUrl = resolved;
      }
    }

    if (!mounted) return;
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(streamUrl),
        formatHint: VideoFormat.hls,
        httpHeaders: const {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': '*/*',
        },
      );
      _videoController!.initialize().then((_) {
        if (!mounted) return;
        cubit.setPlayerLoading(false);
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          placeholder: Container(
            color: Colors.black,
            child: SoccerSpinner(
              size: 48,
              message: context.tr('Loading stream...', 'Cargando transmisión...'),
            ),
          ),
          errorBuilder: (_, String errorMessage) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 8),
                    Text(context.tr('Stream error', 'Error de transmisión'),
                        style: const TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text(errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            );
          },
        );
        setState(() {});
      }).catchError((Object e) {
        if (!mounted) return;
        cubit.setPlayerLoading(false);
        _disposePlayer();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Stream error', 'Error de transmisión') + ': $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      });
    } catch (e) {
      cubit.setPlayerLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr("Error", "Error")}: $e')),
      );
    }
  }

  void _stopPlayback() {
    _disposePlayer();
    context.read<IptvCubit>().stopPlayback();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IptvCubit, IptvState>(
      builder: (context, state) {
        final hasPlayer = _chewieController != null && state.currentChannel != null;
        return Column(
          children: [
            if (hasPlayer) _buildPlayer(state),
            if (hasPlayer) _buildNowPlaying(state),
            _buildControls(state),
            const Divider(height: 1),
            if (state.isLoading)
              const Expanded(
                child: Center(
                  child: SoccerSpinner(message: 'Loading playlist...'),
                ),
              )
            else if (state.playerLoading && state.currentChannel != null)
              Expanded(
                child: Center(
                  child: SoccerSpinner(
                    message: context.tr('Loading ${state.currentChannel!.name}...', 'Cargando ${state.currentChannel!.name}...'),
                  ),
                ),
              )
            else if (state.error != null)
              _buildError(state)
            else if (state.channels.isEmpty)
              _buildEmptyState()
            else
              _buildChannelList(state),
          ],
        );
      },
    );
  }

  Widget _buildPlayer(IptvState state) {
    return Container(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              ),
      ),
    );
  }

  Widget _buildNowPlaying(IptvState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.primaryDark,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('NOW PLAYING', 'REPRODUCIENDO'),
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted.withOpacity(0.7),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  state.currentChannel!.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: AppColors.textMuted, size: 22),
            onPressed: _stopPlayback,
          ),
        ],
      ),
    );
  }

  Widget _buildControls(IptvState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: context.tr('M3U playlist URL...', 'URL de lista M3U...'),
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.link_rounded, size: 20),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      final url = _urlController.text.trim();
                      if (url.isNotEmpty) {
                        context.read<IptvCubit>().loadPlaylist(url);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.download_rounded, size: 22),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () => _showAddChannelDialog(context),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.add_rounded, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(IptvState state) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.read<IptvCubit>().clearError(),
                child: Text(context.tr('Dismiss', 'Descartar')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.live_tv_rounded,
                    size: 40, color: AppColors.secondary),
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('IPTV Channels', 'Canales IPTV'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('Load an M3U playlist URL or add a channel manually', 'Carga una URL M3U o agrega un canal manualmente'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelList(IptvState state) {
    var channels = state.channels;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      channels = channels
          .where((c) => c.name.toLowerCase().contains(q))
          .toList();
    }

    // Group by category
    final grouped = <String, List<IptvChannel>>{};
    for (final c in channels) {
      final group = c.group ?? context.tr('Other', 'Otros');
      grouped.putIfAbsent(group, () => []);
      grouped[group]!.add(c);
    }
    final sortedGroups = grouped.keys.toList()..sort();

    return Expanded(
      child: Column(
        children: [
          // Search
          if (state.channels.length > 10)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: context.tr('Search channels...', 'Buscar canales...'),
                  prefixIcon: const Icon(Icons.search_rounded, size: 22),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
            ),
          // Channels count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text(
                  context.tr('${channels.length} channel${channels.length == 1 ? '' : 's'}', '${channels.length} canal${channels.length == 1 ? '' : 'es'}'),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: sortedGroups.length,
              itemBuilder: (_, i) {
                final group = sortedGroups[i];
                final groupChannels = grouped[group]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                      child: Text(
                        group,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textLight
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    ...groupChannels.map((c) => _channelTile(c, state)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _channelTile(IptvChannel channel, IptvState state) {
    final isPlaying = state.currentChannel?.url == channel.url;
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: channel.logo != null && channel.logo!.isNotEmpty
            ? Image.network(
                channel.logo!,
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _defaultLogo(),
              )
            : _defaultLogo(),
      ),
      title: Text(
        channel.name,
        style: TextStyle(
          fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w500,
          color: isPlaying ? AppColors.secondary : null,
        ),
      ),
      subtitle: Text(
        channel.url,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
      trailing: isPlaying
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fiber_manual_record_rounded,
                      size: 8, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text(context.tr('LIVE', 'EN VIVO'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      )),
                ],
              ),
            )
          : const Icon(Icons.play_circle_outline_rounded,
              color: AppColors.textMuted),
      onTap: () => _playChannel(channel),
    );
  }

  Widget _defaultLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.live_tv_rounded,
          size: 20, color: AppColors.secondary),
    );
  }

  void _showAddChannelDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final groupController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('Add Channel', 'Agregar Canal')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: context.tr('Channel Name', 'Nombre del Canal'),
                hintText: context.tr('e.g. ESPN', 'ej. ESPN'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: context.tr('Stream URL', 'URL del Stream'),
                hintText: context.tr('https://...m3u8', 'https://...m3u8'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: groupController,
              decoration: InputDecoration(
                labelText: context.tr('Group (optional)', 'Grupo (opcional)'),
                hintText: context.tr('e.g. Sports', 'ej. Deportes'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('Cancel', 'Cancelar')),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final url = urlController.text.trim();
              if (name.isNotEmpty && url.isNotEmpty) {
                final newChannel = IptvChannel(
                  name: name,
                  url: url,
                  group: groupController.text.trim().isNotEmpty
                      ? groupController.text.trim()
                      : null,
                );
                final state = context.read<IptvCubit>().state;
                final updated = List<IptvChannel>.from(state.channels)
                  ..add(newChannel);
                context.read<IptvCubit>().loadLocalPlaylist(
                      _channelsToM3u(updated),
                    );
                Navigator.pop(ctx);
              }
            },
            child: Text(context.tr('Add', 'Agregar')),
          ),
        ],
      ),
    );
  }

  String _channelsToM3u(List<IptvChannel> channels) {
    final buf = StringBuffer('#EXTM3U\n');
    for (final c in channels) {
      buf.writeln('#EXTINF:-1'
          '${c.tvgId != null ? ' tvg-id="${c.tvgId}"' : ''}'
          '${c.logo != null ? ' tvg-logo="${c.logo}"' : ''}'
          '${c.group != null ? ' group-title="${c.group}"' : ''}'
          ',${c.name}');
      buf.writeln(c.url);
    }
    return buf.toString();
  }
}
