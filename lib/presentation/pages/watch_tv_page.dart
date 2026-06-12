import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';

class WatchTvPage extends StatefulWidget {
  const WatchTvPage({super.key});

  @override
  State<WatchTvPage> createState() => _WatchTvPageState();
}

class _WatchTvPageState extends State<WatchTvPage> {
  @override
  Widget build(BuildContext context) {
    final channels = [
      _Channel('DSports',
          'https://tvtvhd.com/canales.php?stream=dsports'),
      _Channel('WinSports',
          'https://tvtvhd.com/vivo/canal.php?stream=winsports'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(context.tr('Watch TV', 'Ver TV'),
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(context.tr('Live sports channels', 'Canales deportivos en vivo'),
            style: const TextStyle(
                fontSize: 14, color: AppColors.textMuted)),
        const SizedBox(height: 16),
        if (kIsWeb)
          Text(context.tr(
              'Channels open in embedded viewer',
              'Los canales se abren en visor integrado'),
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 8),
        ...channels.map((ch) => _ChannelCard(channel: ch)),
      ],
    );
  }
}

class _Channel {
  final String name;
  final String url;
  const _Channel(this.name, this.url);
}

class _ChannelCard extends StatelessWidget {
  final _Channel channel;
  const _ChannelCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.live_tv_rounded,
              color: AppColors.primary),
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

// Visor WebView multiplataforma (Android, iOS, Web)
class _TvViewer extends StatefulWidget {
  final _Channel channel;
  const _TvViewer({required this.channel});

  @override
  State<_TvViewer> createState() => _TvViewerState();
}

class _TvViewerState extends State<_TvViewer> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.channel.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.channel.name)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
