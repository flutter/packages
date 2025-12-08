// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart';
import 'package:interactive_media_ads/src/ios/ios_content_progress_provider.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'content_progress_provider_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<IMAContentPlayhead>()])
void main() {
  setUp(() {
    PigeonOverrides.pigeon_reset();
  });

  group('IOSContentProgressProvider', () {
    test('setProgress', () async {
      final mockContentPlayhead = MockIMAContentPlayhead();

      PigeonOverrides.iMAContentPlayhead_new = () => mockContentPlayhead;

      final provider = IOSContentProgressProvider(
        const PlatformContentProgressProviderCreationParams(),
      );

      await provider.setProgress(
        progress: const Duration(seconds: 1),
        duration: const Duration(seconds: 10),
      );

      verify(mockContentPlayhead.setCurrentTime(1.0));
    });
  });
}
