// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'MediaSettings non-parametrized constructor should have correct initial values',
      () {
    const MediaSettings settingsWithNoParameters = MediaSettings();

    expect(
      settingsWithNoParameters.resolutionPreset,
      isNull,
      reason:
          'MediaSettings constructor should have null default resolutionPreset',
    );

    expect(
      settingsWithNoParameters.fps,
      isNull,
      reason: 'MediaSettings constructor should have null default fps',
    );

    expect(
      settingsWithNoParameters.videoBitrate,
      isNull,
      reason: 'MediaSettings constructor should have null default videoBitrate',
    );

    expect(
      settingsWithNoParameters.audioBitrate,
      isNull,
      reason: 'MediaSettings constructor should have null default audioBitrate',
    );

    expect(
      settingsWithNoParameters.enableAudio,
      isFalse,
      reason: 'MediaSettings constructor should have false default enableAudio',
    );
  });

  test('MediaSettings fps should hold parameters', () {
    const MediaSettings settings = MediaSettings(
      resolutionPreset: ResolutionPreset.low,
      fps: 20,
      videoBitrate: 128000,
      audioBitrate: 32000,
      enableAudio: true,
    );

    expect(
      settings.resolutionPreset,
      ResolutionPreset.low,
      reason:
          'MediaSettings constructor should hold resolutionPreset parameter',
    );

    expect(
      settings.fps,
      20,
      reason: 'MediaSettings constructor should hold fps parameter',
    );

    expect(
      settings.videoBitrate,
      128000,
      reason: 'MediaSettings constructor should hold videoBitrate parameter',
    );

    expect(
      settings.audioBitrate,
      32000,
      reason: 'MediaSettings constructor should hold audioBitrate parameter',
    );

    expect(
      settings.enableAudio,
      true,
      reason: 'MediaSettings constructor should hold enableAudio parameter',
    );
  });

  test('MediaSettings hash should be Object.hash of passed parameters', () {
    const MediaSettings settings = MediaSettings(
      resolutionPreset: ResolutionPreset.low,
      fps: 20,
      videoBitrate: 128000,
      audioBitrate: 32000,
      enableAudio: true,
    );

    expect(
      settings.hashCode,
      Object.hash(ResolutionPreset.low, 20, 128000, 32000, true),
      reason:
          'MediaSettings hash() should be equal to Object.hash of parameters',
    );
  });

  test('MediaSettings hash should be Object.hash of passed parameters', () {
    const MediaSettings settings1 = MediaSettings(
      resolutionPreset: ResolutionPreset.low,
      fps: 20,
      videoBitrate: 128000,
      audioBitrate: 32000,
      enableAudio: true,
    );

    const MediaSettings settings1Copy = MediaSettings(
      resolutionPreset: ResolutionPreset.low,
      fps: 20,
      videoBitrate: 128000,
      audioBitrate: 32000,
      enableAudio: true,
    );

    const MediaSettings settings2 = MediaSettings(
      resolutionPreset: ResolutionPreset.high,
      fps: 30,
      videoBitrate: 256000,
      audioBitrate: 64000,
    );

    expect(
      settings1 == settings1Copy,
      isTrue,
      reason:
          'MediaSettings == operator should return true for equal parameters',
    );

    expect(
      settings1 == settings2,
      isFalse,
      reason:
          'MediaSettings == operator should return false for non-equal parameters',
    );
  });
}
