// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart';
import 'package:interactive_media_ads/src/ios/ios_ads_manager_delegate.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart'
    hide AdEventType;

void main() {
  group('Ad', () {
    setUp(() {
      PigeonOverrides.pigeon_reset();
    });

    test('UniversalAdID sets unknown values to null', () {
      late final void Function(IMAAdsManagerDelegate, IMAAdsManager, IMAAdEvent)
      didReceiveAdEventCallback;

      late final IMAAdsManagerDelegate delegate;
      PigeonOverrides.iMAAdsManagerDelegate_new =
          ({
            required void Function(
              IMAAdsManagerDelegate,
              IMAAdsManager,
              IMAAdEvent,
            )
            didReceiveAdEvent,
            required void Function(
              IMAAdsManagerDelegate,
              IMAAdsManager,
              IMAAdError,
            )
            didReceiveAdError,
            required void Function(IMAAdsManagerDelegate, IMAAdsManager)
            didRequestContentPause,
            required void Function(IMAAdsManagerDelegate, IMAAdsManager)
            didRequestContentResume,
          }) {
            didReceiveAdEventCallback = didReceiveAdEvent;
            delegate = IMAAdsManagerDelegate.pigeon_detached(
              didReceiveAdEvent: didReceiveAdEvent,
              didReceiveAdError: didReceiveAdError,
              didRequestContentPause: didRequestContentPause,
              didRequestContentResume: didRequestContentResume,
            );
            return delegate;
          };

      final adsManagerDelegate = IOSAdsManagerDelegate(
        IOSAdsManagerDelegateCreationParams(
          onAdEvent: expectAsync1((PlatformAdEvent event) {
            expect(event.ad!.universalAdIds.single.adIdValue, isNull);
            expect(event.ad!.universalAdIds.single.adIdRegistry, isNull);
          }),
        ),
      );

      // Calls the field because the value is instantiated lazily.
      // ignore: unnecessary_statements
      adsManagerDelegate.delegate;

      didReceiveAdEventCallback(
        delegate,
        IMAAdsManager.pigeon_detached(adCuePoints: const <double>[]),
        IMAAdEvent.pigeon_detached(
          type: AdEventType.allAdsCompleted,
          typeString: 'typeString',
          ad: createTestAd(
            universalAdIds: <IMAUniversalAdID>[
              IMAUniversalAdID.pigeon_detached(
                adIDRegistry: 'unknown',
                adIDValue: 'unknown',
              ),
            ],
          ),
        ),
      );
    });

    test('CompanionAd sets 0 values for height/width to null', () {
      late final void Function(IMAAdsManagerDelegate, IMAAdsManager, IMAAdEvent)
      didReceiveAdEventCallback;

      late final IMAAdsManagerDelegate delegate;
      PigeonOverrides.iMAAdsManagerDelegate_new =
          ({
            required void Function(
              IMAAdsManagerDelegate,
              IMAAdsManager,
              IMAAdEvent,
            )
            didReceiveAdEvent,
            required void Function(
              IMAAdsManagerDelegate,
              IMAAdsManager,
              IMAAdError,
            )
            didReceiveAdError,
            required void Function(IMAAdsManagerDelegate, IMAAdsManager)
            didRequestContentPause,
            required void Function(IMAAdsManagerDelegate, IMAAdsManager)
            didRequestContentResume,
          }) {
            didReceiveAdEventCallback = didReceiveAdEvent;
            delegate = IMAAdsManagerDelegate.pigeon_detached(
              didReceiveAdEvent: didReceiveAdEvent,
              didReceiveAdError: didReceiveAdError,
              didRequestContentPause: didRequestContentPause,
              didRequestContentResume: didRequestContentResume,
            );
            return delegate;
          };

      final adsManagerDelegate = IOSAdsManagerDelegate(
        IOSAdsManagerDelegateCreationParams(
          onAdEvent: expectAsync1((PlatformAdEvent event) {
            expect(event.ad!.companionAds.single.width, isNull);
            expect(event.ad!.companionAds.single.height, isNull);
          }),
        ),
      );

      // Calls the field because the value is instantiated lazily.
      // ignore: unnecessary_statements
      adsManagerDelegate.delegate;

      didReceiveAdEventCallback(
        delegate,
        IMAAdsManager.pigeon_detached(adCuePoints: const <double>[]),
        IMAAdEvent.pigeon_detached(
          type: AdEventType.allAdsCompleted,
          typeString: 'typeString',
          ad: createTestAd(
            companionAds: <IMACompanionAd>[
              IMACompanionAd.pigeon_detached(height: 0, width: 0),
            ],
          ),
        ),
      );
    });

    test('Ad sets durations of -1 to null', () {
      late final void Function(IMAAdsManagerDelegate, IMAAdsManager, IMAAdEvent)
      didReceiveAdEventCallback;

      late final IMAAdsManagerDelegate delegate;
      PigeonOverrides.iMAAdsManagerDelegate_new =
          ({
            required void Function(
              IMAAdsManagerDelegate,
              IMAAdsManager,
              IMAAdEvent,
            )
            didReceiveAdEvent,
            required void Function(
              IMAAdsManagerDelegate,
              IMAAdsManager,
              IMAAdError,
            )
            didReceiveAdError,
            required void Function(IMAAdsManagerDelegate, IMAAdsManager)
            didRequestContentPause,
            required void Function(IMAAdsManagerDelegate, IMAAdsManager)
            didRequestContentResume,
          }) {
            didReceiveAdEventCallback = didReceiveAdEvent;
            delegate = IMAAdsManagerDelegate.pigeon_detached(
              didReceiveAdEvent: didReceiveAdEvent,
              didReceiveAdError: didReceiveAdError,
              didRequestContentPause: didRequestContentPause,
              didRequestContentResume: didRequestContentResume,
            );
            return delegate;
          };

      final adsManagerDelegate = IOSAdsManagerDelegate(
        IOSAdsManagerDelegateCreationParams(
          onAdEvent: expectAsync1((PlatformAdEvent event) {
            expect(event.ad!.duration, isNull);
            expect(event.ad!.skipTimeOffset, isNull);
            expect(event.ad!.adPodInfo.maxDuration, isNull);
          }),
        ),
      );

      // Calls the field because the value is instantiated lazily.
      // ignore: unnecessary_statements
      adsManagerDelegate.delegate;

      didReceiveAdEventCallback(
        delegate,
        IMAAdsManager.pigeon_detached(adCuePoints: const <double>[]),
        IMAAdEvent.pigeon_detached(
          type: AdEventType.allAdsCompleted,
          typeString: 'typeString',
          ad: createTestAd(
            duration: -1,
            skipTimeOffset: -1,
            adPodInfo: IMAAdPodInfo.pigeon_detached(
              adPosition: 0,
              maxDuration: -1,
              podIndex: 0,
              timeOffset: 0,
              totalAds: 0,
              isBumper: true,
            ),
          ),
        ),
      );
    });
  });
}

IMAAd createTestAd({
  List<IMAUniversalAdID>? universalAdIds,
  List<IMACompanionAd>? companionAds,
  IMAAdPodInfo? adPodInfo,
  double? duration,
  double? skipTimeOffset,
}) {
  return IMAAd.pigeon_detached(
    adId: '',
    adPodInfo:
        adPodInfo ??
        IMAAdPodInfo.pigeon_detached(
          adPosition: 0,
          maxDuration: 0,
          podIndex: 0,
          timeOffset: 0,
          totalAds: 0,
          isBumper: false,
        ),
    adSystem: '',
    adTitle: '',
    adDescription: '',
    contentType: '',
    wrapperCreativeIDs: const <String>[],
    wrapperAdIDs: const <String>[],
    wrapperSystems: const <String>[],
    advertiserName: '',
    companionAds: companionAds ?? const <IMACompanionAd>[],
    creativeAdID: '',
    creativeID: '',
    dealID: '',
    duration: duration ?? 0,
    height: 0,
    skipTimeOffset: skipTimeOffset ?? 0,
    traffickingParameters: '',
    uiElements: const <UIElementType>[],
    universalAdIDs: universalAdIds ?? const <IMAUniversalAdID>[],
    vastMediaBitrate: 0,
    vastMediaHeight: 0,
    vastMediaWidth: 0,
    width: 0,
    isLinear: true,
    isSkippable: true,
  );
}
