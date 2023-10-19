// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  group('VideoPlayerWebOptionsControls', () {
    late VideoPlayerWebOptionsControls controls;

    group('when disabled', () {
      setUp(() {
        controls = const VideoPlayerWebOptionsControls.disabled();
      });

      test(
        'expect enabled isFalse',
        () {
          expect(controls.enabled, isFalse);
        },
      );
    });

    group('when enabled', () {
      group('and all options are allowed', () {
        setUp(() {
          controls = const VideoPlayerWebOptionsControls.enabled();
        });

        test(
          'expect enabled isTrue',
          () {
            expect(controls.enabled, isTrue);
            expect(controls.allowDownload, isTrue);
            expect(controls.allowFullscreen, isTrue);
            expect(controls.allowPlaybackRate, isTrue);
            expect(controls.allowPictureInPicture, isTrue);
          },
        );

        test(
          'expect controlsList isEmpty',
          () {
            expect(controls.controlsList, isEmpty);
          },
        );
      });

      group('and some options are disallowed', () {
        setUp(() {
          controls = const VideoPlayerWebOptionsControls.enabled(
            allowDownload: false,
            allowFullscreen: false,
            allowPlaybackRate: false,
          );
        });

        test(
          'expect enabled isTrue',
          () {
            expect(controls.enabled, isTrue);
            expect(controls.allowDownload, isFalse);
            expect(controls.allowFullscreen, isFalse);
            expect(controls.allowPlaybackRate, isFalse);
            expect(controls.allowPictureInPicture, isTrue);
          },
        );

        test(
          'expect controlsList is correct',
          () {
            expect(
              controls.controlsList,
              'nodownload nofullscreen noplaybackrate',
            );
          },
        );
      });
    });
  });
}
