import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/data/models/channel_model.dart';
import 'package:marcadores_mundial_app/presentation/cubits/tv_channels_cubit.dart';
import 'package:marcadores_mundial_app/presentation/widgets/player_widget.dart';

class WatchTvPage extends StatefulWidget {
  const WatchTvPage({super.key});

  @override
  State<WatchTvPage> createState() => _WatchTvPageState();
}

class _WatchTvPageState extends State<WatchTvPage> {
  @override
  void initState() {
    super.initState();
    context.read<TvChannelsCubit>().loadChannels();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TvChannelsCubit, TvChannelsState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async =>
              context.read<TvChannelsCubit>().loadChannels(),
          child: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, TvChannelsState state) {
    if (state.isLoading) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(4, (_) => _buildShimmer()),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () =>
                    context.read<TvChannelsCubit>().loadChannels(),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.tr('Retry', 'Reintentar')),
              ),
            ],
          ),
        ),
      );
    }

    if (state.channels.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.live_tv_rounded,
                size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(context.tr('No channels available', 'No hay canales disponibles'),
                style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(context.tr('Watch TV', 'Ver TV'),
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
            context.tr(
                'Live sports channels', 'Canales deportivos en vivo'),
            style: const TextStyle(
                fontSize: 14, color: AppColors.textMuted)),
        const SizedBox(height: 16),
        ...state.channels.map((ch) => _ChannelCard(channel: ch)),
      ],
    );
  }

  Widget _buildShimmer() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 12,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final ChannelModel channel;
  const _ChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: channel.logoUrl != null && channel.logoUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: channel.logoUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(
                    width: 48,
                    height: 48,
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.live_tv_rounded,
                        color: AppColors.primary),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.live_tv_rounded,
                        color: AppColors.primary),
                  ),
                )
              : Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.live_tv_rounded,
                      color: AppColors.primary),
                ),
        ),
        title: Text(channel.name,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('TV'),
        trailing: const Icon(Icons.play_circle_fill_rounded,
            color: AppColors.secondary),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _TvViewer(channel: channel),
          ),
        ),
      ),
    );
  }
}

class _TvViewer extends StatelessWidget {
  final ChannelModel channel;
  const _TvViewer({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(channel.name)),
      body: PlatformPlayer(url: channel.channelUrl, channelName: channel.name),
    );
  }
}
