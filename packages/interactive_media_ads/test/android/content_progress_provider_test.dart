// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_content_progress_provider.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/android/interactive_media_ads_proxy.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'content_progress_provider_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.ContentProgressProvider>(),
])
void main() {
  group('AndroidContentProgressProvider', () {
    test('setProgress', () async {
      final MockContentProgressProvider mockContentProgressProvider =
          MockContentProgressProvider();

      final AndroidContentProgressProvider provider =
          AndroidContentProgressProvider(
        AndroidContentProgressProviderCreationParams(
          proxy: InteractiveMediaAdsProxy(
            newContentProgressProvider: () => mockContentProgressProvider,
            newVideoProgressUpdate: ({
              required int currentTimeMs,
              required int durationMs,
            }) {
              expect(currentTimeMs, 1000);
              expect(durationMs, 10000);
              return ima.VideoProgressUpdate.pigeon_detached(
                pigeon_instanceManager: ima.PigeonInstanceManager(
                  onWeakReferenceRemoved: (_) {},
                ),
              );
            },
          ),
        ),
      );

      await provider.setProgress(
        progress: const Duration(seconds: 1),
        duration: const Duration(seconds: 10),
      );

      verify(mockContentProgressProvider.setContentProgress(any));
    });
  });
}
