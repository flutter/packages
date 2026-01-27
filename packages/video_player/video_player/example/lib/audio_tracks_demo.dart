// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// A demo page that showcases audio track functionality.
class AudioTracksDemo extends StatefulWidget {
  /// Creates an AudioTracksDemo widget.
  const AudioTracksDemo({super.key});

  @override
  State<AudioTracksDemo> createState() => _AudioTracksDemoState();
}

class _AudioTracksDemoState extends State<AudioTracksDemo> {
  VideoPlayerController? _controller;
  List<VideoAudioTrack> _audioTracks = <VideoAudioTrack>[];
  bool _isLoading = false;
  String? _error;

  // Track previous state to detect relevant changes
  bool _wasPlaying = false;
  bool _wasInitialized = false;

  // Sample video URLs with multiple audio tracks
  static const List<String> _sampleVideos = <String>[
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8',
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

      // Get audio tracks after initialization
      await _loadAudioTracks();
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

  Future<void> _loadAudioTracks() async {
    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    try {
      final List<VideoAudioTrack> tracks = await _controller!.getAudioTracks();
      if (!mounted) {
        return;
      }
      setState(() {
        _audioTracks = tracks;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Failed to load audio tracks: $e';
      });
    }
  }

  Future<void> _selectAudioTrack(String trackId) async {
    final VideoPlayerController? controller = _controller;
    if (controller == null) {
      return;
    }

    try {
      await controller.selectAudioTrack(trackId);

      // Reload tracks to update selection status
      await _loadAudioTracks();

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Selected audio track: $trackId')));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to select audio track: $e')),
      );
    }
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
        title: const Text('Audio Tracks Demo'),
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
              dropdownMenuEntries: _sampleVideos.indexed.map((
                (int, String) record,
              ) {
                final (int index, _) = record;
                return DropdownMenuEntry<int>(
                  value: index,
                  label: 'Video ${index + 1}',
                );
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

          // Audio tracks list
          Expanded(flex: 3, child: _buildAudioTracksList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAudioTracks,
        tooltip: 'Refresh Audio Tracks',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error case final String error?) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeVideo,
              child: const Text('Retry'),
            ),
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

  Widget _buildAudioTracksList() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.audiotrack),
              const SizedBox(width: 8),
              Text(
                'Audio Tracks (${_audioTracks.length})',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_audioTracks.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No audio tracks available.\nTry loading a video with multiple audio tracks.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _audioTracks.length,
                itemBuilder: (BuildContext context, int index) {
                  final VideoAudioTrack track = _audioTracks[index];
                  return _buildAudioTrackTile(track);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAudioTrackTile(VideoAudioTrack track) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: track.isSelected ? Colors.green : Colors.grey,
          child: Icon(
            track.isSelected ? Icons.check : Icons.audiotrack,
            color: Colors.white,
          ),
        ),
        title: Text(
          track.label.isNotEmpty ? track.label : 'Track ${track.id}',
          style: TextStyle(
            fontWeight: track.isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('ID: ${track.id}'),
            Text('Language: ${track.language}'),
            if (track.codec != null) Text('Codec: ${track.codec}'),
            if (track.bitrate != null) Text('Bitrate: ${track.bitrate} bps'),
            if (track.sampleRate != null)
              Text('Sample Rate: ${track.sampleRate} Hz'),
            if (track.channelCount != null)
              Text('Channels: ${track.channelCount}'),
          ],
        ),
        trailing: track.isSelected
            ? const Icon(Icons.radio_button_checked, color: Colors.green)
            : const Icon(Icons.radio_button_unchecked),
        onTap: track.isSelected ? null : () => _selectAudioTrack(track.id),
      ),
    );
  }
}
