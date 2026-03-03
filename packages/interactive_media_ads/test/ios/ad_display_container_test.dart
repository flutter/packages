// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart';
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

  setUp(() {
    PigeonOverrides.pigeon_reset();
  });

  group('IOSAdDisplayContainer', () {
    testWidgets('build with key', (WidgetTester tester) async {
      final container = IOSAdDisplayContainer(
        IOSAdDisplayContainerCreationParams(
          key: const Key('testKey'),
          onContainerAdded: (_) {},
        ),
      );

      await tester.pumpWidget(
        Builder(builder: (BuildContext context) => container.build(context)),
      );

      expect(find.byType(UiKitView), findsOneWidget);
      expect(find.byKey(const Key('testKey')), findsOneWidget);
    });

    testWidgets('onContainerAdded is called', (WidgetTester tester) async {
      late final void Function(UIViewController, bool) viewDidAppearCallback;
      PigeonOverrides.uIViewController_new =
          ({void Function(UIViewController, bool)? viewDidAppear}) {
            viewDidAppearCallback = viewDidAppear!;

            final view = UIView.pigeon_detached();
            PigeonInstanceManager.instance.addDartCreatedInstance(view);

            final mockController = MockUIViewController();
            when(mockController.view).thenReturn(view);
            return mockController;
          };
      PigeonOverrides.iMAAdDisplayContainer_new =
          ({
            required UIView adContainer,
            UIViewController? adContainerViewController,
            List<IMACompanionAdSlot>? companionSlots,
          }) => MockIMAAdDisplayContainer();

      final onContainerAddedCompleter = Completer<void>();

      final container = IOSAdDisplayContainer(
        IOSAdDisplayContainerCreationParams(
          onContainerAdded: (_) => onContainerAddedCompleter.complete(),
        ),
      );

      await tester.pumpWidget(
        Builder(builder: (BuildContext context) => container.build(context)),
      );

      final view = find.byType(UiKitView).evaluate().single.widget as UiKitView;
      view.onPlatformViewCreated!.call(0);

      // Ensure onContainerAdded is not called until viewDidAppear is called.
      expect(onContainerAddedCompleter.isCompleted, isFalse);

      viewDidAppearCallback(MockUIViewController(), true);
      await tester.pumpAndSettle();

      expect(onContainerAddedCompleter.isCompleted, isTrue);
    });

    testWidgets('AdDisplayContainer ads CompanionAdSlots', (
      WidgetTester tester,
    ) async {
      final mockCompanionAdSlot = MockIMACompanionAdSlot();
      late final void Function(UIViewController, bool) viewDidAppearCallback;
      final addedAdSlotsCompleter = Completer<List<IMACompanionAdSlot>?>();
      PigeonOverrides.uIViewController_new =
          ({void Function(UIViewController, bool)? viewDidAppear}) {
            viewDidAppearCallback = viewDidAppear!;

            final view = UIView.pigeon_detached();
            PigeonInstanceManager.instance.addDartCreatedInstance(view);

            final mockController = MockUIViewController();
            when(mockController.view).thenReturn(view);
            return mockController;
          };
      PigeonOverrides.iMAAdDisplayContainer_new =
          ({
            required UIView adContainer,
            UIViewController? adContainerViewController,
            List<IMACompanionAdSlot>? companionSlots,
          }) {
            addedAdSlotsCompleter.complete(companionSlots);
            return MockIMAAdDisplayContainer();
          };
      PigeonOverrides.iMACompanionAdSlot_size =
          ({required int width, required int height, required UIView view}) {
            expect(width, 300);
            expect(height, 400);
            return mockCompanionAdSlot;
          };
      PigeonOverrides.uIView_new = () {
        return UIView.pigeon_detached();
      };

      final onContainerAddedCompleter = Completer<void>();

      final container = IOSAdDisplayContainer(
        IOSAdDisplayContainerCreationParams(
          onContainerAdded: (_) => onContainerAddedCompleter.complete(),
          companionSlots: <PlatformCompanionAdSlot>[
            IOSCompanionAdSlot(
              IOSCompanionAdSlotCreationParams(
                size: CompanionAdSlotSize.fixed(width: 300, height: 400),
              ),
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        Builder(builder: (BuildContext context) => container.build(context)),
      );

      final view = find.byType(UiKitView).evaluate().single.widget as UiKitView;
      view.onPlatformViewCreated!.call(0);

      viewDidAppearCallback(MockUIViewController(), true);
      await tester.pumpAndSettle();

      await onContainerAddedCompleter.future;

      expect(await addedAdSlotsCompleter.future, <IMACompanionAdSlot>[
        mockCompanionAdSlot,
      ]);
    });
  });
}
