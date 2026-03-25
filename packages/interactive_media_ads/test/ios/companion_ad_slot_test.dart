// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart';
import 'package:interactive_media_ads/src/ios/ios_companion_ad_slot.dart';
import 'package:interactive_media_ads/src/platform_interface/companion_ad_slot_size.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'companion_ad_slot_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[MockSpec<IMACompanionAdSlot>()])
void main() {
  setUp(() {
    PigeonOverrides.pigeon_reset();
  });

  group('IOSCompanionAdSlot', () {
    test('instantiate CompanionAdSlot with size', () async {
      final mockCompanionAdSlot = MockIMACompanionAdSlot();
      PigeonOverrides.iMACompanionAdSlot_size =
          ({required int width, required int height, required UIView view}) {
            expect(width, 300);
            expect(height, 400);
            return mockCompanionAdSlot;
          };
      PigeonOverrides.uIView_new = () {
        return UIView.pigeon_detached();
      };
      final params = IOSCompanionAdSlotCreationParams(
        size: CompanionAdSlotSize.fixed(width: 300, height: 400),
      );

      final adSlot = IOSCompanionAdSlot(params);
      expect(adSlot.nativeCompanionAdSlot, mockCompanionAdSlot);
    });

    test('IOSCompanionAdSlot receives onClick', () async {
      final mockCompanionAdSlot = MockIMACompanionAdSlot();

      PigeonOverrides.iMACompanionAdSlot_size =
          ({required int width, required int height, required UIView view}) {
            return mockCompanionAdSlot;
          };
      PigeonOverrides.uIView_new = () {
        return UIView.pigeon_detached();
      };
      PigeonOverrides.iMACompanionDelegate_new =
          ({
            void Function(IMACompanionDelegate, IMACompanionAdSlot, bool)?
            companionAdSlotFilled,
            void Function(IMACompanionDelegate, IMACompanionAdSlot)?
            companionSlotWasClicked,
          }) {
            return IMACompanionDelegate.pigeon_detached(
              companionAdSlotFilled: companionAdSlotFilled,
              companionSlotWasClicked: companionSlotWasClicked,
            );
          };

      final params = IOSCompanionAdSlotCreationParams(
        size: CompanionAdSlotSize.fixed(width: 300, height: 400),
        onClicked: expectAsync0(() {}),
      );

      final adSlot = IOSCompanionAdSlot(params);
      expect(adSlot.nativeCompanionAdSlot, mockCompanionAdSlot);

      final delegate =
          verify(mockCompanionAdSlot.setDelegate(captureAny)).captured.single
              as IMACompanionDelegate;

      delegate.companionSlotWasClicked!(delegate, adSlot.nativeCompanionAdSlot);
    });
  });
}
