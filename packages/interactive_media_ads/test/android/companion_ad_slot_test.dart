// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_companion_ad_slot.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/platform_interface/companion_ad_slot_size.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'companion_ad_slot_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<Object>>[
  MockSpec<ima.CompanionAdSlot>(),
  MockSpec<ima.FrameLayout>(),
  MockSpec<ima.ImaSdkFactory>(),
])
void main() {
  setUp(() {
    ima.PigeonOverrides.pigeon_reset();
  });

  group('AndroidCompanionAdSlot', () {
    test('instantiate CompanionAdSlot with size', () async {
      final frameLayout = ima.FrameLayout.pigeon_detached();
      final mockCompanionAdSlot = MockCompanionAdSlot();

      ima.PigeonOverrides.frameLayout_new = () {
        return frameLayout;
      };
      final mockFactory = MockImaSdkFactory();
      when(
        mockFactory.createCompanionAdSlot(),
      ).thenAnswer((_) async => mockCompanionAdSlot);
      ima.PigeonOverrides.imaSdkFactory_instance = mockFactory;
      final params = AndroidCompanionAdSlotCreationParams(
        size: CompanionAdSlotSize.fixed(width: 300, height: 400),
      );

      final adSlot = AndroidCompanionAdSlot(params);
      await adSlot.getNativeCompanionAdSlot();

      verify(mockCompanionAdSlot.setContainer(frameLayout));
      verify(mockCompanionAdSlot.setSize(300, 400));
    });

    test('AndroidCompanionAdSlot receives onClick', () async {
      final mockCompanionAdSlot = MockCompanionAdSlot();
      ima.PigeonOverrides.frameLayout_new = () =>
          ima.FrameLayout.pigeon_detached();
      final mockFactory = MockImaSdkFactory();
      when(
        mockFactory.createCompanionAdSlot(),
      ).thenAnswer((_) async => mockCompanionAdSlot);
      ima.PigeonOverrides.imaSdkFactory_instance = mockFactory;
      ima.PigeonOverrides.companionAdSlotClickListener_new =
          ({
            required void Function(ima.CompanionAdSlotClickListener)
            onCompanionAdClick,
          }) {
            return ima.CompanionAdSlotClickListener.pigeon_detached(
              onCompanionAdClick: onCompanionAdClick,
            );
          };
      final params = AndroidCompanionAdSlotCreationParams(
        size: CompanionAdSlotSize.fixed(width: 300, height: 400),
        onClicked: expectAsync0(() {}),
      );

      final adSlot = AndroidCompanionAdSlot(params);
      await adSlot.getNativeCompanionAdSlot();

      final clickListener =
          verify(
                mockCompanionAdSlot.addClickListener(captureAny),
              ).captured.single
              as ima.CompanionAdSlotClickListener;

      clickListener.onCompanionAdClick(clickListener);
    });
  });
}
