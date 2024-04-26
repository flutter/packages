// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/android/interactive_media_ads.g.dart',
    dartOptions: DartOptions(copyrightHeader: <String>[
      'Copyright 2013 The Flutter Authors. All rights reserved.',
      'Use of this source code is governed by a BSD-style license that can be',
      'found in the LICENSE file.',
    ]),
    kotlinOut:
        'android/src/main/kotlin/dev/flutter/packages/interactive_media_ads/GeneratedInteractiveMediaAdsLibrary.kt',
    kotlinOptions: KotlinOptions(
      package: 'dev.flutter.packages.interactive_media_ads',
    ),
  ),
)

/// A base class for more specialized container interfaces.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/BaseDisplayContainer.html.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName:
        'com.google.ads.interactivemedia.v3.api.BaseDisplayContainer',
  ),
)
abstract class BaseDisplayContainer {}

/// A container in which to display the ads.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdDisplayContainer.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdDisplayContainer',
  ),
)
abstract class AdDisplayContainer implements BaseDisplayContainer {}

/// An object which allows publishers to request ads from ad servers or a
/// dynamic ad insertion stream.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsLoader.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdsLoader',
  ),
)
abstract class AdsLoader {}

/// An object containing the data used to request ads from the server.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsRequest.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdsRequest',
  ),
)
abstract class AdsRequest {}

/// An object which handles playing ads after they've been received from the
/// server.
///
/// See https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/api/reference/com/google/ads/interactivemedia/v3/api/AdsManager.
@ProxyApi(
  kotlinOptions: KotlinProxyApiOptions(
    fullClassName: 'com.google.ads.interactivemedia.v3.api.AdsManager',
  ),
)
abstract class AdsManager {}
