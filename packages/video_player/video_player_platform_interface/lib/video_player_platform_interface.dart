// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of video_player must implement.
///
/// Platform implementations should extend this class rather than implement it as `video_player`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [VideoPlayerPlatform] methods.
abstract class VideoPlayerPlatform extends PlatformInterface {
  /// Constructs a VideoPlayerPlatform.
  VideoPlayerPlatform() : super(token: _token);

  static final Object _token = Object();

  static VideoPlayerPlatform _instance = _PlaceholderImplementation();

  /// The instance of [VideoPlayerPlatform] to use.
  ///
  /// Defaults to a placeholder that does not override any methods, and thus
  /// throws `UnimplementedError` in most cases.
  static VideoPlayerPlatform get instance => _instance;

  /// Platform-specific plugins should override this with their own
  /// platform-specific class that extends [VideoPlayerPlatform] when they
  /// register themselves.
  static set instance(VideoPlayerPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Initializes the platform interface and disposes all existing players.
  ///
  /// This method is called when the plugin is first initialized
  /// and on every full restart.
  Future<void> init() {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Clears one video.
  Future<void> dispose(int textureId) {
    throw UnimplementedError('dispose() has not been implemented.');
  }

  /// Creates an instance of a video player and returns its textureId.
  Future<int?> create(DataSource dataSource) {
    throw UnimplementedError('create() has not been implemented.');
  }

  /// Returns a Stream of [VideoEventType]s.
  Stream<VideoEvent> videoEventsFor(int textureId) {
    throw UnimplementedError('videoEventsFor() has not been implemented.');
  }

  /// Sets the looping attribute of the video.
  Future<void> setLooping(int textureId, bool looping) {
    throw UnimplementedError('setLooping() has not been implemented.');
  }

  /// Starts the video playback.
  Future<void> play(int textureId) {
    throw UnimplementedError('play() has not been implemented.');
  }

  /// Stops the video playback.
  Future<void> pause(int textureId) {
    throw UnimplementedError('pause() has not been implemented.');
  }

  /// Sets the volume to a range between 0.0 and 1.0.
  Future<void> setVolume(int textureId, double volume) {
    throw UnimplementedError('setVolume() has not been implemented.');
  }

  /// Sets the video position to a [Duration] from the start.
  Future<void> seekTo(int textureId, Duration position) {
    throw UnimplementedError('seekTo() has not been implemented.');
  }

  /// Sets the playback speed to a [speed] value indicating the playback rate.
  Future<void> setPlaybackSpeed(int textureId, double speed) {
    throw UnimplementedError('setPlaybackSpeed() has not been implemented.');
  }

  /// Gets the video position as [Duration] from the start.
  Future<Duration> getPosition(int textureId) {
    throw UnimplementedError('getPosition() has not been implemented.');
  }

  /// Returns a widget displaying the video with a given textureID.
  Widget buildView(int textureId) {
    throw UnimplementedError('buildView() has not been implemented.');
  }

  /// Sets the audio mode to mix with other sources
  Future<void> setMixWithOthers(bool mixWithOthers) {
    throw UnimplementedError('setMixWithOthers() has not been implemented.');
  }

  /// Sets additional options on web
  Future<void> setWebOptions(int textureId, VideoPlayerWebOptions options) {
    throw UnimplementedError('setWebOptions() has not been implemented.');
  }
}

class _PlaceholderImplementation extends VideoPlayerPlatform {}

/// Description of the data source used to create an instance of
/// the video player.
class DataSource {
  /// Constructs an instance of [DataSource].
  ///
  /// The [sourceType] is always required.
  ///
  /// The [uri] argument takes the form of `'https://example.com/video.mp4'` or
  /// `'file:///absolute/path/to/local/video.mp4`.
  ///
  /// The [formatHint] argument can be null.
  ///
  /// The [asset] argument takes the form of `'assets/video.mp4'`.
  ///
  /// The [package] argument must be non-null when the asset comes from a
  /// package and null otherwise.
  DataSource({
    required this.sourceType,
    this.uri,
    this.formatHint,
    this.asset,
    this.package,
    this.httpHeaders = const <String, String>{},
  });

  /// The way in which the video was originally loaded.
  ///
  /// This has nothing to do with the video's file type. It's just the place
  /// from which the video is fetched from.
  final DataSourceType sourceType;

  /// The URI to the video file.
  ///
  /// This will be in different formats depending on the [DataSourceType] of
  /// the original video.
  final String? uri;

  /// **Android only**. Will override the platform's generic file format
  /// detection with whatever is set here.
  final VideoFormat? formatHint;

  /// HTTP headers used for the request to the [uri].
  /// Only for [DataSourceType.network] videos.
  /// Always empty for other video types.
  Map<String, String> httpHeaders;

  /// The name of the asset. Only set for [DataSourceType.asset] videos.
  final String? asset;

  /// The package that the asset was loaded from. Only set for
  /// [DataSourceType.asset] videos.
  final String? package;
}

/// The way in which the video was originally loaded.
///
/// This has nothing to do with the video's file type. It's just the place
/// from which the video is fetched from.
enum DataSourceType {
  /// The video was included in the app's asset files.
  asset,

  /// The video was downloaded from the internet.
  network,

  /// The video was loaded off of the local filesystem.
  file,

  /// The video is available via contentUri. Android only.
  contentUri,
}

/// The file format of the given video.
enum VideoFormat {
  /// Dynamic Adaptive Streaming over HTTP, also known as MPEG-DASH.
  dash,

  /// HTTP Live Streaming.
  hls,

  /// Smooth Streaming.
  ss,

  /// Any format other than the other ones defined in this enum.
  other,
}

/// Event emitted from the platform implementation.
@immutable
class VideoEvent {
  /// Creates an instance of [VideoEvent].
  ///
  /// The [eventType] argument is required.
  ///
  /// Depending on the [eventType], the [duration], [size],
  /// [rotationCorrection], and [buffered] arguments can be null.
  // TODO(stuartmorgan): Temporarily suppress warnings about not using const
  // in all of the other video player packages, fix this, and then update
  // the other packages to use const.
  // ignore: prefer_const_constructors_in_immutables
  VideoEvent({
    required this.eventType,
    this.duration,
    this.size,
    this.rotationCorrection,
    this.buffered,
    this.isPlaying,
  });

  /// The type of the event.
  final VideoEventType eventType;

  /// Duration of the video.
  ///
  /// Only used if [eventType] is [VideoEventType.initialized].
  final Duration? duration;

  /// Size of the video.
  ///
  /// Only used if [eventType] is [VideoEventType.initialized].
  final Size? size;

  /// Degrees to rotate the video (clockwise) so it is displayed correctly.
  ///
  /// Only used if [eventType] is [VideoEventType.initialized].
  final int? rotationCorrection;

  /// Buffered parts of the video.
  ///
  /// Only used if [eventType] is [VideoEventType.bufferingUpdate].
  final List<DurationRange>? buffered;

  /// Whether the video is currently playing.
  ///
  /// Only used if [eventType] is [VideoEventType.isPlayingStateUpdate].
  final bool? isPlaying;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VideoEvent &&
            runtimeType == other.runtimeType &&
            eventType == other.eventType &&
            duration == other.duration &&
            size == other.size &&
            rotationCorrection == other.rotationCorrection &&
            listEquals(buffered, other.buffered) &&
            isPlaying == other.isPlaying;
  }

  @override
  int get hashCode => Object.hash(
        eventType,
        duration,
        size,
        rotationCorrection,
        buffered,
        isPlaying,
      );
}

/// Type of the event.
///
/// Emitted by the platform implementation when the video is initialized or
/// completed or to communicate buffering events or play state changed.
enum VideoEventType {
  /// The video has been initialized.
  ///
  /// A maximum of one event of this type may be emitted per instance.
  initialized,

  /// The playback has ended.
  completed,

  /// Updated information on the buffering state.
  bufferingUpdate,

  /// The video started to buffer.
  bufferingStart,

  /// The video stopped to buffer.
  bufferingEnd,

  /// The playback state of the video has changed.
  ///
  /// This event is fired when the video starts or pauses due to user actions or
  /// phone calls, or other app media such as music players.
  isPlayingStateUpdate,

  /// An unknown event has been received.
  unknown,
}

/// Describes a discrete segment of time within a video using a [start] and
/// [end] [Duration].
@immutable
class DurationRange {
  /// Trusts that the given [start] and [end] are actually in order. They should
  /// both be non-null.
  // TODO(stuartmorgan): Temporarily suppress warnings about not using const
  // in all of the other video player packages, fix this, and then update
  // the other packages to use const.
  // ignore: prefer_const_constructors_in_immutables
  DurationRange(this.start, this.end);

  /// The beginning of the segment described relative to the beginning of the
  /// entire video. Should be shorter than or equal to [end].
  ///
  /// For example, if the entire video is 4 minutes long and the range is from
  /// 1:00-2:00, this should be a `Duration` of one minute.
  final Duration start;

  /// The end of the segment described as a duration relative to the beginning of
  /// the entire video. This is expected to be non-null and longer than or equal
  /// to [start].
  ///
  /// For example, if the entire video is 4 minutes long and the range is from
  /// 1:00-2:00, this should be a `Duration` of two minutes.
  final Duration end;

  /// Assumes that [duration] is the total length of the video that this
  /// DurationRange is a segment form. It returns the percentage that [start] is
  /// through the entire video.
  ///
  /// For example, assume that the entire video is 4 minutes long. If [start] has
  /// a duration of one minute, this will return `0.25` since the DurationRange
  /// starts 25% of the way through the video's total length.
  double startFraction(Duration duration) {
    return start.inMilliseconds / duration.inMilliseconds;
  }

  /// Assumes that [duration] is the total length of the video that this
  /// DurationRange is a segment form. It returns the percentage that [start] is
  /// through the entire video.
  ///
  /// For example, assume that the entire video is 4 minutes long. If [end] has a
  /// duration of two minutes, this will return `0.5` since the DurationRange
  /// ends 50% of the way through the video's total length.
  double endFraction(Duration duration) {
    return end.inMilliseconds / duration.inMilliseconds;
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'DurationRange')}(start: $start, end: $end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DurationRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// [VideoPlayerOptions] can be optionally used to set additional player settings
@immutable
class VideoPlayerOptions {
  /// Set additional optional player settings
  // TODO(stuartmorgan): Temporarily suppress warnings about not using const
  // in all of the other video player packages, fix this, and then update
  // the other packages to use const.
  // ignore: prefer_const_constructors_in_immutables
  VideoPlayerOptions({
    this.mixWithOthers = false,
    this.allowBackgroundPlayback = false,
    this.webOptions,
  });

  /// Set this to true to keep playing video in background, when app goes in background.
  /// The default value is false.
  final bool allowBackgroundPlayback;

  /// Set this to true to mix the video players audio with other audio sources.
  /// The default value is false
  ///
  /// Note: This option will be silently ignored in the web platform (there is
  /// currently no way to implement this feature in this platform).
  final bool mixWithOthers;

  /// Additional web controls
  final VideoPlayerWebOptions? webOptions;
}

/// [VideoPlayerWebOptions] can be optionally used to set additional web settings
@immutable
class VideoPlayerWebOptions {
  /// [VideoPlayerWebOptions] can be optionally used to set additional web settings
  const VideoPlayerWebOptions({
    this.controls = const VideoPlayerWebOptionsControls.disabled(),
    this.allowContextMenu = true,
    this.allowRemotePlayback = true,
  });

  /// Additional settings for how control options are displayed
  final VideoPlayerWebOptionsControls controls;

  /// Whether context menu (right click) is allowed
  final bool allowContextMenu;

  /// Whether remote playback is allowed
  final bool allowRemotePlayback;
}

/// [VideoPlayerWebOptions] can be used to set how control options are displayed
@immutable
class VideoPlayerWebOptionsControls {
  /// Enables controls and sets how the options are displayed
  const VideoPlayerWebOptionsControls.enabled({
    this.allowDownload = true,
    this.allowFullscreen = true,
    this.allowPlaybackRate = true,
    this.allowPictureInPicture = true,
  }) : enabled = true;

  /// Disables control options. Default behavior.
  const VideoPlayerWebOptionsControls.disabled()
      : enabled = false,
        allowDownload = false,
        allowFullscreen = false,
        allowPlaybackRate = false,
        allowPictureInPicture = false;

  /// Whether native controls are enabled
  final bool enabled;

  /// Whether downloaded control is displayed
  ///
  /// Only applicable when [controlsEnabled] is true
  final bool allowDownload;

  /// Whether fullscreen control is enabled
  ///
  /// Only applicable when [controlsEnabled] is true
  final bool allowFullscreen;

  /// Whether playback rate control is displayed
  ///
  /// Only applicable when [controlsEnabled] is true
  final bool allowPlaybackRate;

  /// Whether picture in picture control is displayed
  ///
  /// Only applicable when [controlsEnabled] is true
  final bool allowPictureInPicture;

  /// A string representation of disallowed controls
  String get controlsList {
    final List<String> controlsList = <String>[];
    if (!allowDownload) {
      controlsList.add('nodownload');
    }
    if (!allowFullscreen) {
      controlsList.add('nofullscreen');
    }
    if (!allowPlaybackRate) {
      controlsList.add('noplaybackrate');
    }

    return controlsList.join(' ');
  }
}
