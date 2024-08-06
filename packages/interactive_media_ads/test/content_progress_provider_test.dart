// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/content_progress_provider.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_content_progress_provider.dart';

import 'test_stubs.dart';

void main() {
  test('setProgress', () async {
    final TestContentProgressProvider platformProvider =
        TestContentProgressProvider(
      const PlatformContentProgressProviderCreationParams(),
      onSetProgress: expectAsync1((Duration progress) async {
        expect(progress, equals(const Duration(seconds: 1)));
      }),
    );

    final ContentProgressProvider provider =
        ContentProgressProvider.fromPlatform(
      platformProvider,
    );
    await provider.setProgress(const Duration(seconds: 1));
  });
}
