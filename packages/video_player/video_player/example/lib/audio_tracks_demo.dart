// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  // Sample video URLs with multiple audio tracks
  static const List<String> _sampleVideos = <String>[
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8',
    // Add HLS stream with multiple audio tracks if available
    'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
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

      final VideoPlayerController controller = VideoPlayerController.networkUrl(
        Uri.parse(_sampleVideos[_selectedVideoIndex]),
      );
      _controller = controller;

      await controller.initialize();

      // Get audio tracks after initialization
      await _loadAudioTracks();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
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
      final List<VideoAudioTrack> tracks = await controller.getAudioTracks();
      setState(() {
        _audioTracks = tracks;
      });
    } catch (e) {
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

      // Add a small delay to allow ExoPlayer to process the track selection change
      // This is needed because ExoPlayer's track selection update is asynchronous
      await Future<void>.delayed(const Duration(milliseconds: 100));

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to select audio track: $e')));
    }
  }

  @override
  void dispose() {
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
            child: DropdownButtonFormField<int>(
              value: _selectedVideoIndex,
              decoration: const InputDecoration(
                labelText: 'Select Video',
                border: OutlineInputBorder(),
              ),
              items:
                  _sampleVideos.asMap().entries.map((MapEntry<int, String> entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text('Video ${entry.key + 1}'),
                    );
                  }).toList(),
              onChanged: (int? value) {
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

    if (_error != null) {
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
          setState(() {});
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
            if (track.sampleRate != null) Text('Sample Rate: ${track.sampleRate} Hz'),
            if (track.channelCount != null) Text('Channels: ${track.channelCount}'),
          ],
        ),
        trailing:
            track.isSelected
                ? const Icon(Icons.radio_button_checked, color: Colors.green)
                : const Icon(Icons.radio_button_unchecked),
        onTap: track.isSelected ? null : () => _selectAudioTrack(track.id),
      ),
    );
  }
}
