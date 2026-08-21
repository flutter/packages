// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// A demo of playing DRM-protected streams.
///
/// The DRM configuration types come from the platform implementation packages
/// rather than from video_player itself, so this file imports them directly.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_android/video_player_android.dart';
import 'package:video_player_avfoundation/video_player_avfoundation.dart';

/// A publicly available Axinom test stream and its license endpoints.
const String _widevineStreamUrl =
    'https://media.axprod.net/TestVectors/Dash/protected_dash_1080p_h264_singlekey/manifest.mpd';
const String _widevineLicenseUrl = 'https://drm-widevine-licensing.axprod.net/AcquireLicense';
const String _fairPlayStreamUrl =
    'https://media.axprod.net/TestVectors/Hls/protected_hls_1080p_h264_singlekey/manifest.m3u8';
const String _fairPlayLicenseUrl = 'https://drm-fairplay-licensing.axprod.net/AcquireLicense';
const String _fairPlayCertificateUrl = 'https://vtb.axinom.com/FPScert/fairplay.cer';

/// The entitlement token that the Axinom test license servers expect.
const String _axinomTokenHeaderName = 'X-AxDRM-Message';
const String _axinomToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJ2ZXJzaW9uIjogMSwKICAiY29tX2tleV9pZCI6'
    'ICI2OWU1NDA4OC1lOWUwLTQ1MzAtOGMxYS0xZWI2ZGNkMGQxNGUiLAogICJtZXNzYWdlIjogewogICAg'
    'InR5cGUiOiAiZW50aXRsZW1lbnRfbWVzc2FnZSIsCiAgICAidmVyc2lvbiI6IDIsCiAgICAibGljZW5z'
    'ZSI6IHsKICAgICAgImFsbG93X3BlcnNpc3RlbmNlIjogdHJ1ZQogICAgfSwKICAgICJjb250ZW50X2tl'
    'eXNfc291cmNlIjogewogICAgICAiaW5saW5lIjogWwogICAgICAgIHsKICAgICAgICAgICJpZCI6ICI0'
    'MDYwYTg2NS04ODc4LTQyNjctOWNiZi05MWFlNWJhZTFlNzIiLAogICAgICAgICAgImVuY3J5cHRlZF9r'
    'ZXkiOiAid3QzRW51dVI1UkFybjZBRGYxNkNCQT09IiwKICAgICAgICAgICJ1c2FnZV9wb2xpY3kiOiAi'
    'UG9saWN5IEEiCiAgICAgICAgfQogICAgICBdCiAgICB9LAogICAgImNvbnRlbnRfa2V5X3VzYWdlX3Bv'
    'bGljaWVzIjogWwogICAgICB7CiAgICAgICAgIm5hbWUiOiAiUG9saWN5IEEiLAogICAgICAgICJwbGF5'
    'cmVhZHkiOiB7CiAgICAgICAgICAibWluX2RldmljZV9zZWN1cml0eV9sZXZlbCI6IDE1MCwKICAgICAg'
    'ICAgICJwbGF5X2VuYWJsZXJzIjogWwogICAgICAgICAgICAiNzg2NjI3RDgtQzJBNi00NEJFLThGODgt'
    'MDhBRTI1NUIwMUE3IgogICAgICAgICAgXQogICAgICAgIH0KICAgICAgfQogICAgXQogIH0KfQ.l8Pn'
    'ZznspJ6lnNmfAE9UQV532Ypzt1JXQkvrk8gFSRw';

/// Whether Widevine (as opposed to FairPlay) is the DRM system for the current
/// platform.
bool get _isWidevinePlatform => defaultTargetPlatform == TargetPlatform.android;

class DrmDemo extends StatefulWidget {
  const DrmDemo({super.key});

  @override
  State<DrmDemo> createState() => _DrmDemoState();
}

class _DrmDemoState extends State<DrmDemo> {
  VideoPlayerController? _controller;
  String? _error;
  bool _isInitializing = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    setState(() {
      _isInitializing = true;
      _error = null;
    });

    // Widevine and FairPlay use different test streams, since a single stream
    // isn't packaged for both.
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(_isWidevinePlatform ? _widevineStreamUrl : _fairPlayStreamUrl),
      drmConfiguration: _drmConfiguration(),
      // DRM-protected frames currently only render in platform view mode; see
      // the video_player README for details.
      viewType: VideoViewType.platformView,
    );

    try {
      await controller.initialize();
    } catch (e) {
      await controller.dispose();
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _error = e.toString();
        });
      }
      return;
    }

    if (!mounted) {
      await controller.dispose();
      return;
    }

    final VideoPlayerController? oldController = _controller;
    setState(() {
      _controller = controller;
      _isInitializing = false;
    });
    await oldController?.dispose();
    await controller.play();
  }

  VideoDrmConfiguration _drmConfiguration() {
    const licenseHeaders = <String, String>{_axinomTokenHeaderName: _axinomToken};
    if (_isWidevinePlatform) {
      return WidevineDrmConfiguration(
        licenseUri: Uri.parse(_widevineLicenseUrl),
        licenseHeaders: licenseHeaders,
      );
    }
    return FairPlayDrmConfiguration(
      certificateUri: Uri.parse(_fairPlayCertificateUrl),
      licenseUri: Uri.parse(_fairPlayLicenseUrl),
      licenseHeaders: licenseHeaders,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DRM demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _isWidevinePlatform
                  ? 'Playing a Widevine-protected DASH stream.'
                  : 'Playing a FairPlay-protected HLS stream.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isInitializing ? null : _play,
              child: const Text('Play protected stream'),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildPlayer()),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }
    final String? error = _error;
    if (error != null) {
      return Center(child: Text('Playback failed:\n$error'));
    }
    final VideoPlayerController? controller = _controller;
    if (controller == null) {
      return const Center(child: Text('Not playing.'));
    }
    return Center(
      child: AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)),
    );
  }
}
