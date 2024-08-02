// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdErrorEvent
import com.google.ads.interactivemedia.v3.api.AdsLoader
import com.google.ads.interactivemedia.v3.api.AdsRequest

/**
 * ProxyApi implementation for [AdsLoader].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdsLoaderProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdsLoader(pigeonRegistrar) {
  override fun addAdErrorListener(
      pigeon_instance: AdsLoader,
      listener: AdErrorEvent.AdErrorListener
  ) {
    pigeon_instance.addAdErrorListener(listener)
  }

  override fun addAdsLoadedListener(
      pigeon_instance: AdsLoader,
      listener: AdsLoader.AdsLoadedListener
  ) {
    pigeon_instance.addAdsLoadedListener(listener)
  }

  override fun requestAds(pigeon_instance: AdsLoader, request: AdsRequest) {
    pigeon_instance.requestAds(request)
  }
}
