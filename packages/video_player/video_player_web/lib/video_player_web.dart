// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_util';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:web/web.dart' as web;

import 'src/browser_detection.dart';
import 'src/video_player.dart';

/// The web implementation of [VideoPlayerPlatform].
///
/// This class implements the `package:video_player` functionality for the web.
class VideoPlayerPlugin extends VideoPlayerPlatform {
  /// Registers this class as the default instance of [VideoPlayerPlatform].
  static void registerWith(Registrar registrar) {
    VideoPlayerPlatform.instance = VideoPlayerPlugin();
  }

  // Map of textureId -> VideoPlayer instances
  final Map<int, VideoPlayer> _videoPlayers = <int, VideoPlayer>{};

  // Simulate the native "textureId".
  int _textureCounter = 1;

  @override
  Future<void> init() async {
    return _disposeAllPlayers();
  }

  @override
  Future<void> dispose(int textureId) async {
    _player(textureId).dispose();

    _videoPlayers.remove(textureId);
    return;
  }

  void _disposeAllPlayers() {
    for (final VideoPlayer videoPlayer in _videoPlayers.values) {
      videoPlayer.dispose();
    }
    _videoPlayers.clear();
  }

  @override
  Future<int> create(DataSource dataSource) async {
    final int textureId = _textureCounter++;

    late String uri;
    switch (dataSource.sourceType) {
      case DataSourceType.network:
        // Do NOT modify the incoming uri, it can be a Blob, and Safari doesn't
        // like blobs that have changed.
        uri = dataSource.uri ?? '';
      case DataSourceType.asset:
        String assetUrl = dataSource.asset!;
        if (dataSource.package != null && dataSource.package!.isNotEmpty) {
          assetUrl = 'packages/${dataSource.package}/$assetUrl';
        }
        assetUrl = ui_web.assetManager.getAssetUrl(assetUrl);
        uri = assetUrl;
      case DataSourceType.file:
        return Future<int>.error(UnimplementedError(
            'web implementation of video_player cannot play local files'));
      case DataSourceType.contentUri:
        return Future<int>.error(UnimplementedError(
            'web implementation of video_player cannot play content uri'));
    }

    final web.HTMLVideoElement videoElement = _createElement(textureId);

    final VideoPlayer player = VideoPlayer(videoElement: videoElement)
      ..initialize(
        src: uri,
      );

    _videoPlayers[textureId] = player;

    return textureId;
  }

  web.VideoElement _createElement(int textureId) {
    final web.VideoElement videoElement = web.HTMLVideoElement()
      ..id = 'videoElement-$textureId'
      ..style.border = 'none'
      ..style.height = '100%'
      ..style.width = '100%'
      ..style.pointerEvents = 'none';

    if (mode != VideoRenderMode.html) {
      videoElement.crossOrigin = 'anonymous';
    }

    return videoElement;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {
    return _player(textureId).setLooping(looping);
  }

  @override
  Future<void> play(int textureId) async {
    return _player(textureId).play();
  }

  @override
  Future<void> pause(int textureId) async {
    return _player(textureId).pause();
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {
    return _player(textureId).setVolume(volume);
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    return _player(textureId).setPlaybackSpeed(speed);
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    return _player(textureId).seekTo(position);
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    return _player(textureId).getPosition();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return _player(textureId).events;
  }

  @override
  Future<void> setWebOptions(int textureId, VideoPlayerWebOptions options) {
    return _player(textureId).setOptions(options);
  }

  // Retrieves a [VideoPlayer] by its internal `id`.
  // It must have been created earlier from the [create] method.
  VideoPlayer _player(int id) {
    return _videoPlayers[id]!;
  }

  @override
  Widget buildView(int textureId) {
    return _AdapterVideoPlayerRenderer(
        key: Key(textureId.toString()),
        textureId: textureId,
        player: _player(textureId),
        mode: mode);
  }

  /// Sets the audio mode to mix with other sources (ignored)
  @override
  Future<void> setMixWithOthers(bool mixWithOthers) => Future<void>.value();

  /// The mode to render the video with.
  VideoRenderMode mode = VideoRenderMode.auto;
}

class _AdapterVideoPlayerRenderer extends StatefulWidget {
  const _AdapterVideoPlayerRenderer(
      {required this.textureId,
      required this.player,
      required this.mode,
      super.key});

  final int textureId;
  final VideoPlayer player;
  final VideoRenderMode mode;

  @override
  State createState() => _AdapterVideoPlayerRendererState();
}

class _AdapterVideoPlayerRendererState
    extends State<_AdapterVideoPlayerRenderer> {
  _AdapterVideoPlayerRendererState() {
    setDesiredModeRef = setDesiredMode.toJS;
  }

  late JSFunction setDesiredModeRef;

  VideoRenderMode _mode = VideoRenderMode.html;

  VideoRenderMode get mode {
    return _mode;
  }

  set mode(VideoRenderMode mode) {
    if (_mode != mode) {
      _mode = mode;
      updateVideoElementStyle();
      if (mounted) {
        if (widget.player.videoElement.parentElement == null &&
            mode != VideoRenderMode.html) {
          web.document.body!.appendChild(widget.player.videoElement);
        }
      }
    }
  }

  bool get rendererCanvasKit {
    return hasProperty(web.window, 'flutterCanvasKit');
  }

  @override
  void initState() {
    super.initState();

    // if auto rendering mode, and in canvaskit renderer, always start in
    // texture mode to reduce the number of platform layers used for videos
    // that are not playing
    mode = widget.mode == VideoRenderMode.auto
        ? (rendererCanvasKit ? VideoRenderMode.texture : VideoRenderMode.html)
        : widget.mode;

    if (widget.mode == VideoRenderMode.auto) {
      widget.player.videoElement
          .addEventListener('play', setDesiredModeRef, false.toJS);
      widget.player.videoElement
          .addEventListener('pause', setDesiredModeRef, false.toJS);
    }
  }

  // when in auto mode, will optimize based off of the browser
  void setDesiredMode(web.Event event) {
    VideoRenderMode desiredMode;
    final web.HTMLVideoElement element = widget.player.videoElement;
    isPlaying = !!(!element.paused && !element.ended && element.readyState > 2);

    if (isPlaying && (isSafari || isFirefox)) {
      desiredMode = VideoRenderMode.canvas;
    } else {
      desiredMode = VideoRenderMode.texture;
    }
    if (desiredMode != mode) {
      setState(() {
        mode = desiredMode;
      });
    }
  }

  bool isPlaying = true;

  @override
  void dispose() {
    super.dispose();
    events?.cancel();

    if (widget.mode == VideoRenderMode.auto) {
      widget.player.videoElement.removeEventListener('play', setDesiredModeRef);
      widget.player.videoElement
          .removeEventListener('pause', setDesiredModeRef);
    }

    if (widget.player.videoElement.parentElement != null) {
      widget.player.videoElement.parentElement!
          .removeChild(widget.player.videoElement);
    }
  }

  StreamSubscription<VideoEvent>? events;

  void updateVideoElementStyle() {
    switch (mode) {
      case VideoRenderMode.html:
        widget.player.videoElement
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.opacity = '1'
          ..style.position = 'relative';
      case VideoRenderMode.auto:
      case VideoRenderMode.texture:
      case VideoRenderMode.canvas:
        widget.player.videoElement
          ..style.top = '0px'
          ..style.left = '0px'
          ..style.width = '0px'
          ..style.height = '0px'
          ..style.opacity = '0'
          ..style.zIndex = '-1'
          ..style.position = 'absolute';
    }
  }

  /// Builds a view that will render the video player using an HtmlElementView
  Widget buildHtmlView(int textureId, VideoPlayer player) {
    return HtmlElementView.fromTagName(
        tagName: 'div',
        onElementCreated: (Object? element) {
          final web.HTMLElement tag = element! as web.HTMLElement;
          tag.appendChild(player.videoElement);
        });
  }

  Widget buildTextureView(int textureId, VideoPlayer player) {
    player.videoElement.style.top = '0px';
    player.videoElement.style.left = '0px';
    player.videoElement.style.width = '0px';
    player.videoElement.style.height = '0px';
    player.videoElement.style.opacity = '0';
    player.videoElement.style.zIndex = '-1';
    player.videoElement.style.position = 'absolute';
    return _TextureVideoPlayerRenderer(
        element: player.videoElement, paused: !isPlaying);
  }

  Widget buildCanvasView(int textureId, VideoPlayer player) {
    player.videoElement.style.top = '0px';
    player.videoElement.style.left = '0px';
    player.videoElement.style.width = '0px';
    player.videoElement.style.height = '0px';
    player.videoElement.style.opacity = '0';
    player.videoElement.style.zIndex = '-1';
    player.videoElement.style.position = 'absolute';
    return _CanvasVideoPlayerRenderer(
        element: player.videoElement, paused: !isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return switch (mode) {
      VideoRenderMode.html => buildHtmlView(widget.textureId, widget.player),
      VideoRenderMode.texture =>
        buildTextureView(widget.textureId, widget.player),
      VideoRenderMode.canvas =>
        buildCanvasView(widget.textureId, widget.player),
      VideoRenderMode.auto =>
        Container(color: Colors.red) // This case should never happen
    };
  }
}

/// Determines whether the video uses a platform layer or renders into the canvas
enum VideoRenderMode {
  /// render the video with a a native layer so that it can interact with
  /// shaders and other flutter features, this will eliminate the need for
  /// platform layers, but may reduce performance in some browsers.
  texture,

  /// render the video into an html canvas element layer, this will reduce
  /// memory usage in browsers without zero copy bitmap operations.
  canvas,

  /// render the video with a platform layer to enable support for DRM
  html,

  /// automatically pick an appropriate rendering mode based on the active
  /// rendering engine and whether the video is playing, if using CanvasKit
  /// renderer, will attempt to minimize the number of platform layers used
  /// while optimizing performance. If using HTML renderer, will use a platform
  /// view.
  auto
}

abstract class _VideoPlayerRenderer extends StatefulWidget {
  const _VideoPlayerRenderer({required this.element, this.paused = true});

  final web.HTMLVideoElement element;
  final bool paused;
}

abstract class _VideoPlayerRendererState<T extends _VideoPlayerRenderer>
    extends State<T> {
  _VideoPlayerRendererState() {
    onSeekRef = onSeek.toJS;
  }

  @override
  void initState() {
    super.initState();

    frameCallback(0.toJS, 0.toJS);
    widget.element.addEventListener('seeked', onSeekRef);
  }

  late JSFunction onSeekRef;

  int? callbackID;

  void getFrame(web.HTMLVideoElement element) {
    callbackID =
        element.requestVideoFrameCallbackWithFallback(frameCallback.toJS);
  }

  void cancelFrame(web.HTMLVideoElement element) {
    if (callbackID != null) {
      element.cancelVideoFrameCallbackWithFallback(callbackID!);
    }
  }

  void onSeek(web.Event event) {
    capture();
  }

  void frameCallback(JSAny now, JSAny metadata) {
    final web.HTMLVideoElement element = widget.element;
    final bool isPlaying = !!(element.currentTime > 0 &&
        !element.paused &&
        !element.ended &&
        element.readyState > 2);

    // only capture frames if video is playing (optimization for RAF)
    if (isPlaying || element.readyState > 2 && lastFrameTime == null) {
      capture().then((_) async {
        getFrame(widget.element);
      });
    } else {
      getFrame(widget.element);
    }
  }

  web.ImageBitmap? source;
  num? lastFrameTime;

  Future<void> capture();

  @override
  void dispose() {
    cancelFrame(widget.element);
    super.dispose();
    source?.close();
    widget.element.removeEventListener('seeked', onSeekRef);
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.element != widget.element) {
      oldWidget.element.addEventListener('seeked', onSeekRef);
      widget.element.addEventListener('seeked', onSeekRef);
      cancelFrame(oldWidget.element);
      getFrame(widget.element);
    }
  }
}

class _TextureVideoPlayerRenderer extends _VideoPlayerRenderer {
  const _TextureVideoPlayerRenderer({required super.element, super.paused});

  @override
  State createState() => _TextureVideoPlayerRendererState();
}

class _TextureVideoPlayerRendererState
    extends _VideoPlayerRendererState<_TextureVideoPlayerRenderer> {
  @override
  Future<void> capture() async {
    if (!widget.paused || lastFrameTime != widget.element.currentTime) {
      lastFrameTime = widget.element.currentTime;
      try {
        final web.ImageBitmap newSource =
            await promiseToFuture<web.ImageBitmap>(
                web.window.createImageBitmap(widget.element));
        final ui.Image img = await ui_web.createImageFromImageBitmap(newSource);

        if (mounted) {
          setState(() {
            image?.dispose();
            source?.close();
            image = img;
            source = newSource;
          });
        }
      } on web.DOMException catch (err) {
        lastFrameTime = null;
        if (err.name == 'InvalidStateError') {
          // We don't have enough data yet, continue on
        } else {
          rethrow;
        }
      }
    }
  }

  ui.Image? image;

  @override
  void dispose() {
    super.dispose();
    image?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // adjust video element size to match dimensions of frame so we capture the correct sized bitmap
      final double dpr = MediaQuery.of(context).devicePixelRatio;

      final double maxWidth = constraints.maxWidth * dpr;
      final double maxHeight = constraints.maxHeight * dpr;
      final double videoWidth = widget.element.videoWidth.toDouble();
      final double videoHeight = widget.element.videoHeight.toDouble();

      widget.element.width =
          (videoWidth == 0 ? maxWidth : min(videoWidth, maxWidth)).ceil();
      widget.element.height =
          (videoHeight == 0 ? maxHeight : min(videoHeight, maxHeight)).ceil();
      if (image != null) {
        return RawImage(image: image);
      } else {
        return const ColoredBox(color: Colors.black);
      }
    });
  }
}

class _CanvasVideoPlayerRenderer extends _VideoPlayerRenderer {
  const _CanvasVideoPlayerRenderer({required super.element, super.paused});

  @override
  State createState() => _CanvasVideoPlayerRendererState();
}

class _CanvasVideoPlayerRendererState
    extends _VideoPlayerRendererState<_CanvasVideoPlayerRenderer> {
  @override
  Future<void> capture() async {
    lastFrameTime = widget.element.currentTime;
    if (canvas != null) {
      final web.CanvasRenderingContext2D context =
          canvas!.getContext('2d')! as web.CanvasRenderingContext2D;

      context.drawImage(widget.element, 0, 0, canvas!.width, canvas!.height);
    }
  }

  web.HTMLCanvasElement? canvas;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // adjust video element size to match dimensions of frame so we capture the correct sized bitmap
      final double dpr = MediaQuery.of(context).devicePixelRatio;

      final double maxWidth = constraints.maxWidth * dpr;
      final double maxHeight = constraints.maxHeight * dpr;
      final double videoWidth = widget.element.videoWidth.toDouble();
      final double videoHeight = widget.element.videoHeight.toDouble();

      widget.element.width =
          (videoWidth == 0 ? maxWidth : min(videoWidth, maxWidth)).ceil();
      widget.element.height =
          (videoHeight == 0 ? maxHeight : min(videoHeight, maxHeight)).ceil();

      if (canvas != null) {
        if (canvas!.width != widget.element.width ||
            canvas!.height != widget.element.height) {
          canvas!.width = widget.element.width;
          canvas!.height = widget.element.height;
          capture();
        }
      }

      return HtmlElementView.fromTagName(
          tagName: 'canvas',
          onElementCreated: (Object? element) {
            canvas = element! as web.HTMLCanvasElement;
            canvas!.width = widget.element.width;
            canvas!.height = widget.element.height;
            capture();
            getFrame(widget.element);
          });
    });
  }
}

typedef _VideoFrameRequestCallback = JSFunction;

extension _HTMLVideoElementRequestAnimationFrame on web.HTMLVideoElement {
  int requestVideoFrameCallbackWithFallback(
      _VideoFrameRequestCallback callback) {
    if (hasProperty(this, 'requestVideoFrameCallback')) {
      return requestVideoFrameCallback(callback);
    } else {
      return web.window.requestAnimationFrame((double num) {
        callback.callAsFunction(this, 0.toJS, 0.toJS);
      }.toJS);
    }
  }

  void cancelVideoFrameCallbackWithFallback(int callbackID) {
    if (hasProperty(this, 'requestVideoFrameCallback')) {
      cancelVideoFrameCallback(callbackID);
    } else {
      web.window.cancelAnimationFrame(callbackID);
    }
  }

  external int requestVideoFrameCallback(_VideoFrameRequestCallback callback);
  external void cancelVideoFrameCallback(int callbackID);
}
