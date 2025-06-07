// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/android/android_companion_ad_slot.dart';
import 'package:interactive_media_ads/src/android/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/android/interactive_media_ads_proxy.dart';
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
  group('AndroidCompanionAdSlot', () {
    test('instantiate CompanionAdSlot with size', () async {
      final ima.FrameLayout frameLayout = ima.FrameLayout.pigeon_detached(
        pigeon_instanceManager: _TestInstanceManager(),
      );
      final MockCompanionAdSlot mockCompanionAdSlot = MockCompanionAdSlot();
      final AndroidCompanionAdSlotCreationParams params =
          AndroidCompanionAdSlotCreationParams(
        size: CompanionAdSlotSize.fixed(width: 300, height: 400),
        proxy: InteractiveMediaAdsProxy(
          newFrameLayout: () {
            return frameLayout;
          },
          instanceImaSdkFactory: () {
            final MockImaSdkFactory mockFactory = MockImaSdkFactory();
            when(mockFactory.createCompanionAdSlot()).thenAnswer(
              (_) async => mockCompanionAdSlot,
            );
            return mockFactory;
          },
        ),
      );

      final AndroidCompanionAdSlot adSlot = AndroidCompanionAdSlot(params);
      await adSlot.getNativeCompanionAdSlot();

      verify(mockCompanionAdSlot.setContainer(frameLayout));
      verify(mockCompanionAdSlot.setSize(300, 400));
    });

    test('AndroidCompanionAdSlot receives onClick', () async {
      final MockCompanionAdSlot mockCompanionAdSlot = MockCompanionAdSlot();
      final AndroidCompanionAdSlotCreationParams params =
          AndroidCompanionAdSlotCreationParams(
        size: CompanionAdSlotSize.fixed(width: 300, height: 400),
        onClicked: expectAsync0(() {}),
        proxy: InteractiveMediaAdsProxy(
          newFrameLayout: () {
            return ima.FrameLayout.pigeon_detached(
              pigeon_instanceManager: _TestInstanceManager(),
            );
          },
          instanceImaSdkFactory: () {
            final MockImaSdkFactory mockFactory = MockImaSdkFactory();
            when(mockFactory.createCompanionAdSlot()).thenAnswer(
              (_) async => mockCompanionAdSlot,
            );
            return mockFactory;
          },
          newCompanionAdSlotClickListener: ({
            required void Function(
              ima.CompanionAdSlotClickListener,
            ) onCompanionAdClick,
          }) {
            return ima.CompanionAdSlotClickListener.pigeon_detached(
              onCompanionAdClick: onCompanionAdClick,
              pigeon_instanceManager: _TestInstanceManager(),
            );
          },
        ),
      );

      final AndroidCompanionAdSlot adSlot = AndroidCompanionAdSlot(params);
      await adSlot.getNativeCompanionAdSlot();

      final ima.CompanionAdSlotClickListener clickListener =
          verify(mockCompanionAdSlot.addClickListener(captureAny))
              .captured
              .single as ima.CompanionAdSlotClickListener;

      clickListener.onCompanionAdClick(clickListener);
    });
  });
}

class _TestInstanceManager extends ima.PigeonInstanceManager {
  _TestInstanceManager() : super(onWeakReferenceRemoved: (_) {});
}
