// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Entry screen for all DRM demo pages.
class DrmDemosHome extends StatelessWidget {
  /// Creates a DRM demos home screen.
  const DrmDemosHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DRM Demos')),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.android),
            title: const Text('Android Widevine Demo'),
            subtitle: const Text('MPEG-DASH + Widevine license server'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push<AndroidWidevineDrmDemo>(
                context,
                MaterialPageRoute<AndroidWidevineDrmDemo>(
                  builder: (BuildContext context) =>
                      const AndroidWidevineDrmDemo(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_iphone),
            title: const Text('iOS FairPlay Demo'),
            subtitle: const Text(
              'HLS + FairPlay certificate and license server',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push<IosFairPlayDrmDemo>(
                context,
                MaterialPageRoute<IosFairPlayDrmDemo>(
                  builder: (BuildContext context) => const IosFairPlayDrmDemo(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Demo screen for Android Widevine playback.
class AndroidWidevineDrmDemo extends StatelessWidget {
  /// Creates an Android Widevine demo.
  const AndroidWidevineDrmDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DrmDemoScreen(mode: _DrmMode.widevine);
  }
}

/// Demo screen for iOS FairPlay playback.
class IosFairPlayDrmDemo extends StatelessWidget {
  /// Creates an iOS FairPlay demo.
  const IosFairPlayDrmDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DrmDemoScreen(mode: _DrmMode.fairplay);
  }
}

enum _DrmMode { widevine, fairplay }

class _DrmDemoScreen extends StatefulWidget {
  const _DrmDemoScreen({required this.mode});

  final _DrmMode mode;

  @override
  State<_DrmDemoScreen> createState() => _DrmDemoScreenState();
}

class _DrmDemoScreenState extends State<_DrmDemoScreen> {
  static const String _widevineStreamUrl =
      'https://media.axprod.net/TestVectors/Dash/protected_dash_1080p_h264_singlekey/manifest.mpd';
  static const String _widevineLicenseUrl =
      'https://drm-widevine-licensing.axprod.net/AcquireLicense';
  static const String _fairPlayStreamUrl =
      'https://media.axprod.net/TestVectors/Hls/protected_hls_1080p_h264_singlekey/manifest.m3u8';
  static const String _fairPlayLicenseUrl =
      'https://drm-fairplay-licensing.axprod.net/AcquireLicense';
  static const String _fairPlayCertificateUrl =
      'https://vtb.axinom.com/FPScert/fairplay.cer';
  static final String _axinomToken = <String>[
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJ2ZXJzaW9uIjogMSwKICAiY29tX2tleV9pZCI6',
    'ICI2OWU1NDA4OC1lOWUwLTQ1MzAtOGMxYS0xZWI2ZGNkMGQxNGUiLAogICJtZXNzYWdlIjogewogICAg',
    'InR5cGUiOiAiZW50aXRsZW1lbnRfbWVzc2FnZSIsCiAgICAidmVyc2lvbiI6IDIsCiAgICAibGljZW5z',
    'ZSI6IHsKICAgICAgImFsbG93X3BlcnNpc3RlbmNlIjogdHJ1ZQogICAgfSwKICAgICJjb250ZW50X2tl',
    'eXNfc291cmNlIjogewogICAgICAiaW5saW5lIjogWwogICAgICAgIHsKICAgICAgICAgICJpZCI6ICI0',
    'MDYwYTg2NS04ODc4LTQyNjctOWNiZi05MWFlNWJhZTFlNzIiLAogICAgICAgICAgImVuY3J5cHRlZF9r',
    'ZXkiOiAid3QzRW51dVI1UkFybjZBRGYxNkNCQT09IiwKICAgICAgICAgICJ1c2FnZV9wb2xpY3kiOiAi',
    'UG9saWN5IEEiCiAgICAgICAgfQogICAgICBdCiAgICB9LAogICAgImNvbnRlbnRfa2V5X3VzYWdlX3Bv',
    'bGljaWVzIjogWwogICAgICB7CiAgICAgICAgIm5hbWUiOiAiUG9saWN5IEEiLAogICAgICAgICJwbGF5',
    'cmVhZHkiOiB7CiAgICAgICAgICAibWluX2RldmljZV9zZWN1cml0eV9sZXZlbCI6IDE1MCwKICAgICAg',
    'ICAgICJwbGF5X2VuYWJsZXJzIjogWwogICAgICAgICAgICAiNzg2NjI3RDgtQzJBNi00NEJFLThGODgt',
    'MDhBRTI1NUIwMUE3IgogICAgICAgICAgXQogICAgICAgIH0KICAgICAgfQogICAgXQogIH0KfQ.l8Pn',
    'ZznspJ6lnNmfAE9UQV532Ypzt1JXQkvrk8gFSRw',
  ].join();

  final TextEditingController _streamUrlController = TextEditingController();
  final TextEditingController _licenseUrlController = TextEditingController();
  final TextEditingController _headersController = TextEditingController();
  final TextEditingController _certificateUrlController =
      TextEditingController();
  final TextEditingController _contentIdController = TextEditingController();

  VideoPlayerController? _controller;
  VideoViewType _viewType = VideoViewType.textureView;
  bool _isInitializing = false;
  String? _error;

  bool get _isWidevineDemo => widget.mode == _DrmMode.widevine;

  @override
  void initState() {
    super.initState();
    _applyDefaults();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerValueChanged);
    _controller?.dispose();
    _streamUrlController.dispose();
    _licenseUrlController.dispose();
    _headersController.dispose();
    _certificateUrlController.dispose();
    _contentIdController.dispose();
    super.dispose();
  }

  void _applyDefaults() {
    _viewType = _isWidevineDemo
        ? VideoViewType.platformView
        : VideoViewType.textureView;

    if (_isWidevineDemo) {
      _streamUrlController.text = _widevineStreamUrl;
      _licenseUrlController.text = _widevineLicenseUrl;
    } else {
      _streamUrlController.text = _fairPlayStreamUrl;
      _licenseUrlController.text = _fairPlayLicenseUrl;
      _certificateUrlController.text = _fairPlayCertificateUrl;
      _contentIdController.text = '';
    }

    _headersController.text = 'X-AxDRM-Message: $_axinomToken';

    setState(() {
      _error = null;
    });
  }

  void _onControllerValueChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isInitializing = true;
      _error = null;
    });

    try {
      final Uri streamUri = _parseUri(
        _streamUrlController.text,
        fieldName: 'Stream URL',
      );
      final Uri licenseUri = _parseUri(
        _licenseUrlController.text,
        fieldName: 'License URL',
      );
      final Map<String, String> licenseHeaders = _parseHeaders(
        _headersController.text,
      );

      final VideoDrmConfiguration drmConfiguration;
      if (_isWidevineDemo) {
        drmConfiguration = WidevineDrmConfiguration(
          licenseUri: licenseUri,
          licenseHeaders: licenseHeaders,
        );
      } else {
        final Uri certificateUri = _parseUri(
          _certificateUrlController.text,
          fieldName: 'Certificate URL',
        );
        final String trimmedContentId = _contentIdController.text.trim();

        drmConfiguration = FairPlayDrmConfiguration(
          certificateUri: certificateUri,
          licenseUri: licenseUri,
          licenseHeaders: licenseHeaders,
          contentId: trimmedContentId.isEmpty ? null : trimmedContentId,
        );
      }

      final controller = VideoPlayerController.networkUrl(
        streamUri,
        drmConfiguration: drmConfiguration,
        viewType: _viewType,
      );
      controller.addListener(_onControllerValueChanged);

      await controller.initialize();
      await controller.setLooping(true);

      final VideoPlayerController? oldController = _controller;
      oldController?.removeListener(_onControllerValueChanged);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitializing = false;
      });

      await oldController?.dispose();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isInitializing = false;
        _error = e.toString();
      });
    }
  }

  Uri _parseUri(String rawValue, {required String fieldName}) {
    final String value = rawValue.trim();
    final Uri? uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw FormatException('$fieldName is not a valid absolute URI.');
    }
    return uri;
  }

  Map<String, String> _parseHeaders(String rawHeaders) {
    final headers = <String, String>{};

    for (final String line in rawHeaders.split('\n')) {
      final String trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final int splitIndex = trimmed.indexOf(':');
      if (splitIndex < 1 || splitIndex == trimmed.length - 1) {
        throw FormatException(
          'Header line "$line" must be in the format "Header-Name: value".',
        );
      }

      final String name = trimmed.substring(0, splitIndex).trim();
      final String value = trimmed.substring(splitIndex + 1).trim();
      if (name.isEmpty || value.isEmpty) {
        throw FormatException(
          'Header line "$line" must be in the format "Header-Name: value".',
        );
      }

      headers[name] = value;
    }

    return headers;
  }

  Future<void> _disposePlayer() async {
    final VideoPlayerController? controller = _controller;
    controller?.removeListener(_onControllerValueChanged);
    await controller?.dispose();

    if (!mounted) {
      return;
    }
    setState(() {
      _controller = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isWidevineDemo
        ? 'Android Widevine DRM Demo'
        : 'iOS FairPlay DRM Demo';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildPlatformHintCard(),
          const SizedBox(height: 12),
          TextField(
            controller: _streamUrlController,
            decoration: const InputDecoration(
              labelText: 'Stream URL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _licenseUrlController,
            decoration: const InputDecoration(
              labelText: 'License URL',
              border: OutlineInputBorder(),
            ),
          ),
          if (!_isWidevineDemo) ...<Widget>[
            const SizedBox(height: 12),
            TextField(
              controller: _certificateUrlController,
              decoration: const InputDecoration(
                labelText: 'FairPlay certificate URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentIdController,
              decoration: const InputDecoration(
                labelText: 'Content ID override (optional)',
                border: OutlineInputBorder(),
                helperText: 'Leave empty to derive from skd:// URI in HLS key.',
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _headersController,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'License headers',
              helperText: 'One per line: Header-Name: value',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<VideoViewType>(
            value: _viewType,
            decoration: const InputDecoration(
              labelText: 'View type',
              helperText: 'Applied on next initialize.',
              border: OutlineInputBorder(),
            ),
            items: const <DropdownMenuItem<VideoViewType>>[
              DropdownMenuItem<VideoViewType>(
                value: VideoViewType.textureView,
                child: Text('Texture View'),
              ),
              DropdownMenuItem<VideoViewType>(
                value: VideoViewType.platformView,
                child: Text('Platform View'),
              ),
            ],
            onChanged: (VideoViewType? value) {
              if (value == null) {
                return;
              }
              setState(() {
                _viewType = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.icon(
                onPressed: _isInitializing ? null : _initializeVideo,
                icon: const Icon(Icons.play_circle_fill),
                label: Text(_isInitializing ? 'Initializing...' : 'Initialize'),
              ),
              OutlinedButton.icon(
                onPressed: _isInitializing ? null : _applyDefaults,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset defaults'),
              ),
              TextButton.icon(
                onPressed: _controller == null ? null : _disposePlayer,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Dispose'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPlayerSection(),
        ],
      ),
    );
  }

  Widget _buildPlatformHintCard() {
    final isSupportedPlatform = _isWidevineDemo
        ? defaultTargetPlatform == TargetPlatform.android
        : defaultTargetPlatform == TargetPlatform.iOS;

    final Color color = isSupportedPlatform
        ? Colors.green.shade50
        : Colors.amber.shade50;
    final Color borderColor = isSupportedPlatform
        ? Colors.green.shade300
        : Colors.amber.shade300;

    final message = isSupportedPlatform
        ? 'This platform matches the selected DRM demo.'
        : (_isWidevineDemo
              ? 'Run this demo on Android for Widevine playback.'
              : 'Run this demo on iOS for FairPlay playback.');
    final subtitle = _isWidevineDemo
        ? 'Widevine defaults to Platform View for better device compatibility.'
        : 'FairPlay defaults to Texture View.';

    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          isSupportedPlatform ? Icons.check_circle : Icons.info_outline,
          color: isSupportedPlatform
              ? Colors.green.shade700
              : Colors.amber.shade900,
        ),
        title: Text(message),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildPlayerSection() {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error case final String error?) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Initialization failed:\n$error'),
        ),
      );
    }

    final VideoPlayerController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Initialize the player to start DRM playback.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            VideoProgressIndicator(controller, allowScrubbing: true),
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                  },
                  icon: Icon(
                    controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                  ),
                ),
                Text(controller.value.isPlaying ? 'Playing' : 'Paused'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
