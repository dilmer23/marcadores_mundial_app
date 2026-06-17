import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/domain/entities/channel.dart';
import 'package:marcadores_mundial_app/presentation/cubits/tv_channels_cubit.dart';
import 'package:marcadores_mundial_app/presentation/widgets/player_widget.dart';

class WatchTvPage extends StatefulWidget {
  const WatchTvPage({super.key});

  @override
  State<WatchTvPage> createState() => _WatchTvPageState();
}

class _WatchTvPageState extends State<WatchTvPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<TvChannelsCubit>().loadChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    size: 40, color: AppColors.error),
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('Connection Error', 'Error de conexión'),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.live_tv_rounded,
                  size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
                context.tr('No channels available', 'No hay canales disponibles'),
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    final filtered = _searchQuery.isEmpty
        ? state.channels
        : state.channels
            .where((ch) =>
                ch.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: context.tr(
                        'Search channels...', 'Buscar canales...'),
                    prefixIcon:
                        const Icon(Icons.search_rounded, size: 22),
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
                        ? AppColors.bgCard
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      context.tr(
                          '${filtered.length} channel${filtered.length == 1 ? '' : 's'} found',
                          '${filtered.length} canal${filtered.length == 1 ? '' : 'es'} encontrado${filtered.length == 1 ? '' : 's'}'),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (filtered.isEmpty && _searchQuery.isNotEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('No channels match your search',
                        'Ningún canal coincide con tu búsqueda'),
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _ChannelCard(channel: filtered[index]),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          color: isDark ? AppColors.bgCard : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isDark ? Colors.grey[800] : Colors.grey[200]),
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
                  color: (isDark ? Colors.grey[800] : Colors.grey[200]),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 12,
                  color: (isDark ? Colors.grey[800] : Colors.grey[200]),
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
  final Channel channel;
  const _ChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _TvViewer(channel: channel),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppColors.cardRadius),
            color: isDark ? AppColors.bgCard : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(channel.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text('Live',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.2),
                        AppColors.secondary.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: AppColors.secondary, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TvViewer extends StatelessWidget {
  final Channel channel;
  const _TvViewer({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(channel.name)),
      body: PlatformPlayer(url: channel.channelUrl, channelName: channel.name),
    );
  }
}
