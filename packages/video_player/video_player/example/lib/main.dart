// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.
library;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MaterialApp(home: _App()));
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: const ValueKey<String>('home_page'),
        appBar: AppBar(
          title: const Text('Video player example'),
          actions: <Widget>[
            IconButton(
              key: const ValueKey<String>('push_tab'),
              icon: const Icon(Icons.navigation),
              onPressed: () {
                Navigator.push<_PlayerVideoAndPopPage>(
                  context,
                  MaterialPageRoute<_PlayerVideoAndPopPage>(
                    builder: (BuildContext context) => _PlayerVideoAndPopPage(),
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.list), text: 'List example'),
              Tab(icon: Icon(Icons.cloud), text: 'Remote'),
              Tab(icon: Icon(Icons.insert_drive_file), text: 'Asset'),
              Tab(icon: Icon(Icons.dynamic_feed), text: 'Multiplay'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _ViewTypeTabBar(
              builder: (VideoViewType viewType) =>
                  _InitializeVideosSimulInList(viewType),
            ),
            _ViewTypeTabBar(
              builder: (VideoViewType viewType) =>
                  _BumbleBeeRemoteVideo(viewType),
            ),
            _ViewTypeTabBar(
              builder: (VideoViewType viewType) => const Text('Hello'),
            ),
            _ViewTypeTabBar(
              builder: (VideoViewType viewType) => _MultiplePlayers(viewType),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewTypeTabBar extends StatefulWidget {
  const _ViewTypeTabBar({required this.builder});

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
            Tab(icon: Icon(Icons.texture), text: 'Texture view'),
            Tab(icon: Icon(Icons.construction), text: 'Platform view'),
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

class _InitializeVideosSimulInList extends StatefulWidget {
  const _InitializeVideosSimulInList(this.viewType);

  final VideoViewType viewType;

  @override
  _InitializeVideosSimulInListState createState() =>
      _InitializeVideosSimulInListState();
}

class _InitializeVideosSimulInListState
    extends State<_InitializeVideosSimulInList> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<VideoPlayerController> _videoControllers;
  final List<String> _videoAssets = <String>[
    'assets/Butterfly-209.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _videoControllers = <VideoPlayerController>[];

    for (var i = 0; i < _videoAssets.length; i++) {
      final String asset = _videoAssets[i];
      final VideoPlayerController controller;

      if (asset.startsWith('http')) {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(asset),
          viewType: widget.viewType,
        );
      } else {
        controller = VideoPlayerController.asset(
          asset,
          viewType: widget.viewType,
        );
      }

      controller.setLooping(true);
      if (i != 0) {
        // Initialize all videos except the first one for easier debugging
        controller.initialize().then((_) {
          if (i == _currentPage) {
            controller.play();
          }
        });
      }

      _videoControllers.add(controller);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final VideoPlayerController controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: (int page) {
        // Pause previous video
        if (_videoControllers.isNotEmpty &&
            _currentPage < _videoControllers.length) {
          _videoControllers[_currentPage].pause();
        }

        setState(() {
          _currentPage = page;
        });

        // Play current video
        if (_videoControllers.isNotEmpty && page < _videoControllers.length) {
          _videoControllers[page].play();
        }
      },
      children: <Widget>[
        Card(
          child: Column(
            children: <Widget>[
              const ListTile(leading: Icon(Icons.cake), title: Text('Video 1')),
              _Video(
                _videoControllers.isNotEmpty ? _videoControllers[0] : null,
                shouldPlay: _currentPage == 0,
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: <Widget>[
              const ListTile(leading: Icon(Icons.cake), title: Text('Video 2')),
              _Video(
                _videoControllers.isNotEmpty ? _videoControllers[1] : null,
                shouldPlay: _currentPage == 1,
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: <Widget>[
              const ListTile(leading: Icon(Icons.cake), title: Text('Video 3')),
              _Video(
                _videoControllers.isNotEmpty ? _videoControllers[2] : null,
                shouldPlay: _currentPage == 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Video extends StatefulWidget {
  const _Video(
    this.controller, {
    this.shouldPlay = true,
    this.showControls = true,
    this.showProgressIndicator = true,
  });

  final VideoPlayerController? controller;
  final bool shouldPlay;
  final bool showControls;
  final bool showProgressIndicator;

  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<_Video> {
  VideoPlayerController? get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller?.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(_Video oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shouldPlay != widget.shouldPlay && _controller != null) {
      if (widget.shouldPlay) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    }
  }

  @override
  void dispose() {
    // Don't dispose the controller here since it's managed by the parent
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: Text('Not Loaded'));
    }

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(padding: const EdgeInsets.only(top: 20.0)),
          const Text('With assets mp4'),
          Container(
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller!),
                  if (widget.showControls)
                    _ControlsOverlay(controller: _controller!),
                  if (widget.showProgressIndicator)
                    VideoProgressIndicator(_controller!, allowScrubbing: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiplePlayers extends StatefulWidget {
  const _MultiplePlayers(this.viewType);

  final VideoViewType viewType;

  @override
  _MultiplePlayersState createState() => _MultiplePlayersState();
}

class _MultiplePlayersState extends State<_MultiplePlayers> {
  late List<VideoPlayerController> _videoControllers;
  final List<String> _videoAssets = <String>[
    'assets/Butterfly-209.mp4',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _videoControllers = <VideoPlayerController>[];

    for (var i = 0; i < _videoAssets.length; i++) {
      final String asset = _videoAssets[i];
      final VideoPlayerController controller;

      if (asset.startsWith('http')) {
        controller = VideoPlayerController.networkUrl(
          Uri.parse(asset),
          viewType: widget.viewType,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        controller = VideoPlayerController.asset(
          asset,
          viewType: widget.viewType,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      }

      controller
        ..setLooping(true)
        ..initialize().then((_) {
          controller.play();
        });
      _videoControllers.add(controller);
    }
  }

  @override
  void dispose() {
    for (final VideoPlayerController controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final controller in _videoControllers)
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              },
              child: _Video(controller, showControls: false),
            ),
          ),
      ],
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
  late VideoPlayerController _controller;

  Future<ClosedCaptionFile> _loadCaptions() async {
    final String fileContents = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/bumble_bee_captions.vtt');
    return WebVTTCaptionFile(
      fileContents,
    ); // For vtt files, use WebVTTCaptionFile
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
      closedCaptionFile: _loadCaptions(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      viewType: widget.viewType,
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
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
        children: [
          SizedBox(
            height: 400,
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[_Video(_controller)],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              FilledButton(
                onPressed: () {
                  _controller.stop();
                },
                child: const Text('STOP'),
              ),
              FilledButton(
                onPressed: () {
                  _controller.initialize();
                  _controller.setLooping(true);
                },
                child: const Text('INITIALIZE'),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              _controller.loadAsset(
                Uri.parse(
                  'https://cdn.mono-digital.com/challenges/d9b4cb50-a56c-47b1-b368-c9397c3d356a/contributions/de76015c-df4a-4bdc-85ee-a97509d71ed8/c4ab30b6-a6b4-4c01-a349-283cb6521de2.mp4',
                ),
              );
            },
            child: const Text('Load butterfly'),
          ),
          TextButton(
            onPressed: () {
              _controller.loadAsset(
                Uri.parse(
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
                ),
              );
            },
            child: const Text('Load game of thrones'),
          ),
          TextButton(
            onPressed: () {
              _controller.loadAsset(
                Uri.parse(
                  'https://cdn.mono-digital.com/challenges/be599c70-16c5-4368-8e96-88caec9db6e8/d250a736-ff7e-43fe-95ce-6a81861feed0.mp4',
                ),
              );
            },
            child: const Text('Load bee'),
          ),
          TextButton(
            onPressed: () {
              _controller.dispose();
              _controller = VideoPlayerController.asset(
                'assets/hdr.MOV',
                videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
                viewType: VideoViewType.platformView,
              );
              _controller.addListener(() {
                setState(() {});
              });
              _controller.setLooping(true);
              _controller.initialize();
              _controller.play();
            },
            child: const Text('Create new player for HDR'),
          ),
          TextButton(
            onPressed: () {
              _controller.dispose();
              _controller = VideoPlayerController.networkUrl(
                Uri.parse(
                  'https://cdn.mono-digital.com/challenges/d9b4cb50-a56c-47b1-b368-c9397c3d356a/b0ecdcbf-7091-4ce7-91f7-fb50c86be975.mp4',
                ),
                closedCaptionFile: _loadCaptions(),
                videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
              );
              _controller.addListener(() {
                setState(() {});
              });
              _controller.setLooping(true);
              _controller.initialize();
              _controller.play();
            },
            child: const Text('Create new player for butterfly'),
          ),
          TextButton(
            onPressed: () {
              _controller.dispose();
              _controller = VideoPlayerController.networkUrl(
                Uri.parse(
                  'https://cdn.mono-digital.com/challenges/d9b4cb50-a56c-47b1-b368-c9397c3d356a/contributions/de76015c-df4a-4bdc-85ee-a97509d71ed8/c4ab30b6-a6b4-4c01-a349-283cb6521de2.mp4',
                ),
                closedCaptionFile: _loadCaptions(),
                videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
              );
              _controller.addListener(() {
                setState(() {});
              });
              _controller.setLooping(true);
              _controller.initialize();
              _controller.play();
            },
            child: const Text('Create new player for bee'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});

  static const List<Duration> _exampleCaptionOffsets = <Duration>[
    Duration(seconds: -10),
    Duration(seconds: -3),
    Duration(seconds: -1, milliseconds: -500),
    Duration(milliseconds: -250),
    Duration.zero,
    Duration(milliseconds: 250),
    Duration(seconds: 1, milliseconds: 500),
    Duration(seconds: 3),
    Duration(seconds: 10),
  ];
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

  final VideoPlayerController controller;

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
          alignment: Alignment.topLeft,
          child: PopupMenuButton<Duration>(
            initialValue: controller.value.captionOffset,
            tooltip: 'Caption Offset',
            onSelected: (Duration delay) {
              controller.setCaptionOffset(delay);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<Duration>>[
                for (final Duration offsetDuration in _exampleCaptionOffsets)
                  PopupMenuItem<Duration>(
                    value: offsetDuration,
                    child: Text('${offsetDuration.inMilliseconds}ms'),
                  ),
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
              child: Text('${controller.value.captionOffset.inMilliseconds}ms'),
            ),
          ),
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
                  PopupMenuItem<double>(value: speed, child: Text('${speed}x')),
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

class _PlayerVideoAndPopPage extends StatefulWidget {
  @override
  _PlayerVideoAndPopPageState createState() => _PlayerVideoAndPopPageState();
}

class _PlayerVideoAndPopPageState extends State<_PlayerVideoAndPopPage> {
  late VideoPlayerController _videoPlayerController;
  bool startedPlaying = false;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.asset(
      'assets/Butterfly-209.mp4',
    );
    _videoPlayerController.addListener(() {
      if (startedPlaying && !_videoPlayerController.value.isPlaying) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<bool> started() async {
    await _videoPlayerController.initialize();
    await _videoPlayerController.play();
    startedPlaying = true;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: FutureBuilder<bool>(
          future: started(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data ?? false) {
              return AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              );
            } else {
              return const Text('waiting for video to load');
            }
          },
        ),
      ),
    );
  }
}
