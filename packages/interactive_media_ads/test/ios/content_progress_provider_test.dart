// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads_proxy.dart';
import 'package:interactive_media_ads/src/ios/ios_content_progress_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'content_progress_provider_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<IMAContentPlayhead>(),
])
void main() {
  group('IOSContentProgressProvider', () {
    test('setProgress', () async {
      final MockIMAContentPlayhead mockContentPlayhead =
          MockIMAContentPlayhead();

      final IOSContentProgressProvider provider = IOSContentProgressProvider(
        IOSContentProgressProviderCreationParams(
          proxy: InteractiveMediaAdsProxy(
            newIMAContentPlayhead: () => mockContentPlayhead,
          ),
        ),
      );

      await provider.setProgress(
        progress: const Duration(seconds: 1),
        duration: const Duration(seconds: 10),
      );

      verify(mockContentPlayhead.setCurrentTime(1.0));
    });
  });
}
