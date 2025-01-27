// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/content_progress_provider.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_content_progress_provider.dart';

import 'test_stubs.dart';

void main() {
  test('setProgress', () async {
    late final Duration callbackProgress;
    late final Duration callbackDuration;

    final TestContentProgressProvider platformProvider =
        TestContentProgressProvider(
      const PlatformContentProgressProviderCreationParams(),
      onSetProgress: ({
        required Duration progress,
        required Duration duration,
      }) async {
        callbackProgress = progress;
        callbackDuration = duration;
      },
    );

    final ContentProgressProvider provider =
        ContentProgressProvider.fromPlatform(
      platformProvider,
    );

    await provider.setProgress(
      progress: const Duration(seconds: 1),
      duration: const Duration(seconds: 10),
    );

    expect(callbackProgress, const Duration(seconds: 1));
    expect(callbackDuration, const Duration(seconds: 10));
  });
}
