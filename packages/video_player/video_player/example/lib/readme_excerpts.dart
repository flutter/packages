// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file is used to extract code samples for the README.md file.
// Run update-excerpts if you modify this file.

// ignore_for_file: public_member_api_docs

import 'package:video_player/video_player.dart';
// #docregion widevine
import 'package:video_player_android/video_player_android.dart';
// #enddocregion widevine
// #docregion fairplay
import 'package:video_player_avfoundation/video_player_avfoundation.dart';
// #enddocregion fairplay

Future<VideoPlayerController> widevineExample() async {
  // #docregion widevine
  final controller = VideoPlayerController.networkUrl(
    Uri.parse('https://example.com/protected.mpd'),
    drmConfiguration: WidevineDrmConfiguration(
      licenseUri: Uri.parse('https://example.com/license'),
      licenseHeaders: const <String, String>{'Authorization': 'Bearer ...'},
    ),
    viewType: VideoViewType.platformView,
  );
  await controller.initialize();
  await controller.play();
  // #enddocregion widevine
  return controller;
}

VideoPlayerController fairPlayExample() {
  // #docregion fairplay
  final controller = VideoPlayerController.networkUrl(
    Uri.parse('https://example.com/protected.m3u8'),
    drmConfiguration: FairPlayDrmConfiguration(
      certificateUri: Uri.parse('https://example.com/certificate'),
      licenseUri: Uri.parse('https://example.com/license'),
      licenseHeaders: const <String, String>{'Authorization': 'Bearer ...'},
    ),
    viewType: VideoViewType.platformView,
  );
  // #enddocregion fairplay
  return controller;
}
