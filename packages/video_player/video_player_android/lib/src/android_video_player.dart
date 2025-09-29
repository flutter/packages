// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'messages.g.dart';
import 'platform_view_player.dart';

/// The string to append a player ID to in order to construct the event channel
/// name for the event channel used to receive player state updates.
///
/// Must match the string used to create the EventChannel on the Java side.
const String _videoEventChannelNameBase = 'flutter.io/videoPlayer/videoEvents';

/// The non-test implementation of `_apiProvider`.
VideoPlayerInstanceApi _productionApiProvider(int playerId) {
  return VideoPlayerInstanceApi(messageChannelSuffix: playerId.toString());
}

/// An Android implementation of [VideoPlayerPlatform] that uses the
/// Pigeon-generated [VideoPlayerApi].
class AndroidVideoPlayer extends VideoPlayerPlatform {
  /// Creates a new Android video player implementation instance.
  AndroidVideoPlayer({
    @visibleForTesting AndroidVideoPlayerApi? pluginApi,
    @visibleForTesting
    VideoPlayerInstanceApi Function(int playerId)? playerApiProvider,
  }) : _api = pluginApi ?? AndroidVideoPlayerApi(),
       _playerApiProvider = playerApiProvider ?? _productionApiProvider;

  final AndroidVideoPlayerApi _api;
  // A method to create VideoPlayerInstanceApi instances, which can be
  //overridden for testing.
  final VideoPlayerInstanceApi Function(int playerId) _playerApiProvider;

  final Map<int, _PlayerInstance> _players = <int, _PlayerInstance>{};

  /// Registers this class as the default instance of [PathProviderPlatform].
  static void registerWith() {
    VideoPlayerPlatform.instance = AndroidVideoPlayer();
  }

  @override
  Future<void> init() {
    return _api.initialize();
  }

  @override
  Future<void> dispose(int playerId) async {
    final _PlayerInstance? player = _players.remove(playerId);
    await _api.dispose(playerId);
    await player?.dispose();
  }

  @override
  Future<int?> create(DataSource dataSource) {
    return createWithOptions(
      VideoCreationOptions(
        dataSource: dataSource,
        // Compatibility; "create" is always a textureView (createWithOptions
        // allows selecting).
        viewType: VideoViewType.textureView,
      ),
    );
  }

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    final DataSource dataSource = options.dataSource;

    String? uri;
    PlatformVideoFormat? formatHint;
    final Map<String, String> httpHeaders = dataSource.httpHeaders;
    final String? userAgent = _userAgentFromHeaders(httpHeaders);
    switch (dataSource.sourceType) {
      case DataSourceType.asset:
        final String? asset = dataSource.asset;
        if (asset == null) {
          throw ArgumentError(
            '"asset" must be non-null for an asset data source',
          );
        }
        final String key = await _api.getLookupKeyForAsset(
          asset,
          dataSource.package,
        );
        uri = 'asset:///$key';
      case DataSourceType.network:
        uri = dataSource.uri;
        formatHint = _platformVideoFormatFromVideoFormat(dataSource.formatHint);
      case DataSourceType.file:
      case DataSourceType.contentUri:
        uri = dataSource.uri;
    }
    if (uri == null) {
      throw ArgumentError('Unable to construct a video asset from $options');
    }
    final CreationOptions pigeonCreationOptions = CreationOptions(
      uri: uri,
      httpHeaders: httpHeaders,
      userAgent: userAgent,
      formatHint: formatHint,
    );

    final int playerId;
    final VideoPlayerViewState state;
    switch (options.viewType) {
      case VideoViewType.textureView:
        final TexturePlayerIds ids = await _api.createForTextureView(
          pigeonCreationOptions,
        );
        playerId = ids.playerId;
        state = VideoPlayerTextureViewState(textureId: ids.textureId);
      case VideoViewType.platformView:
        playerId = await _api.createForPlatformView(pigeonCreationOptions);
        state = const VideoPlayerPlatformViewState();
    }
    ensurePlayerInitialized(playerId, state);

    return playerId;
  }

  // Returns the user agent to use with ExoPlayer for the given headers.
  String? _userAgentFromHeaders(Map<String, String> httpHeaders) {
    // TODO(stuartmorgan): HTTP headers are case-insensitive, so this should be
    //  adjusted to find any entry where the key has a case-insensitive match.
    const String userAgentKey = 'User-Agent';
    // TODO(stuartmorgan): Investigate removing this. The use of a hard-coded
    //  default agent dates back to the original ExoPlayer implementation of the
    //  plugin, but it's not clear why the default isn't null, which would let
    //  ExoPlayer use its own default value.
    const String defaultUserAgent = 'ExoPlayer';
    return httpHeaders[userAgentKey] ?? defaultUserAgent;
  }

  /// Returns the player instance for [playerId], creating it if it doesn't
  /// already exist.
  @visibleForTesting
  void ensurePlayerInitialized(int playerId, VideoPlayerViewState viewState) {
    _players.putIfAbsent(playerId, () {
      final String eventChannelName = '$_videoEventChannelNameBase$playerId';
      return _PlayerInstance(
        _playerApiProvider(playerId),
        viewState,
        eventChannelName: eventChannelName,
      );
    });
  }

  @override
  Future<void> setLooping(int playerId, bool looping) {
    return _playerWith(id: playerId).setLooping(looping);
  }

  @override
  Future<void> play(int playerId) {
    return _playerWith(id: playerId).play();
  }

  @override
  Future<void> pause(int playerId) {
    return _playerWith(id: playerId).pause();
  }

  @override
  Future<void> setVolume(int playerId, double volume) {
    return _playerWith(id: playerId).setVolume(volume);
  }

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) {
    assert(speed > 0);

    return _playerWith(id: playerId).setPlaybackSpeed(speed);
  }

  @override
  Future<void> seekTo(int playerId, Duration position) {
    return _playerWith(id: playerId).seekTo(position);
  }

  @override
  Future<Duration> getPosition(int playerId) async {
    return _playerWith(id: playerId).getPosition();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) {
    return _playerWith(id: playerId).videoEvents();
  }

  @override
  Widget buildView(int playerId) {
    return buildViewWithOptions(VideoViewOptions(playerId: playerId));
  }

  @override
  Widget buildViewWithOptions(VideoViewOptions options) {
    final int playerId = options.playerId;
    final VideoPlayerViewState viewState = _playerWith(id: playerId).viewState;

    return switch (viewState) {
      VideoPlayerTextureViewState(:final int textureId) => Texture(
        textureId: textureId,
      ),
      VideoPlayerPlatformViewState() => PlatformViewPlayer(playerId: playerId),
    };
  }

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) {
    return _api.setMixWithOthers(mixWithOthers);
  }

  _PlayerInstance _playerWith({required int id}) {
    final _PlayerInstance? player = _players[id];
    return player ?? (throw StateError('No active player with ID $id.'));
  }

  PlatformVideoFormat? _platformVideoFormatFromVideoFormat(
    VideoFormat? format,
  ) {
    return switch (format) {
      VideoFormat.dash => PlatformVideoFormat.dash,
      VideoFormat.hls => PlatformVideoFormat.hls,
      VideoFormat.ss => PlatformVideoFormat.ss,
      VideoFormat.other => null,
      // Include a catch-all, since the enum comes from another package, so
      // this code must handle the possibility of a new enum value.
      _ => null,
    };
  }
}

/// An instance of a video player, corresponding to a single player ID in
/// [AndroidVideoPlayer].
class _PlayerInstance {
  /// Creates a new instance of [_PlayerInstance] corresponding to the given
  /// API instance.
  _PlayerInstance(
    this._api,
    this.viewState, {
    required String eventChannelName,
  }) {
    _eventChannel = EventChannel(eventChannelName);
    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      _onStreamEvent,
      onError: (Object e) {
        _eventStreamController.addError(e);
      },
    );
  }

  final VideoPlayerInstanceApi _api;
  late final EventChannel _eventChannel;
  final StreamController<VideoEvent> _eventStreamController =
      StreamController<VideoEvent>();
  late final StreamSubscription<dynamic> _eventSubscription;
  Timer? _bufferPollingTimer;
  int _lastBufferPosition = -1;

  final VideoPlayerViewState viewState;

  Future<void> setLooping(bool looping) {
    return _api.setLooping(looping);
  }

  Future<void> play() {
    return _api.play();
  }

  Future<void> pause() {
    return _api.pause();
  }

  Future<void> setVolume(double volume) {
    return _api.setVolume(volume);
  }

  Future<void> setPlaybackSpeed(double speed) {
    return _api.setPlaybackSpeed(speed);
  }

  Future<void> seekTo(Duration position) {
    return _api.seekTo(position.inMilliseconds);
  }

  Future<Duration> getPosition() async {
    return Duration(milliseconds: await _api.getCurrentPosition());
  }

  Stream<VideoEvent> videoEvents() {
    return _eventStreamController.stream;
  }

  Future<void> dispose() async {
    _bufferPollingTimer?.cancel();
    await _eventSubscription.cancel();
  }

  /// Sends a buffering update if the buffer position has changed since the
  /// last check.
  void _updateBufferingState(int bufferPosition) {
    if (bufferPosition != _lastBufferPosition) {
      _lastBufferPosition = bufferPosition;
      _eventStreamController.add(
        VideoEvent(
          eventType: VideoEventType.bufferingUpdate,
          buffered: _bufferRangeForPosition(bufferPosition),
        ),
      );
    }
  }

  void _onStreamEvent(dynamic event) {
    final Map<dynamic, dynamic> map = event as Map<dynamic, dynamic>;
    switch (map['event']) {
      case 'initialized':
        _eventStreamController.add(
          VideoEvent(
            eventType: VideoEventType.initialized,
            duration: Duration(milliseconds: map['duration'] as int),
            size: Size(
              (map['width'] as num).toDouble(),
              (map['height'] as num).toDouble(),
            ),
            rotationCorrection: map['rotationCorrection'] as int? ?? 0,
          ),
        );

        // Start polling for buffer position, since there is no buffer position
        // event to listen to.
        _bufferPollingTimer = Timer.periodic(const Duration(seconds: 1), (
          Timer timer,
        ) async {
          _updateBufferingState(await _api.getBufferedPosition());
        });
      case 'completed':
        _eventStreamController.add(
          VideoEvent(eventType: VideoEventType.completed),
        );
      case 'bufferingStart':
        _eventStreamController.add(
          VideoEvent(eventType: VideoEventType.bufferingStart),
        );
        // Trigger an extra buffer position check, so that clients have an
        // accurate reporting of the current buffering state.
        _api.getBufferedPosition().then(
          (int position) => _updateBufferingState(position),
        );
      case 'bufferingEnd':
        _eventStreamController.add(
          VideoEvent(eventType: VideoEventType.bufferingEnd),
        );
        // Trigger an extra buffer position check, so that clients have an
        // accurate reporting of the current buffering state.
        _api.getBufferedPosition().then(
          (int position) => _updateBufferingState(position),
        );
      case 'isPlayingStateUpdate':
        _eventStreamController.add(
          VideoEvent(
            eventType: VideoEventType.isPlayingStateUpdate,
            isPlaying: map['isPlaying'] as bool,
          ),
        );
      default:
        _eventStreamController.add(
          VideoEvent(eventType: VideoEventType.unknown),
        );
    }
  }

  // Turns a single buffer position, which is what ExoPlayer reports, into the
  // DurationRange array expected by [VideoEventType.bufferingUpdate].
  List<DurationRange> _bufferRangeForPosition(int milliseconds) {
    return <DurationRange>[
      DurationRange(Duration.zero, Duration(milliseconds: milliseconds)),
    ];
  }
}

/// Base class representing the state of a video player view.
@visibleForTesting
@immutable
sealed class VideoPlayerViewState {
  const VideoPlayerViewState();
}

/// Represents the state of a video player view that uses a texture.
@visibleForTesting
final class VideoPlayerTextureViewState extends VideoPlayerViewState {
  /// Creates a new instance of [VideoPlayerTextureViewState].
  const VideoPlayerTextureViewState({required this.textureId});

  /// The ID of the texture used by the video player.
  final int textureId;
}

/// Represents the state of a video player view that uses a platform view.
@visibleForTesting
final class VideoPlayerPlatformViewState extends VideoPlayerViewState {
  /// Creates a new instance of [VideoPlayerPlatformViewState].
  const VideoPlayerPlatformViewState();
}
