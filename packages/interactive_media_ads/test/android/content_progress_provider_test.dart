// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_content_progress_provider.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'content_progress_provider_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<ima.ContentProgressProvider>()])
void main() {
  setUp(() {
    ima.PigeonOverrides.pigeon_reset();
  });

  group('AndroidContentProgressProvider', () {
    test('setProgress', () async {
      final mockContentProgressProvider = MockContentProgressProvider();

      ima.PigeonOverrides.contentProgressProvider_new = () =>
          mockContentProgressProvider;
      ima.PigeonOverrides.videoProgressUpdate_new =
          ({required int currentTimeMs, required int durationMs}) {
            expect(currentTimeMs, 1000);
            expect(durationMs, 10000);
            return ima.VideoProgressUpdate.pigeon_detached();
          };
      final provider = AndroidContentProgressProvider(
        const PlatformContentProgressProviderCreationParams(),
      );

      await provider.setProgress(
        progress: const Duration(seconds: 1),
        duration: const Duration(seconds: 10),
      );

      verify(mockContentProgressProvider.setContentProgress(any));
    });
  });
}
