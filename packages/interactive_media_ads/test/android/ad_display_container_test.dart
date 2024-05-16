// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_ad_display_container.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:mockito/annotations.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.AdDisplayContainer>(),
  MockSpec<ima.FrameLayout>(),
  MockSpec<ima.VideoView>(),
])
void main() {
  group('AndroidAdDisplayContainer', () {
    testWidgets('build', (WidgetTester tester) async {
      final AndroidAdDisplayContainer container = AndroidAdDisplayContainer(
        AndroidAdDisplayContainerCreationParams(
          key: const Key('testKey'),
          onContainerAdded: (_) {},
        ),
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) => container.build(context),
      ));

      expect(find.byType(PlatformViewLink), findsOneWidget);
      expect(find.byKey(const Key('testKey')), findsOneWidget);
    });
  });
}
