import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlatformPlayer extends StatefulWidget {
  final String url;
  final String channelName;
  const PlatformPlayer({required this.url, required this.channelName, super.key});

  @override
  State<PlatformPlayer> createState() => _PlatformPlayerState();
}

class _PlatformPlayerState extends State<PlatformPlayer> {
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
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
