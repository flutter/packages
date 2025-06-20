// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads_proxy.dart';
import 'package:interactive_media_ads/src/ios/ios_ad_display_container.dart';
import 'package:interactive_media_ads/src/ios/ios_companion_ad_slot.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ad_display_container_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<IMAAdDisplayContainer>(),
  MockSpec<IMACompanionAdSlot>(),
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
          List<IMACompanionAdSlot>? companionSlots,
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

    testWidgets('AdDisplayContainer ads CompanionAdSlots',
        (WidgetTester tester) async {
      final PigeonInstanceManager instanceManager = PigeonInstanceManager(
        onWeakReferenceRemoved: (_) {},
      );

      final MockIMACompanionAdSlot mockCompanionAdSlot =
          MockIMACompanionAdSlot();
      late final void Function(UIViewController, bool) viewDidAppearCallback;
      final Completer<List<IMACompanionAdSlot>?> addedAdSlotsCompleter =
          Completer<List<IMACompanionAdSlot>?>();
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newUIViewController: ({
          void Function(UIViewController, bool)? viewDidAppear,
        }) {
          viewDidAppearCallback = viewDidAppear!;

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
          List<IMACompanionAdSlot>? companionSlots,
        }) {
          addedAdSlotsCompleter.complete(companionSlots);
          return MockIMAAdDisplayContainer();
        },
        sizeIMACompanionAdSlot: ({
          required int width,
          required int height,
          required UIView view,
        }) {
          expect(width, 300);
          expect(height, 400);
          return mockCompanionAdSlot;
        },
        newUIView: () {
          return UIView.pigeon_detached(
            pigeon_instanceManager: instanceManager,
          );
        },
      );

      final Completer<void> onContainerAddedCompleter = Completer<void>();

      final IOSAdDisplayContainer container = IOSAdDisplayContainer(
        IOSAdDisplayContainerCreationParams(
          onContainerAdded: (_) => onContainerAddedCompleter.complete(),
          companionSlots: <PlatformCompanionAdSlot>[
            IOSCompanionAdSlot(
              IOSCompanionAdSlotCreationParams(
                size: CompanionAdSlotSize.fixed(width: 300, height: 400),
                proxy: imaProxy,
              ),
            )
          ],
          imaProxy: imaProxy,
        ),
      );

      await tester.pumpWidget(Builder(
        builder: (BuildContext context) => container.build(context),
      ));

      final UiKitView view =
          find.byType(UiKitView).evaluate().single.widget as UiKitView;
      view.onPlatformViewCreated!.call(0);

      viewDidAppearCallback(MockUIViewController(), true);
      await tester.pumpAndSettle();

      await onContainerAddedCompleter.future;

      expect(
        await addedAdSlotsCompleter.future,
        <IMACompanionAdSlot>[mockCompanionAdSlot],
      );
    });
  });
}
