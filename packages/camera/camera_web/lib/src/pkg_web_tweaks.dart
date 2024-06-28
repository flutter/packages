// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:js_interop';

import 'package:web/web.dart';

// TODO(srujzs): These will be added in `package:web` 0.6.0. Remove these
// helpers once it is available.

/// Adds missing fields to [HTMLMediaElement]s.
extension NonStandardFieldsOnMediaElement on HTMLMediaElement {
  external MediaStream captureStream();
}

/// Adds missing fields to [HTMLCanvasElement]s.
extension NonStandardFieldsOnCanvasElement on HTMLCanvasElement {
  external MediaStream captureStream();
}

/// Adds missing fields to [MediaTrackSupportedConstraints].
extension NonStandardFieldsOnMediaTrackSupportedConstraints
    on MediaTrackSupportedConstraints {
  static MediaTrackSupportedConstraints construct({
    // bool? width,
    // bool? height,
    // bool? aspectRatio,
    // bool? frameRate,
    // bool? facingMode,
    // bool? resizeMode,
    // bool? sampleRate,
    // bool? sampleSize,
    // bool? echoCancellation,
    // bool? autoGainControl,
    // bool? noiseSuppression,
    // bool? latency,
    // bool? channelCount,
    // bool? deviceId,
    // bool? groupId,
    // bool? whiteBalanceMode,
    // bool? exposureMode,
    // bool? focusMode,
    // bool? pointsOfInterest,
    // bool? exposureCompensation,
    // bool? exposureTime,
    // bool? colorTemperature,
    // bool? iso,
    // bool? brightness,
    // bool? contrast,
    // bool? pan,
    // bool? saturation,
    // bool? sharpness,
    // bool? focusDistance,
    // bool? tilt,
    bool? zoom,
    bool? torch,
    // bool? displaySurface,
    // bool? logicalSurface,
    // bool? cursor,
    // bool? restrictOwnAudio,
    // bool? suppressLocalAudioPlayback,
  }) {
    final MediaTrackSupportedConstraints constraints =
        MediaTrackSupportedConstraints();

    if (zoom != null) {
      constraints.zoom = zoom;
    }
    if (torch != null) {
      constraints.torch = torch;
    }

    return constraints;
  }

  // external bool get width;
  // external set width(bool value);
  // external bool get height;
  // external set height(bool value);
  // external bool get aspectRatio;
  // external set aspectRatio(bool value);
  // external bool get frameRate;
  // external set frameRate(bool value);
  // external bool get facingMode;
  // external set facingMode(bool value);
  // external bool get resizeMode;
  // external set resizeMode(bool value);
  // external bool get sampleRate;
  // external set sampleRate(bool value);
  // external bool get sampleSize;
  // external set sampleSize(bool value);
  // external bool get echoCancellation;
  // external set echoCancellation(bool value);
  // external bool get autoGainControl;
  // external set autoGainControl(bool value);
  // external bool get noiseSuppression;
  // external set noiseSuppression(bool value);
  // external bool get latency;
  // external set latency(bool value);
  // external bool get channelCount;
  // external set channelCount(bool value);
  // external bool get deviceId;
  // external set deviceId(bool value);
  // external bool get groupId;
  // external set groupId(bool value);
  // external bool get whiteBalanceMode;
  // external set whiteBalanceMode(bool value);
  // external bool get exposureMode;
  // external set exposureMode(bool value);
  // external bool get focusMode;
  // external set focusMode(bool value);
  // external bool get pointsOfInterest;
  // external set pointsOfInterest(bool value);
  // external bool get exposureCompensation;
  // external set exposureCompensation(bool value);
  // external bool get exposureTime;
  // external set exposureTime(bool value);
  // external bool get colorTemperature;
  // external set colorTemperature(bool value);
  // external bool get iso;
  // external set iso(bool value);
  // external bool get brightness;
  // external set brightness(bool value);
  // external bool get contrast;
  // external set contrast(bool value);
  // external bool get pan;
  // external set pan(bool value);
  // external bool get saturation;
  // external set saturation(bool value);
  // external bool get sharpness;
  // external set sharpness(bool value);
  // external bool get focusDistance;
  // external set focusDistance(bool value);
  // external bool get tilt;
  // external set tilt(bool value);
  external bool get zoom;
  external set zoom(bool value);
  external bool get torch;
  external set torch(bool value);
  // external bool get displaySurface;
  // external set displaySurface(bool value);
  // external bool get logicalSurface;
  // external set logicalSurface(bool value);
  // external bool get cursor;
  // external set cursor(bool value);
  // external bool get restrictOwnAudio;
  // external set restrictOwnAudio(bool value);
  // external bool get suppressLocalAudioPlayback;
  // external set suppressLocalAudioPlayback(bool value);
}

/// Adds missing fields to [MediaTrackCapabilities].

extension NonStandardFieldsOnMediaTrackCapabilities on MediaTrackCapabilities {
  static MediaTrackCapabilities construct({
    // ULongRange width,
    // ULongRange height,
    // DoubleRange aspectRatio,
    // DoubleRange frameRate,
    // JSArray<JSString> facingMode,
    // JSArray<JSString> resizeMode,
    // ULongRange sampleRate,
    // ULongRange sampleSize,
    // JSArray<JSBoolean> echoCancellation,
    // JSArray<JSBoolean> autoGainControl,
    // JSArray<JSBoolean> noiseSuppression,
    // DoubleRange latency,
    // ULongRange channelCount,
    // String deviceId,
    // String groupId,
    // JSArray<JSString> whiteBalanceMode,
    // JSArray<JSString> exposureMode,
    // JSArray<JSString> focusMode,
    // MediaSettingsRange exposureCompensation,
    // MediaSettingsRange exposureTime,
    // MediaSettingsRange colorTemperature,
    // MediaSettingsRange iso,
    // MediaSettingsRange brightness,
    // MediaSettingsRange contrast,
    // MediaSettingsRange saturation,
    // MediaSettingsRange sharpness,
    // MediaSettingsRange focusDistance,
    // MediaSettingsRange pan,
    // MediaSettingsRange tilt,
    MediaSettingsRange? zoom,
    JSArray<JSBoolean>? torch,
    // String displaySurface,
    // bool logicalSurface,
    // JSArray<JSString> cursor,
  }) {
    final MediaTrackCapabilities capabilities = MediaTrackCapabilities();

    if (zoom != null) {
      capabilities.zoom = zoom;
    }
    if (torch != null) {
      capabilities.torch = torch;
    }

    return capabilities;
  }

  // external ULongRange get width;
  // external set width(ULongRange value);
  // external ULongRange get height;
  // external set height(ULongRange value);
  // external DoubleRange get aspectRatio;
  // external set aspectRatio(DoubleRange value);
  // external DoubleRange get frameRate;
  // external set frameRate(DoubleRange value);
  // external JSArray<JSString> get facingMode;
  // external set facingMode(JSArray<JSString> value);
  // external JSArray<JSString> get resizeMode;
  // external set resizeMode(JSArray<JSString> value);
  // external ULongRange get sampleRate;
  // external set sampleRate(ULongRange value);
  // external ULongRange get sampleSize;
  // external set sampleSize(ULongRange value);
  // external JSArray<JSBoolean> get echoCancellation;
  // external set echoCancellation(JSArray<JSBoolean> value);
  // external JSArray<JSBoolean> get autoGainControl;
  // external set autoGainControl(JSArray<JSBoolean> value);
  // external JSArray<JSBoolean> get noiseSuppression;
  // external set noiseSuppression(JSArray<JSBoolean> value);
  // external DoubleRange get latency;
  // external set latency(DoubleRange value);
  // external ULongRange get channelCount;
  // external set channelCount(ULongRange value);
  // external String get deviceId;
  // external set deviceId(String value);
  // external String get groupId;
  // external set groupId(String value);
  // external JSArray<JSString> get whiteBalanceMode;
  // external set whiteBalanceMode(JSArray<JSString> value);
  // external JSArray<JSString> get exposureMode;
  // external set exposureMode(JSArray<JSString> value);
  // external JSArray<JSString> get focusMode;
  // external set focusMode(JSArray<JSString> value);
  // external MediaSettingsRange get exposureCompensation;
  // external set exposureCompensation(MediaSettingsRange value);
  // external MediaSettingsRange get exposureTime;
  // external set exposureTime(MediaSettingsRange value);
  // external MediaSettingsRange get colorTemperature;
  // external set colorTemperature(MediaSettingsRange value);
  // external MediaSettingsRange get iso;
  // external set iso(MediaSettingsRange value);
  // external MediaSettingsRange get brightness;
  // external set brightness(MediaSettingsRange value);
  // external MediaSettingsRange get contrast;
  // external set contrast(MediaSettingsRange value);
  // external MediaSettingsRange get saturation;
  // external set saturation(MediaSettingsRange value);
  // external MediaSettingsRange get sharpness;
  // external set sharpness(MediaSettingsRange value);
  // external MediaSettingsRange get focusDistance;
  // external set focusDistance(MediaSettingsRange value);
  // external MediaSettingsRange get pan;
  // external set pan(MediaSettingsRange value);
  // external MediaSettingsRange get tilt;
  // external set tilt(MediaSettingsRange value);
  external MediaSettingsRange get zoom;
  external set zoom(MediaSettingsRange value);
  external JSArray<JSBoolean> get torch;
  external set torch(JSArray<JSBoolean> value);
  // external String get displaySurface;
  // external set displaySurface(String value);
  // external bool get logicalSurface;
  // external set logicalSurface(bool value);
  // external JSArray<JSString> get cursor;
  // external set cursor(JSArray<JSString> value);
}

/// Adds missing fields to [MediaTrackConstraints].
extension NonStandardFieldsOnMediaTrackConstraints on MediaTrackConstraints {
  static MediaTrackConstraints construct({
    // ConstrainULong width,
    // ConstrainULong height,
    // ConstrainDouble aspectRatio,
    // ConstrainDouble frameRate,
    // ConstrainDOMString facingMode,
    // ConstrainDOMString resizeMode,
    // ConstrainULong sampleRate,
    // ConstrainULong sampleSize,
    // ConstrainBoolean echoCancellation,
    // ConstrainBoolean autoGainControl,
    // ConstrainBoolean noiseSuppression,
    // ConstrainDouble latency,
    // ConstrainULong channelCount,
    // ConstrainDOMString deviceId,
    // ConstrainDOMString groupId,
    // ConstrainDOMString whiteBalanceMode,
    // ConstrainDOMString exposureMode,
    // ConstrainDOMString focusMode,
    // ConstrainPoint2D pointsOfInterest,
    // ConstrainDouble exposureCompensation,
    // ConstrainDouble exposureTime,
    // ConstrainDouble colorTemperature,
    // ConstrainDouble iso,
    // ConstrainDouble brightness,
    // ConstrainDouble contrast,
    // ConstrainDouble saturation,
    // ConstrainDouble sharpness,
    // ConstrainDouble focusDistance,
    // JSAny pan,
    // JSAny tilt,
    JSAny? zoom,
    ConstrainBoolean? torch,
    // ConstrainDOMString displaySurface,
    // ConstrainBoolean logicalSurface,
    // ConstrainDOMString cursor,
    // ConstrainBoolean restrictOwnAudio,
    // ConstrainBoolean suppressLocalAudioPlayback,
    // JSArray<MediaTrackConstraintSet> advanced,
  }) {
    final MediaTrackConstraints constraints = MediaTrackConstraints();

    if (zoom != null) {
      constraints.zoom = zoom;
    }
    if (torch != null) {
      constraints.torch = torch;
    }

    return constraints;
  }
}

/// Adds missing fields to [MediaTrackConstraintSet].
extension NonStandardFieldsOnMediaTrackConstraintSet
    on MediaTrackConstraintSet {
// external factory MediaTrackConstraintSet({
//     ConstrainULong width,
//     ConstrainULong height,
//     ConstrainDouble aspectRatio,
//     ConstrainDouble frameRate,
//     ConstrainDOMString facingMode,
//     ConstrainDOMString resizeMode,
//     ConstrainULong sampleRate,
//     ConstrainULong sampleSize,
//     ConstrainBoolean echoCancellation,
//     ConstrainBoolean autoGainControl,
//     ConstrainBoolean noiseSuppression,
//     ConstrainDouble latency,
//     ConstrainULong channelCount,
//     ConstrainDOMString deviceId,
//     ConstrainDOMString groupId,
//     ConstrainDOMString whiteBalanceMode,
//     ConstrainDOMString exposureMode,
//     ConstrainDOMString focusMode,
//     ConstrainPoint2D pointsOfInterest,
//     ConstrainDouble exposureCompensation,
//     ConstrainDouble exposureTime,
//     ConstrainDouble colorTemperature,
//     ConstrainDouble iso,
//     ConstrainDouble brightness,
//     ConstrainDouble contrast,
//     ConstrainDouble saturation,
//     ConstrainDouble sharpness,
//     ConstrainDouble focusDistance,
//     JSAny pan,
//     JSAny tilt,
//     JSAny zoom,
//     ConstrainBoolean torch,
//     ConstrainDOMString displaySurface,
//     ConstrainBoolean logicalSurface,
//     ConstrainDOMString cursor,
//     ConstrainBoolean restrictOwnAudio,
//     ConstrainBoolean suppressLocalAudioPlayback,
//   });

//   external ConstrainULong get width;
//   external set width(ConstrainULong value);
//   external ConstrainULong get height;
//   external set height(ConstrainULong value);
//   external ConstrainDouble get aspectRatio;
//   external set aspectRatio(ConstrainDouble value);
//   external ConstrainDouble get frameRate;
//   external set frameRate(ConstrainDouble value);
//   external ConstrainDOMString get facingMode;
//   external set facingMode(ConstrainDOMString value);
//   external ConstrainDOMString get resizeMode;
//   external set resizeMode(ConstrainDOMString value);
//   external ConstrainULong get sampleRate;
//   external set sampleRate(ConstrainULong value);
//   external ConstrainULong get sampleSize;
//   external set sampleSize(ConstrainULong value);
//   external ConstrainBoolean get echoCancellation;
//   external set echoCancellation(ConstrainBoolean value);
//   external ConstrainBoolean get autoGainControl;
//   external set autoGainControl(ConstrainBoolean value);
//   external ConstrainBoolean get noiseSuppression;
//   external set noiseSuppression(ConstrainBoolean value);
//   external ConstrainDouble get latency;
//   external set latency(ConstrainDouble value);
//   external ConstrainULong get channelCount;
//   external set channelCount(ConstrainULong value);
//   external ConstrainDOMString get deviceId;
//   external set deviceId(ConstrainDOMString value);
//   external ConstrainDOMString get groupId;
//   external set groupId(ConstrainDOMString value);
//   external ConstrainDOMString get whiteBalanceMode;
//   external set whiteBalanceMode(ConstrainDOMString value);
//   external ConstrainDOMString get exposureMode;
//   external set exposureMode(ConstrainDOMString value);
//   external ConstrainDOMString get focusMode;
//   external set focusMode(ConstrainDOMString value);
//   external ConstrainPoint2D get pointsOfInterest;
//   external set pointsOfInterest(ConstrainPoint2D value);
//   external ConstrainDouble get exposureCompensation;
//   external set exposureCompensation(ConstrainDouble value);
//   external ConstrainDouble get exposureTime;
//   external set exposureTime(ConstrainDouble value);
//   external ConstrainDouble get colorTemperature;
//   external set colorTemperature(ConstrainDouble value);
//   external ConstrainDouble get iso;
//   external set iso(ConstrainDouble value);
//   external ConstrainDouble get brightness;
//   external set brightness(ConstrainDouble value);
//   external ConstrainDouble get contrast;
//   external set contrast(ConstrainDouble value);
//   external ConstrainDouble get saturation;
//   external set saturation(ConstrainDouble value);
//   external ConstrainDouble get sharpness;
//   external set sharpness(ConstrainDouble value);
//   external ConstrainDouble get focusDistance;
//   external set focusDistance(ConstrainDouble value);
//   external JSAny get pan;
//   external set pan(JSAny value);
//   external JSAny get tilt;
//   external set tilt(JSAny value);
  external JSAny get zoom;
  external set zoom(JSAny value);
  external ConstrainBoolean get torch;
  external set torch(ConstrainBoolean value);
//   external ConstrainDOMString get displaySurface;
//   external set displaySurface(ConstrainDOMString value);
//   external ConstrainBoolean get logicalSurface;
//   external set logicalSurface(ConstrainBoolean value);
//   external ConstrainDOMString get cursor;
//   external set cursor(ConstrainDOMString value);
//   external ConstrainBoolean get restrictOwnAudio;
//   external set restrictOwnAudio(ConstrainBoolean value);
//   external ConstrainBoolean get suppressLocalAudioPlayback;
//   external set suppressLocalAudioPlayback(ConstrainBoolean value);
}

extension type MediaSettingsRange._(JSObject _) implements JSObject {
  external factory MediaSettingsRange({
    num max,
    num min,
    num step,
  });

  external num get max;
  external set max(num value);
  external num get min;
  external set min(num value);
  external num get step;
  external set step(num value);
}

typedef FullscreenNavigationUI = String;
extension type FullscreenOptions._(JSObject _) implements JSObject {
  external factory FullscreenOptions({
    FullscreenNavigationUI navigationUI,
    JSObject screen,
  });

  external FullscreenNavigationUI get navigationUI;
  external set navigationUI(FullscreenNavigationUI value);
  external JSObject get screen;
  external set screen(JSObject value);
}

/// Adds missing fields to [Element]
extension NonStandardFieldsOnElement on Element {
  external JSPromise<JSAny?> requestFullscreen([FullscreenOptions options]);
}
