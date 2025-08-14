// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Demo page showing how to retrieve and display available audio tracks
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

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    // Apple's test HLS stream with multiple audio tracks
    const String videoUrl =
        'https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8';

    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    try {
      await _controller!.initialize();
      setState(() {
        // Video initialized
      });

      // Get audio tracks after initialization
      await _getAudioTracks();
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }

  Future<void> _getAudioTracks() async {
    if (_controller == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<VideoAudioTrack> tracks = await _controller!.getAudioTracks();
      setState(() {
        _audioTracks = tracks;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error getting audio tracks: $e');
      setState(() {
        _isLoading = false;
      });
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
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          // Video Player
          if (_controller != null && _controller!.value.isInitialized)
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )
          else
            const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Video Controls
          if (_controller != null && _controller!.value.isInitialized)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_controller!.value.isPlaying) {
                        _controller!.pause();
                      } else {
                        _controller!.play();
                      }
                    });
                  },
                  icon: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
                IconButton(
                  onPressed: _getAudioTracks,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Audio Tracks',
                ),
              ],
            ),

          const Divider(),

          // Audio Tracks Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text(
                        'Available Audio Tracks:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_audioTracks.isEmpty && !_isLoading)
                    const Text(
                      'No audio tracks found or video not initialized.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _audioTracks.length,
                        itemBuilder: (BuildContext context, int index) {
                          final VideoAudioTrack track = _audioTracks[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: track.isSelected
                                    ? Colors.green
                                    : Colors.grey,
                                child: Icon(
                                  track.isSelected
                                      ? Icons.check
                                      : Icons.audiotrack,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                track.label,
                                style: TextStyle(
                                  fontWeight: track.isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('ID: ${track.id}'),
                                  Text('Language: ${track.language}'),
                                ],
                              ),
                              trailing: track.isSelected
                                  ? const Chip(
                                      label: Text('Selected'),
                                      backgroundColor: Colors.green,
                                      labelStyle:
                                          TextStyle(color: Colors.white),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
