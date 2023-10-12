// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: always_specify_types

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

  group('MediaSettings == operator', () {
    const ResolutionPreset preset1 = ResolutionPreset.low;
    const int fps1 = 20;
    const int videoBitrate1 = 128000;
    const int audioBitrate1 = 32000;
    const bool enableAudio1 = true;

    const ResolutionPreset preset2 = ResolutionPreset.high;
    const int fps2 = fps1 + 10;
    const int videoBitrate2 = videoBitrate1 * 2;
    const int audioBitrate2 = audioBitrate1 * 2;
    const bool enableAudio2 = !enableAudio1;

    const MediaSettings settings1 = MediaSettings(
      resolutionPreset: ResolutionPreset.low,
      fps: 20,
      videoBitrate: 128000,
      audioBitrate: 32000,
      enableAudio: true,
    );

    // test operator== on parameters combination.
    void checkParameters(List<dynamic> args) {
      final resolutionPreset = args[0] as ResolutionPreset?;
      final fps = args[1] as int?;
      final videoBitrate = args[2] as int?;
      final audioBitrate = args[3] as int?;
      final enableAudio = args[4]! as bool;

      final MediaSettings settings2 = MediaSettings(
          resolutionPreset: resolutionPreset,
          fps: fps,
          videoBitrate: videoBitrate,
          audioBitrate: audioBitrate,
          enableAudio: enableAudio);

      if (resolutionPreset == preset1 &&
          fps == fps1 &&
          videoBitrate == videoBitrate1 &&
          audioBitrate == audioBitrate1 &&
          enableAudio == enableAudio1) {
        expect(
          settings1 == settings2,
          isTrue,
          reason:
              'MediaSettings == operator should return true for equal parameters: $settings1 == $settings2',
        );
      } else {
        expect(
          settings1 == settings2,
          isFalse,
          reason:
              'MediaSettings == operator should return false for non-equal parameters: $settings1 != $settings2',
        );
      }
    }

    test(
        'MediaSettings == operator should be short-circuit AND of all parameters',
        () {
      // Sets of various parameters, including those equal and not equal to the corresponding `settings1` parameters
      final params = [
        {preset1, preset2, null},
        {fps1, fps2, null},
        {videoBitrate1, videoBitrate2, null},
        {audioBitrate1, audioBitrate2, null},
        {enableAudio1, enableAudio2},
      ];

      // recursively check all possible parameters combinations
      void combine(List<Set<dynamic>> params, List<dynamic> args, int level) {
        if (params.length == level) {
          // now args contains all required parameters, so check `operator ==` now
          checkParameters(args);
        } else {
          for (final variant in params[level]) {
            combine(params, [...args, variant], level + 1);
          }
        }
      }

      combine(params, [], 0);
    });

    test('Identical objects should be equal', () {
      const MediaSettings settingsIdentical = settings1;

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
