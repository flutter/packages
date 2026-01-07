// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A demo page that showcases video track (quality) selection functionality.
class VideoTracksDemo extends StatefulWidget {
  /// Creates a VideoTracksDemo widget.
  const VideoTracksDemo({super.key});

  @override
  State<VideoTracksDemo> createState() => _VideoTracksDemoState();
}

class _VideoTracksDemoState extends State<VideoTracksDemo> {
  VideoPlayerController? _controller;
  List<VideoTrack> _videoTracks = <VideoTrack>[];
  bool _isLoading = false;
  String? _error;
  bool _isAutoQuality = true;

  // Track previous state to detect relevant changes
  bool _wasPlaying = false;
  bool _wasInitialized = false;

  // Sample video URLs with multiple video tracks (HLS streams)
  static const List<String> _sampleVideos = <String>[
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8',
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
  ];

  int _selectedVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isAutoQuality = true;
    });

    try {
      await _controller?.dispose();

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(_sampleVideos[_selectedVideoIndex]),
      );
      _controller = controller;

      await controller.initialize();

      // Add listener for video player state changes
      _controller!.addListener(_onVideoPlayerValueChanged);

      // Initialize tracking variables
      _wasPlaying = _controller!.value.isPlaying;
      _wasInitialized = _controller!.value.isInitialized;

      // Get video tracks after initialization
      await _loadVideoTracks();
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Failed to initialize video: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVideoTracks() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    // Check if video track selection is supported
    if (!controller.isVideoTrackSupportAvailable()) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Video track selection is not supported on this platform.';
        _videoTracks = <VideoTrack>[];
      });
      return;
    }

    try {
      final List<VideoTrack> tracks = await controller.getVideoTracks();
      if (!mounted) {
        return;
      }
      setState(() {
        _videoTracks = tracks;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Failed to load video tracks: $e';
      });
    }
  }

  Future<void> _selectVideoTrack(VideoTrack? track) async {
    final VideoPlayerController? controller = _controller;
    if (controller == null) {
      return;
    }

    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await controller.selectVideoTrack(track);

      setState(() {
        _isAutoQuality = track == null;
      });

      // Reload tracks to update selection status
      await _loadVideoTracks();

      if (!mounted) {
        return;
      }
      final message = track == null
          ? 'Switched to automatic quality'
          : 'Selected video track: ${_getTrackLabel(track)}';
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) {
        return;
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to select video track: $e')),
      );
    }
  }

  String _getTrackLabel(VideoTrack track) {
    if (track.label.isNotEmpty) {
      return track.label;
    }
    if (track.height != null && track.width != null) {
      return '${track.width}x${track.height}';
    }
    if (track.height != null) {
      return '${track.height}p';
    }
    return 'Track ${track.id}';
  }

  String _formatBitrate(int? bitrate) {
    if (bitrate == null) {
      return 'Unknown';
    }
    if (bitrate >= 1000000) {
      return '${(bitrate / 1000000).toStringAsFixed(2)} Mbps';
    }
    if (bitrate >= 1000) {
      return '${(bitrate / 1000).toStringAsFixed(0)} Kbps';
    }
    return '$bitrate bps';
  }

  void _onVideoPlayerValueChanged() {
    if (!mounted || _controller == null) {
      return;
    }

    final VideoPlayerValue currentValue = _controller!.value;
    var shouldUpdate = false;

    // Check for relevant state changes that affect UI
    if (currentValue.isPlaying != _wasPlaying) {
      _wasPlaying = currentValue.isPlaying;
      shouldUpdate = true;
    }

    if (currentValue.isInitialized != _wasInitialized) {
      _wasInitialized = currentValue.isInitialized;
      shouldUpdate = true;
    }

    // Only call setState if there are relevant changes
    if (shouldUpdate) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoPlayerValueChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Tracks Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: <Widget>[
          // Video selection dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownMenu<int>(
              initialSelection: _selectedVideoIndex,
              label: const Text('Select Video'),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
              dropdownMenuEntries: _sampleVideos.indexed.map(((int, String) record) {
                final (index, url) = record;
                final label = url.contains('.m3u8')
                    ? 'HLS Stream ${index + 1}'
                    : 'MP4 Video ${index + 1}';
                return DropdownMenuEntry<int>(value: index, label: label);
              }).toList(),
              onSelected: (int? value) {
                if (value != null && value != _selectedVideoIndex) {
                  setState(() {
                    _selectedVideoIndex = value;
                  });
                  _initializeVideo();
                }
              },
            ),
          ),

          // Video player
          Expanded(
            flex: 2,
            child: ColoredBox(color: Colors.black, child: _buildVideoPlayer()),
          ),

          // Video tracks list
          Expanded(flex: 3, child: _buildVideoTracksList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadVideoTracks,
        tooltip: 'Refresh Video Tracks',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _controller?.value.isInitialized != true) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _initializeVideo, child: const Text('Retry')),
          ],
        ),
      );
    }

    final VideoPlayerController? controller = _controller;
    if (controller?.value.isInitialized ?? false) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          _buildPlayPauseButton(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(controller, allowScrubbing: true),
          ),
        ],
      );
    }

    return const Center(
      child: Text('No video loaded', style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildPlayPauseButton() {
    final VideoPlayerController? controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        iconSize: 48,
        color: Colors.white,
        onPressed: () {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        },
        icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }

  Widget _buildVideoTracksList() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.high_quality),
              const SizedBox(width: 8),
              Text(
                'Video Tracks (${_videoTracks.length})',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Auto quality option
          Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _isAutoQuality ? Colors.blue : Colors.grey,
                child: Icon(
                  _isAutoQuality ? Icons.check : Icons.auto_awesome,
                  color: Colors.white,
                ),
              ),
              title: Text(
                'Automatic Quality',
                style: TextStyle(
                  fontWeight: _isAutoQuality ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: const Text('Let the player choose the best quality'),
              trailing: _isAutoQuality
                  ? const Icon(Icons.radio_button_checked, color: Colors.blue)
                  : const Icon(Icons.radio_button_unchecked),
              onTap: _isAutoQuality ? null : () => _selectVideoTrack(null),
            ),
          ),

          const SizedBox(height: 8),

          if (_videoTracks.isEmpty && _error == null)
            const Expanded(
              child: Center(
                child: Text(
                  'No video tracks available.\nTry loading an HLS stream with multiple quality levels.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else if (_error != null && (_controller?.value.isInitialized ?? false))
            Expanded(
              child: Center(
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.orange),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _videoTracks.length,
                itemBuilder: (BuildContext context, int index) {
                  final VideoTrack track = _videoTracks[index];
                  return _buildVideoTrackTile(track);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoTrackTile(VideoTrack track) {
    final bool isSelected = track.isSelected && !_isAutoQuality;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected ? Colors.green : Colors.grey,
          child: Icon(isSelected ? Icons.check : Icons.hd, color: Colors.white),
        ),
        title: Text(
          _getTrackLabel(track),
          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('ID: ${track.id}'),
            if (track.width != null && track.height != null)
              Text('Resolution: ${track.width}x${track.height}'),
            Text('Bitrate: ${_formatBitrate(track.bitrate)}'),
            if (track.frameRate != null)
              Text('Frame Rate: ${track.frameRate!.toStringAsFixed(2)} fps'),
            if (track.codec != null) Text('Codec: ${track.codec}'),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.radio_button_checked, color: Colors.green)
            : const Icon(Icons.radio_button_unchecked),
        onTap: isSelected ? null : () => _selectVideoTrack(track),
      ),
    );
  }
}
