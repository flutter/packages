// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:interactive_media_ads/src/ios/interactive_media_ads.g.dart'
    as ima;
import 'package:interactive_media_ads/src/ios/interactive_media_ads_proxy.dart';
import 'package:interactive_media_ads/src/ios/ios_ads_manager_delegate.dart';
import 'package:interactive_media_ads/src/platform_interface/platform_interface.dart';

void main() {
  group('IOSAdsManagerDelegate', () {
    test('didReceiveAdEvent calls onAdEvent', () {
      final ima.PigeonInstanceManager instanceManager =
          ima.PigeonInstanceManager(onWeakReferenceRemoved: (_) {});

      late final void Function(
        ima.IMAAdsManagerDelegate,
        ima.IMAAdsManager,
        ima.IMAAdEvent,
      ) didReceiveAdEventCallback;

      late final ima.IMAAdsManagerDelegate delegate;
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newIMAAdsManagerDelegate: ({
          required void Function(
            ima.IMAAdsManagerDelegate,
            ima.IMAAdsManager,
            ima.IMAAdEvent,
          ) didReceiveAdEvent,
          required void Function(
            ima.IMAAdsManagerDelegate,
            ima.IMAAdsManager,
            ima.IMAAdError,
          ) didReceiveAdError,
          required void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
              didRequestContentPause,
          required void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
              didRequestContentResume,
        }) {
          didReceiveAdEventCallback = didReceiveAdEvent;
          delegate = ima.IMAAdsManagerDelegate.pigeon_detached(
            didReceiveAdEvent: didReceiveAdEvent,
            didReceiveAdError: didReceiveAdError,
            didRequestContentPause: didRequestContentPause,
            didRequestContentResume: didRequestContentResume,
            pigeon_instanceManager: instanceManager,
          );
          return delegate;
        },
      );

      final IOSAdsManagerDelegate adsManagerDelegate = IOSAdsManagerDelegate(
        IOSAdsManagerDelegateCreationParams(
          onAdEvent: expectAsync1((AdEvent event) {
            expect(event.type, AdEventType.allAdsCompleted);
            expect(event.adData, <String, String>{'hello': 'world'});
          }),
          proxy: imaProxy,
        ),
      );

      // Calls the field because the value is instantiated lazily.
      // ignore: unnecessary_statements
      adsManagerDelegate.delegate;

      didReceiveAdEventCallback(
        delegate,
        ima.IMAAdsManager.pigeon_detached(
          pigeon_instanceManager: instanceManager,
        ),
        ima.IMAAdEvent.pigeon_detached(
          type: ima.AdEventType.allAdsCompleted,
          typeString: 'typeString',
          adData: const <String, String>{'hello': 'world'},
          pigeon_instanceManager: instanceManager,
        ),
      );
    });

    test('didRequestContentPause calls onAdEvent', () {
      final ima.PigeonInstanceManager instanceManager =
          ima.PigeonInstanceManager(onWeakReferenceRemoved: (_) {});

      late final void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
          didRequestContentPauseCallback;

      late final ima.IMAAdsManagerDelegate delegate;
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newIMAAdsManagerDelegate: ({
          required void Function(
            ima.IMAAdsManagerDelegate,
            ima.IMAAdsManager,
            ima.IMAAdEvent,
          ) didReceiveAdEvent,
          required void Function(
            ima.IMAAdsManagerDelegate,
            ima.IMAAdsManager,
            ima.IMAAdError,
          ) didReceiveAdError,
          required void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
              didRequestContentPause,
          required void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
              didRequestContentResume,
        }) {
          didRequestContentPauseCallback = didRequestContentPause;
          delegate = ima.IMAAdsManagerDelegate.pigeon_detached(
            didReceiveAdEvent: didReceiveAdEvent,
            didReceiveAdError: didReceiveAdError,
            didRequestContentPause: didRequestContentPause,
            didRequestContentResume: didRequestContentResume,
            pigeon_instanceManager: instanceManager,
          );
          return delegate;
        },
      );

      final IOSAdsManagerDelegate adsManagerDelegate = IOSAdsManagerDelegate(
        IOSAdsManagerDelegateCreationParams(
          onAdEvent: expectAsync1((AdEvent event) {
            expect(event.type, AdEventType.contentPauseRequested);
          }),
          proxy: imaProxy,
        ),
      );

      // Calls the field because the value is instantiated lazily.
      // ignore: unnecessary_statements
      adsManagerDelegate.delegate;

      didRequestContentPauseCallback(
        delegate,
        ima.IMAAdsManager.pigeon_detached(
          pigeon_instanceManager: instanceManager,
        ),
      );
    });

    test('didRequestContentResume calls onAdEvent', () {
      final ima.PigeonInstanceManager instanceManager =
          ima.PigeonInstanceManager(onWeakReferenceRemoved: (_) {});

      late final void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
          didRequestContentResumeCallback;

      late final ima.IMAAdsManagerDelegate delegate;
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newIMAAdsManagerDelegate: ({
          required void Function(
            ima.IMAAdsManagerDelegate,
            ima.IMAAdsManager,
            ima.IMAAdEvent,
          ) didReceiveAdEvent,
          required void Function(
            ima.IMAAdsManagerDelegate,
            ima.IMAAdsManager,
            ima.IMAAdError,
          ) didReceiveAdError,
          required void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
              didRequestContentPause,
          required void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
              didRequestContentResume,
        }) {
          didRequestContentResumeCallback = didRequestContentResume;
          delegate = ima.IMAAdsManagerDelegate.pigeon_detached(
            didReceiveAdEvent: didReceiveAdEvent,
            didReceiveAdError: didReceiveAdError,
            didRequestContentPause: didRequestContentPause,
            didRequestContentResume: didRequestContentResume,
            pigeon_instanceManager: instanceManager,
          );
          return delegate;
        },
      );

      final IOSAdsManagerDelegate adsManagerDelegate = IOSAdsManagerDelegate(
        IOSAdsManagerDelegateCreationParams(
          onAdEvent: expectAsync1((AdEvent event) {
            expect(event.type, AdEventType.contentResumeRequested);
          }),
          proxy: imaProxy,
        ),
      );

      // Calls the field because the value is instantiated lazily.
      // ignore: unnecessary_statements
      adsManagerDelegate.delegate;

      didRequestContentResumeCallback(
        delegate,
        ima.IMAAdsManager.pigeon_detached(
          pigeon_instanceManager: instanceManager,
        ),
      );
    });

    test('didReceiveAdError calls onAdErrorEvent', () {
      final ima.PigeonInstanceManager instanceManager =
          ima.PigeonInstanceManager(onWeakReferenceRemoved: (_) {});

      late final void Function(
        ima.IMAAdsManagerDelegate,
        ima.IMAAdsManager,
        ima.IMAAdError,
      ) didReceiveAdErrorCallback;

      late final ima.IMAAdsManagerDelegate delegate;
      final InteractiveMediaAdsProxy imaProxy = InteractiveMediaAdsProxy(
        newIMAAdsManagerDelegate: ({
          required void Function(
            ima.IMAAdsManagerDelegate,
            ima.IMAAdsManager,
            ima.IMAAdEvent,
          ) didReceiveAdEvent,
          required void Function(
            ima.IMAAdsManagerDelegate,
            ima.IMAAdsManager,
            ima.IMAAdError,
          ) didReceiveAdError,
          required void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
              didRequestContentPause,
          required void Function(ima.IMAAdsManagerDelegate, ima.IMAAdsManager)
              didRequestContentResume,
        }) {
          didReceiveAdErrorCallback = didReceiveAdError;
          delegate = ima.IMAAdsManagerDelegate.pigeon_detached(
            didReceiveAdEvent: didReceiveAdEvent,
            didReceiveAdError: didReceiveAdError,
            didRequestContentPause: didRequestContentPause,
            didRequestContentResume: didRequestContentResume,
            pigeon_instanceManager: instanceManager,
          );
          return delegate;
        },
      );

      final IOSAdsManagerDelegate adsManagerDelegate = IOSAdsManagerDelegate(
        IOSAdsManagerDelegateCreationParams(
          onAdErrorEvent: expectAsync1((AdErrorEvent event) {
            expect(event.error.type, AdErrorType.loading);
            expect(event.error.code, AdErrorCode.apiError);
            expect(event.error.message, 'error message');
          }),
          proxy: imaProxy,
        ),
      );

      // Calls the field because the value is instantiated lazily.
      // ignore: unnecessary_statements
      adsManagerDelegate.delegate;

      didReceiveAdErrorCallback(
        delegate,
        ima.IMAAdsManager.pigeon_detached(
          pigeon_instanceManager: instanceManager,
        ),
        ima.IMAAdError.pigeon_detached(
          type: ima.AdErrorType.loadingFailed,
          code: ima.AdErrorCode.apiError,
          message: 'error message',
          pigeon_instanceManager: instanceManager,
        ),
      );
    });
  });
}
