// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'mini_controller.dart';

void main() {
  runApp(
    MaterialApp(
      home: _App(),
    ),
  );
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: const ValueKey<String>('home_page'),
        appBar: AppBar(
          title: const Text('Video player example'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.cloud),
                text: 'Remote mp4',
              ),
              Tab(
                icon: Icon(Icons.favorite),
                text: 'Remote enc m3u8',
              ),
              Tab(icon: Icon(Icons.insert_drive_file), text: 'Asset mp4'),
            ],
          ),
        ),
        body: TabBarView(
          children: Platform.isIOS
              ? <Widget>[
                  _ViewTypeTabBar(
                    builder: (VideoViewType viewType) =>
                        _BumbleBeeRemoteVideo(viewType),
                  ),
                  _ViewTypeTabBar(
                    builder: (VideoViewType viewType) =>
                        _BumbleBeeEncryptedLiveStream(viewType),
                  ),
                  _ViewTypeTabBar(
                    builder: (VideoViewType viewType) =>
                        _ButterFlyAssetVideo(viewType),
                  ),
                ]
              // Platform views are only supported on iOS as of now.
              : const <Widget>[
                  _BumbleBeeRemoteVideo(VideoViewType.textureView),
                  _BumbleBeeEncryptedLiveStream(VideoViewType.textureView),
                  _ButterFlyAssetVideo(VideoViewType.textureView),
                ],
        ),
      ),
    );
  }
}

class _ViewTypeTabBar extends StatefulWidget {
  const _ViewTypeTabBar({
    required this.builder,
  });

  final Widget Function(VideoViewType) builder;

  @override
  State<_ViewTypeTabBar> createState() => _ViewTypeTabBarState();
}

class _ViewTypeTabBarState extends State<_ViewTypeTabBar>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.texture),
              text: 'Texture view',
            ),
            Tab(
              icon: Icon(Icons.construction),
              text: 'Platform view',
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              widget.builder(VideoViewType.textureView),
              widget.builder(VideoViewType.platformView),
            ],
          ),
        ),
      ],
    );
  }
}

class _ButterFlyAssetVideo extends StatefulWidget {
  const _ButterFlyAssetVideo(this.viewType);

  final VideoViewType viewType;

  @override
  _ButterFlyAssetVideoState createState() => _ButterFlyAssetVideoState();
}

class _ButterFlyAssetVideoState extends State<_ButterFlyAssetVideo> {
  late MiniController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MiniController.asset(
      'assets/Butterfly-209.mp4',
      viewType: widget.viewType,
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize().then((_) => setState(() {}));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 20.0),
          ),
          const Text('With assets mp4'),
          Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BumbleBeeRemoteVideo extends StatefulWidget {
  const _BumbleBeeRemoteVideo(this.viewType);

  final VideoViewType viewType;

  @override
  _BumbleBeeRemoteVideoState createState() => _BumbleBeeRemoteVideoState();
}

class _BumbleBeeRemoteVideoState extends State<_BumbleBeeRemoteVideo> {
  late MiniController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MiniController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      viewType: widget.viewType,
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(padding: const EdgeInsets.only(top: 20.0)),
          const Text('With remote mp4'),
          Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  _ControlsOverlay(controller: _controller),
                  VideoProgressIndicator(_controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BumbleBeeEncryptedLiveStream extends StatefulWidget {
  const _BumbleBeeEncryptedLiveStream(this.viewType);

  final VideoViewType viewType;

  @override
  _BumbleBeeEncryptedLiveStreamState createState() =>
      _BumbleBeeEncryptedLiveStreamState();
}

class _BumbleBeeEncryptedLiveStreamState
    extends State<_BumbleBeeEncryptedLiveStream> {
  late MiniController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MiniController.network(
      'https://flutter.github.io/assets-for-api-docs/assets/videos/hls/encrypted_bee.m3u8',
      viewType: widget.viewType,
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.initialize();

    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(padding: const EdgeInsets.only(top: 20.0)),
          const Text('With remote encrypted m3u8'),
          Container(
            padding: const EdgeInsets.all(20),
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Text('loading...'),
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final MiniController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : const ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
