import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  final String id;

  const VideoScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String _iframeId = 'youtube_iframe_$id';

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_iframeId, (int viewId) {
      final html.IFrameElement element = html.IFrameElement()
        ..width = '100%'
        ..height = '100%'
        ..src = 'https://www.youtube.com/embed/$id'
        ..style.border = 'none';
      return element;
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Now Playing',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF2A2824),
          ),
        ),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.black87, Colors.blueGrey.shade900]
                      : [const Color(0xFFDFD7C2), const Color(0xFFF7DB4C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: HtmlElementView(viewType: _iframeId),
        ),
      ),
    );
  }
}
