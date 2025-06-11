// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads_proxy.dart';
import 'package:interactive_media_ads/src/ios/ios_companion_ad_slot.dart';
import 'package:interactive_media_ads/src/platform_interface/companion_ad_slot_size.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'companion_ad_slot_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<IMACompanionAdSlot>(),
])
void main() {
  group('IOSCompanionAdSlot', () {
    test('instantiate CompanionAdSlot with size', () async {
      final MockIMACompanionAdSlot mockCompanionAdSlot =
          MockIMACompanionAdSlot();
      final IOSCompanionAdSlotCreationParams params =
          IOSCompanionAdSlotCreationParams(
        size: CompanionAdSlotSize.fixed(width: 300, height: 400),
        proxy: InteractiveMediaAdsProxy(
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
              pigeon_instanceManager: _TestInstanceManager(),
            );
          },
        ),
      );

      final IOSCompanionAdSlot adSlot = IOSCompanionAdSlot(params);
      expect(adSlot.nativeCompanionAdSlot, mockCompanionAdSlot);
    });

    test('IOSCompanionAdSlot receives onClick', () async {
      final MockIMACompanionAdSlot mockCompanionAdSlot =
          MockIMACompanionAdSlot();
      final IOSCompanionAdSlotCreationParams params =
          IOSCompanionAdSlotCreationParams(
        size: CompanionAdSlotSize.fixed(width: 300, height: 400),
        onClicked: expectAsync0(() {}),
        proxy: InteractiveMediaAdsProxy(
          sizeIMACompanionAdSlot: ({
            required int width,
            required int height,
            required UIView view,
          }) {
            return mockCompanionAdSlot;
          },
          newUIView: () {
            return UIView.pigeon_detached(
              pigeon_instanceManager: _TestInstanceManager(),
            );
          },
          newIMACompanionDelegate: ({
            void Function(
              IMACompanionDelegate,
              IMACompanionAdSlot,
              bool,
            )? companionAdSlotFilled,
            void Function(
              IMACompanionDelegate,
              IMACompanionAdSlot,
            )? companionSlotWasClicked,
          }) {
            return IMACompanionDelegate.pigeon_detached(
              companionAdSlotFilled: companionAdSlotFilled,
              companionSlotWasClicked: companionSlotWasClicked,
              pigeon_instanceManager: _TestInstanceManager(),
            );
          },
        ),
      );

      final IOSCompanionAdSlot adSlot = IOSCompanionAdSlot(params);
      expect(adSlot.nativeCompanionAdSlot, mockCompanionAdSlot);

      final IMACompanionDelegate delegate =
          verify(mockCompanionAdSlot.setDelegate(captureAny)).captured.single
              as IMACompanionDelegate;

      delegate.companionSlotWasClicked!(delegate, adSlot.nativeCompanionAdSlot);
    });
  });
}

class _TestInstanceManager extends PigeonInstanceManager {
  _TestInstanceManager() : super(onWeakReferenceRemoved: (_) {});
}
