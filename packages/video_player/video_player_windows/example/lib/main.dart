// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MaterialApp(home: _WindowsVideoExample()));

class _WindowsVideoExample extends StatefulWidget {
  const _WindowsVideoExample();

  @override
  State<_WindowsVideoExample> createState() => _WindowsVideoExampleState();
}

class _WindowsVideoExampleState extends State<_WindowsVideoExample> {
  final VideoPlayerController _controller = VideoPlayerController.asset('assets/Butterfly-209.mp4');
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _controller.initialize();
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Windows video player')),
    body: FutureBuilder<void>(
      future: _initialization,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Could not load video: ${snapshot.error}'));
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: _controller,
          builder: (BuildContext context, VideoPlayerValue value, Widget? child) => Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
              VideoProgressIndicator(_controller, allowScrubbing: true),
              IconButton(
                tooltip: value.isPlaying ? 'Pause' : 'Play',
                onPressed: () => value.isPlaying ? _controller.pause() : _controller.play(),
                icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
              ),
            ],
          ),
        );
      },
    ),
  );
}
