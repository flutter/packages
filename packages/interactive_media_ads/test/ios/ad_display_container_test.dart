// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

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

  group('IOSAdDisplayContainer', () {
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
      late final void Function(UIViewController, bool) viewDidAppearCallback;
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newUIViewController: ({
          void Function(UIViewController, bool)? viewDidAppear,
        }) {
          viewDidAppearCallback = viewDidAppear!;

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

      final Completer<void> onContainerAddedCompleter = Completer<void>();

      final IOSAdDisplayContainer container = IOSAdDisplayContainer(
        IOSAdDisplayContainerCreationParams(
          onContainerAdded: (_) => onContainerAddedCompleter.complete(),
          imaProxy: imaProxy,
        ),
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) => container.build(context),
      ));

      final UiKitView view =
          find.byType(UiKitView).evaluate().single.widget as UiKitView;
      view.onPlatformViewCreated!.call(0);

      // Ensure onContainerAdded is not called until viewDidAppear is called.
      expect(onContainerAddedCompleter.isCompleted, isFalse);

      viewDidAppearCallback(MockUIViewController(), true);
      await tester.pumpAndSettle();

      expect(onContainerAddedCompleter.isCompleted, isTrue);
    });
  });
}
