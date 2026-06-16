import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

// ignore: avoid_web_libraries_in_flutter
class PlatformPlayer extends StatefulWidget {
  final String url;
  final String channelName;
  const PlatformPlayer(
      {required this.url, required this.channelName, super.key});

  @override
  State<PlatformPlayer> createState() => _PlatformPlayerState();
}

class _PlatformPlayerState extends State<PlatformPlayer> {
  String get _viewType => 'player-iframe-${widget.url.hashCode}';

  @override
  void initState() {
    super.initState();
    try {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        return html.IFrameElement()
          ..src = widget.url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.border = 'none'
          ..allow = 'autoplay; encrypted-media'
          ..setAttribute('allowfullscreen', 'true');
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
