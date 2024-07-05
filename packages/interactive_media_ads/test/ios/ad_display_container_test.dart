// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads_proxy.dart';
import 'package:interactive_media_ads/src/ios/ios_ad_display_container.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ad_display_container_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<IMAAdDisplayContainer>(),
  MockSpec<UIView>(),
  MockSpec<UIViewController>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidAdDisplayContainer', () {
    testWidgets('build with key', (WidgetTester tester) async {
      final IOSAdDisplayContainer container = IOSAdDisplayContainer(
        IOSAdDisplayContainerCreationParams(
          key: const Key('testKey'),
          onContainerAdded: (_) {},
        ),
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) => container.build(context),
      ));

      expect(find.byType(UiKitView), findsOneWidget);
      expect(find.byKey(const Key('testKey')), findsOneWidget);
    });

    testWidgets('onContainerAdded is called', (WidgetTester tester) async {
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newUIViewController: () {
          final PigeonInstanceManager instanceManager = PigeonInstanceManager(
            onWeakReferenceRemoved: (_) {},
          );
          final UIView view =
              UIView.pigeon_detached(pigeon_instanceManager: instanceManager);
          instanceManager.addDartCreatedInstance(view);

          final MockUIViewController mockController = MockUIViewController();
          when(mockController.view).thenReturn(view);
          return mockController;
        },
        newIMAAdDisplayContainer: ({
          required UIView adContainer,
          UIViewController? adContainerViewController,
        }) =>
            MockIMAAdDisplayContainer(),
      );

      final IOSAdDisplayContainer container = IOSAdDisplayContainer(
        IOSAdDisplayContainerCreationParams(
          onContainerAdded: expectAsync1((_) {}),
          imaProxy: imaProxy,
        ),
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) => container.build(context),
      ));

      final UiKitView view =
          find.byType(UiKitView).evaluate().single.widget as UiKitView;
      view.onPlatformViewCreated!.call(0);

      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });
}
