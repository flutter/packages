// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:web/web.dart' as web;

import 'duration_utils.dart';
import 'pkg_web_tweaks.dart';

// An error code value to error name Map.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/code
const Map<int, String> _kErrorValueToErrorName = <int, String>{
  1: 'MEDIA_ERR_ABORTED',
  2: 'MEDIA_ERR_NETWORK',
  3: 'MEDIA_ERR_DECODE',
  4: 'MEDIA_ERR_SRC_NOT_SUPPORTED',
};

// An error code value to description Map.
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/code
const Map<int, String> _kErrorValueToErrorDescription = <int, String>{
  1: 'The user canceled the fetching of the video.',
  2: 'A network error occurred while fetching the video, despite having previously been available.',
  3: 'An error occurred while trying to decode the video, despite having previously been determined to be usable.',
  4: 'The video has been found to be unsuitable (missing or in a format not supported by your browser).',
};

// The default error message, when the error is an empty string
// See: https://developer.mozilla.org/en-US/docs/Web/API/MediaError/message
const String _kDefaultErrorMessage =
    'No further diagnostic information can be determined or provided.';

/// Wraps a [web.HTMLVideoElement] so its API complies with what is expected by the plugin.
class VideoPlayer {
  /// Create a [VideoPlayer] from a [web.HTMLVideoElement] instance.
  VideoPlayer({
    required web.HTMLVideoElement videoElement,
    @visibleForTesting StreamController<VideoEvent>? eventController,
  })  : _videoElement = videoElement,
        _eventController = eventController ?? StreamController<VideoEvent>();

  final StreamController<VideoEvent> _eventController;
  final web.HTMLVideoElement _videoElement;
  web.EventHandler? _onContextMenu;

  bool _isInitialized = false;
  bool _isBuffering = false;

  /// Returns the [Stream] of [VideoEvent]s from the inner [web.HTMLVideoElement].
  Stream<VideoEvent> get events => _eventController.stream;

  /// Initializes the wrapped [web.HTMLVideoElement].
  ///
  /// This method sets the required DOM attributes so videos can [play] programmatically,
  /// and attaches listeners to the internal events from the [web.HTMLVideoElement]
  /// to react to them / expose them through the [VideoPlayer.events] stream.
  ///
  /// The [src] parameter is the URL of the video. It is passed in from the plugin
  /// `create` method so it can be set in the VideoElement *last*. This way, all
  /// the event listeners needed to integrate the videoElement with the plugin
  /// are attached before any events start firing (events start to fire when the
  /// `src` attribute is set).
  ///
  /// The `src` parameter is nullable for testing purposes.
  void initialize({
    String? src,
  }) {
    _videoElement
      ..autoplay = false
      ..controls = false
      ..playsInline = true;

    _videoElement.onCanPlay.listen(_onVideoElementInitialization);
    // Needed for Safari iOS 17, which may not send `canplay`.
    _videoElement.onLoadedMetadata.listen(_onVideoElementInitialization);

    _videoElement.onCanPlayThrough.listen((dynamic _) {
      setBuffering(false);
    });

    _videoElement.onPlaying.listen((dynamic _) {
      setBuffering(false);
    });

    _videoElement.onWaiting.listen((dynamic _) {
      setBuffering(true);
      _sendBufferingRangesUpdate();
    });

    // The error event fires when some form of error occurs while attempting to load or perform the media.
    _videoElement.onError.listen((web.Event _) {
      setBuffering(false);
      // The Event itself (_) doesn't contain info about the actual error.
      // We need to look at the HTMLMediaElement.error.
      // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/error
      final web.MediaError error = _videoElement.error!;
      _eventController.addError(PlatformException(
        code: _kErrorValueToErrorName[error.code]!,
        message: error.message != '' ? error.message : _kDefaultErrorMessage,
        details: _kErrorValueToErrorDescription[error.code],
      ));
    });

    _videoElement.onPlay.listen((dynamic _) {
      _eventController.add(VideoEvent(
        eventType: VideoEventType.isPlayingStateUpdate,
        isPlaying: true,
      ));
    });

    _videoElement.onPause.listen((dynamic _) {
      _eventController.add(VideoEvent(
        eventType: VideoEventType.isPlayingStateUpdate,
        isPlaying: false,
      ));
    });

    _videoElement.onEnded.listen((dynamic _) {
      setBuffering(false);
      _eventController.add(VideoEvent(eventType: VideoEventType.completed));
    });

    // The `src` of the _videoElement is the last property that is set, so all
    // the listeners for the events that the plugin cares about are attached.
    if (src != null) {
      _videoElement.src = src;
    }
  }

  /// Attempts to play the video.
  ///
  /// If this method is called programmatically (without user interaction), it
  /// might fail unless the video is completely muted (or it has no Audio tracks).
  ///
  /// When called from some user interaction (a tap on a button), the above
  /// limitation should disappear.
  Future<void> play() {
    return _videoElement.play().toDart.catchError((Object e) {
      // play() attempts to begin playback of the media. It returns
      // a Promise which can get rejected in case of failure to begin
      // playback for any reason, such as permission issues.
      // The rejection handler is called with a DOMException.
      // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/play
      final web.DOMException exception = e as web.DOMException;
      _eventController.addError(PlatformException(
        code: exception.name,
        message: exception.message,
      ));
      return null;
    }, test: (Object e) => e is web.DOMException);
  }

  /// Pauses the video in the current position.
  void pause() {
    _videoElement.pause();
  }

  /// Controls whether the video should start again after it finishes.
  // ignore: use_setters_to_change_properties
  void setLooping(bool value) {
    _videoElement.loop = value;
  }

  /// Sets the volume at which the media will be played.
  ///
  /// Values must fall between 0 and 1, where 0 is muted and 1 is the loudest.
  ///
  /// When volume is set to 0, the `muted` property is also applied to the
  /// [web.HTMLVideoElement]. This is required for auto-play on the web.
  void setVolume(double volume) {
    assert(volume >= 0 && volume <= 1);

    // TODO(ditman): Do we need to expose a "muted" API?
    // https://github.com/flutter/flutter/issues/60721

    // If the volume is set to 0.0, only change muted attribute, but don't adjust the volume.
    _videoElement.muted = volume == 0.0;
    // Set the volume only if it's greater than 0.0.
    if (volume > 0.0) {
      _videoElement.volume = volume;
    }
  }

  /// Sets the playback `speed`.
  ///
  /// A `speed` of 1.0 is "normal speed," values lower than 1.0 make the media
  /// play slower than normal, higher values make it play faster.
  ///
  /// `speed` cannot be negative.
  ///
  /// The audio is muted when the fast forward or slow motion is outside a useful
  /// range (for example, Gecko mutes the sound outside the range 0.25 to 4.0).
  ///
  /// The pitch of the audio is corrected by default.
  void setPlaybackSpeed(double speed) {
    assert(speed > 0);

    _videoElement.playbackRate = speed;
  }

  /// Moves the playback head to a new `position`.
  ///
  /// `position` cannot be negative.
  void seekTo(Duration position) {
    assert(!position.isNegative);

    // Don't seek if video is already at target position.
    //
    // This is needed because the core plugin will pause and seek to the end of
    // the video when it finishes, and that causes an infinite loop of `ended`
    // events on the web.
    //
    // See: https://github.com/flutter/flutter/issues/77674
    if (position == _videoElementCurrentTime) {
      return;
    }

    _videoElement.currentTime = position.inMilliseconds.toDouble() / 1000;
  }

  /// Returns the current playback head position as a [Duration].
  Duration getPosition() {
    _sendBufferingRangesUpdate();
    return _videoElementCurrentTime;
  }

  /// Returns the currentTime of the underlying video element.
  Duration get _videoElementCurrentTime {
    return Duration(milliseconds: (_videoElement.currentTime * 1000).round());
  }

  /// Sets options
  Future<void> setOptions(VideoPlayerWebOptions options) async {
    // In case this method is called multiple times, reset options.
    _resetOptions();

    if (options.controls.enabled) {
      _videoElement.controls = true;
      final String controlsList = options.controls.controlsList;
      if (controlsList.isNotEmpty) {
        _videoElement.controlsList = controlsList;
      }

      if (!options.controls.allowPictureInPicture) {
        _videoElement.disablePictureInPicture = true;
      }
    }

    if (!options.allowContextMenu) {
      _onContextMenu = ((web.Event event) => event.preventDefault()).toJS;
      _videoElement.addEventListener('contextmenu', _onContextMenu);
    }

    if (!options.allowRemotePlayback) {
      _videoElement.disableRemotePlayback = true;
    }
  }

  void _resetOptions() {
    _videoElement.controls = false;
    _videoElement.removeAttribute('controlsList');
    _videoElement.removeAttribute('disablePictureInPicture');
    if (_onContextMenu != null) {
      _videoElement.removeEventListener('contextmenu', _onContextMenu);
      _onContextMenu = null;
    }
    _videoElement.removeAttribute('disableRemotePlayback');
  }

  /// Disposes of the current [web.HTMLVideoElement].
  void dispose() {
    _videoElement.removeAttribute('src');
    if (_onContextMenu != null) {
      _videoElement.removeEventListener('contextmenu', _onContextMenu);
      _onContextMenu = null;
    }
    _videoElement.load();
  }

  // Handler to mark (and broadcast) when this player [_isInitialized].
  //
  // (Used as a JS event handler for "canplay" and "loadedmetadata")
  //
  // This function can be called multiple times by different JS Events, but it'll
  // only broadcast an "initialized" event the first time it's called, and ignore
  // the rest of the calls.
  void _onVideoElementInitialization(Object? _) {
    if (!_isInitialized) {
      _isInitialized = true;
      _sendInitialized();
    }
  }

  // Sends an [VideoEventType.initialized] [VideoEvent] with info about the wrapped video.
  void _sendInitialized() {
    final Duration? duration =
        convertNumVideoDurationToPluginDuration(_videoElement.duration);

    final Size? size = _videoElement.videoHeight.isFinite
        ? Size(
            _videoElement.videoWidth.toDouble(),
            _videoElement.videoHeight.toDouble(),
          )
        : null;

    _eventController.add(
      VideoEvent(
        eventType: VideoEventType.initialized,
        duration: duration,
        size: size,
      ),
    );
  }

  /// Caches the current "buffering" state of the video.
  ///
  /// If the current buffering state is different from the previous one
  /// ([_isBuffering]), this dispatches a [VideoEvent].
  @visibleForTesting
  void setBuffering(bool buffering) {
    if (_isBuffering != buffering) {
      _isBuffering = buffering;
      _eventController.add(VideoEvent(
        eventType: _isBuffering
            ? VideoEventType.bufferingStart
            : VideoEventType.bufferingEnd,
      ));
    }
  }

  // Broadcasts the [web.HTMLVideoElement.buffered] status through the [events] stream.
  void _sendBufferingRangesUpdate() {
    _eventController.add(VideoEvent(
      buffered: _toDurationRange(_videoElement.buffered),
      eventType: VideoEventType.bufferingUpdate,
    ));
  }

  // Converts from [html.TimeRanges] to our own List<DurationRange>.
  List<DurationRange> _toDurationRange(web.TimeRanges buffered) {
    final List<DurationRange> durationRange = <DurationRange>[];
    for (int i = 0; i < buffered.length; i++) {
      durationRange.add(DurationRange(
        Duration(milliseconds: (buffered.start(i) * 1000).round()),
        Duration(milliseconds: (buffered.end(i) * 1000).round()),
      ));
    }
    return durationRange;
  }
}
