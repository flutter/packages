// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Options used to create a camera with the given
/// [audio] and [video] media constraints.
///
/// These options represent web `MediaStreamConstraints`
/// and can be used to request the browser for media streams
/// with audio and video tracks containing the requested types of media.
///
/// https://developer.mozilla.org/en-US/docs/Web/API/MediaStreamConstraints
@immutable
class CameraOptions {
  /// Creates a new instance of [CameraOptions]
  /// with the given [audio] and [video] constraints.
  const CameraOptions({
    AudioConstraints? audio,
    VideoConstraints? video,
  })  : audio = audio ?? const AudioConstraints(),
        video = video ?? const VideoConstraints();

  /// The audio constraints for the camera.
  final AudioConstraints audio;

  /// The video constraints for the camera.
  final VideoConstraints video;

  /// Converts `this` to something that can be used by the browser.
  web.MediaStreamConstraints toMediaStreamConstraints() {
    return web.MediaStreamConstraints(
      audio: audio.toMediaStreamConstraints(),
      video: video.toMediaStreamConstraints(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CameraOptions &&
        other.audio == audio &&
        other.video == video;
  }

  @override
  int get hashCode => Object.hash(audio, video);
}

/// Indicates whether the audio track is requested.
///
/// By default, the audio track is not requested.
@immutable
class AudioConstraints {
  /// Creates a new instance of [AudioConstraints]
  /// with the given [enabled] constraint.
  const AudioConstraints({this.enabled = false});

  /// Whether the audio track should be enabled.
  final bool enabled;

  /// Convert `this` to something that can be used on the browser.
  JSAny toMediaStreamConstraints() => enabled.toJS;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AudioConstraints && other.enabled == enabled;
  }

  @override
  int get hashCode => enabled.hashCode;
}

/// Defines constraints that the video track must have
/// to be considered acceptable.
@immutable
class VideoConstraints {
  /// Creates a new instance of [VideoConstraints]
  /// with the given constraints.
  const VideoConstraints({
    this.facingMode,
    this.width,
    this.height,
    this.deviceId,
  });

  /// The facing mode of the video track.
  final FacingModeConstraint? facingMode;

  /// The width of the video track.
  final VideoSizeConstraint? width;

  /// The height of the video track.
  final VideoSizeConstraint? height;

  /// The device id of the video track.
  final String? deviceId;

  // TODO(dit): package:web has a class for this. Use it instead of jsify and toJson.
  /// Convert `this` to something that can be used on the browser.
  JSAny toMediaStreamConstraints() {
    return <String, Object>{
      if (width != null) 'width': width!.toJson(),
      if (height != null) 'height': height!.toJson(),
      if (facingMode != null) 'facingMode': facingMode!.toJson(),
      if (deviceId != null) 'deviceId': <String, Object>{'exact': deviceId!},
    }.jsify()!;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is VideoConstraints &&
        other.facingMode == facingMode &&
        other.width == width &&
        other.height == height &&
        other.deviceId == deviceId;
  }

  @override
  int get hashCode => Object.hash(facingMode, width, height, deviceId);
}

/// The camera type used in [FacingModeConstraint].
///
/// Specifies whether the requested camera should be facing away
/// or toward the user.
enum CameraType {
  /// The camera is facing away from the user, viewing their environment.
  /// This includes the back camera on a smartphone.
  environment._('environment'),

  /// The camera is facing toward the user.
  /// This includes the front camera on a smartphone.
  user._('user');

  const CameraType._(this._type);

  final String _type;

  @override
  String toString() => _type;
}

// TODO(dit): package:web has a class for this. Use it instead of toJson.
/// Indicates the direction in which the desired camera should be pointing.
@immutable
class FacingModeConstraint {
  /// Creates a new instance of [FacingModeConstraint]
  /// with [ideal] constraint set to [type].
  factory FacingModeConstraint(CameraType type) =>
      FacingModeConstraint._(ideal: type);

  /// Creates a new instance of [FacingModeConstraint]
  /// with the given [ideal] and [exact] constraints.
  const FacingModeConstraint._({this.ideal, this.exact});

  /// Creates a new instance of [FacingModeConstraint]
  /// with [exact] constraint set to [type].
  factory FacingModeConstraint.exact(CameraType type) =>
      FacingModeConstraint._(exact: type);

  /// The ideal facing mode constraint.
  ///
  /// If this constraint is used, then the camera would ideally have
  /// the desired facing [type] but it may be considered optional.
  final CameraType? ideal;

  /// The exact facing mode constraint.
  ///
  /// If this constraint is used, then the camera must have
  /// the desired facing [type] to be considered acceptable.
  final CameraType? exact;

  // TODO(dit): package:web has a class for this. Use it instead of toJson.
  /// Converts the current instance to a Map.
  Object toJson() {
    return <String, Object>{
      if (ideal != null) 'ideal': ideal.toString(),
      if (exact != null) 'exact': exact.toString(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is FacingModeConstraint &&
        other.ideal == ideal &&
        other.exact == exact;
  }

  @override
  int get hashCode => Object.hash(ideal, exact);
}

// TODO(dit): package:web has a class for this. Use it instead of toJson.
/// The size of the requested video track used in
/// [VideoConstraints.width] and [VideoConstraints.height].
///
/// The obtained video track will have a size between [minimum] and [maximum]
/// with ideally a size of [ideal]. The size is determined by
/// the capabilities of the hardware and the other specified constraints.
@immutable
class VideoSizeConstraint {
  /// Creates a new instance of [VideoSizeConstraint] with the given
  /// [minimum], [ideal] and [maximum] constraints.
  const VideoSizeConstraint({this.minimum, this.ideal, this.maximum});

  /// The minimum video size.
  final int? minimum;

  /// The ideal video size.
  ///
  /// The video would ideally have the [ideal] size
  /// but it may be considered optional. If not possible
  /// to satisfy, the size will be as close as possible
  /// to [ideal].
  final int? ideal;

  /// The maximum video size.
  final int? maximum;

  // TODO(dit): package:web has a class for this. Use it instead of toJson.
  /// Converts the current instance to a Map.
  Object toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    if (ideal != null) {
      json['ideal'] = ideal;
    }
    if (minimum != null) {
      json['min'] = minimum;
    }
    if (maximum != null) {
      json['max'] = maximum;
    }

    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is VideoSizeConstraint &&
        other.minimum == minimum &&
        other.ideal == ideal &&
        other.maximum == maximum;
  }

  @override
  int get hashCode => Object.hash(minimum, ideal, maximum);
}
