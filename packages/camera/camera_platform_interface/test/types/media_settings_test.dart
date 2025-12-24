// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: always_specify_types

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'MediaSettings non-parametrized constructor should have correct initial values',
    () {
      const settingsWithNoParameters = MediaSettings();

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
        reason:
            'MediaSettings constructor should have null default videoBitrate',
      );

      expect(
        settingsWithNoParameters.audioBitrate,
        isNull,
        reason:
            'MediaSettings constructor should have null default audioBitrate',
      );

      expect(
        settingsWithNoParameters.enableAudio,
        isFalse,
        reason:
            'MediaSettings constructor should have false default enableAudio',
      );
    },
  );

  test('MediaSettings fps should hold parameters', () {
    const settings = MediaSettings(
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
    const settings = MediaSettings(
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

  group('MediaSettings == operator', () {
    const ResolutionPreset preset1 = ResolutionPreset.low;
    const fps1 = 20;
    const videoBitrate1 = 128000;
    const audioBitrate1 = 32000;
    const enableAudio1 = true;

    const ResolutionPreset preset2 = ResolutionPreset.high;
    const int fps2 = fps1 + 10;
    const int videoBitrate2 = videoBitrate1 * 2;
    const int audioBitrate2 = audioBitrate1 * 2;
    const bool enableAudio2 = !enableAudio1;

    const settings1 = MediaSettings(
      resolutionPreset: ResolutionPreset.low,
      fps: 20,
      videoBitrate: 128000,
      audioBitrate: 32000,
      enableAudio: true,
    );

    test('should compare resolutionPreset', () {
      const settings2 = MediaSettings(
        resolutionPreset: preset2,
        fps: fps1,
        videoBitrate: videoBitrate1,
        audioBitrate: audioBitrate1,
        enableAudio: enableAudio1,
      );

      expect(settings1 == settings2, isFalse);
    });

    test('should compare fps', () {
      const settings2 = MediaSettings(
        resolutionPreset: preset1,
        fps: fps2,
        videoBitrate: videoBitrate1,
        audioBitrate: audioBitrate1,
        enableAudio: enableAudio1,
      );

      expect(settings1 == settings2, isFalse);
    });

    test('should compare videoBitrate', () {
      const settings2 = MediaSettings(
        resolutionPreset: preset1,
        fps: fps1,
        videoBitrate: videoBitrate2,
        audioBitrate: audioBitrate1,
        enableAudio: enableAudio1,
      );

      expect(settings1 == settings2, isFalse);
    });

    test('should compare audioBitrate', () {
      const settings2 = MediaSettings(
        resolutionPreset: preset1,
        fps: fps1,
        videoBitrate: videoBitrate1,
        audioBitrate: audioBitrate2,
        enableAudio: enableAudio1,
      );

      expect(settings1 == settings2, isFalse);
    });

    test('should compare enableAudio', () {
      const settings2 = MediaSettings(
        resolutionPreset: preset1,
        fps: fps1,
        videoBitrate: videoBitrate1,
        audioBitrate: audioBitrate1,
        // ignore: avoid_redundant_argument_values
        enableAudio: enableAudio2,
      );

      expect(settings1 == settings2, isFalse);
    });

    test('should return true when all parameters are equal', () {
      const sameSettings = MediaSettings(
        resolutionPreset: preset1,
        fps: fps1,
        videoBitrate: videoBitrate1,
        audioBitrate: audioBitrate1,
        enableAudio: enableAudio1,
      );

      expect(settings1 == sameSettings, isTrue);
    });

    test('Identical objects should be equal', () {
      const settingsIdentical = settings1;

      expect(
        settings1 == settingsIdentical,
        isTrue,
        reason:
            'MediaSettings == operator should return true for identical objects',
      );
    });

    test('Objects of different types should be non-equal', () {
      expect(
        settings1 == Object(),
        isFalse,
        reason:
            'MediaSettings == operator should return false for objects of different types',
      );
    });
  });
}
