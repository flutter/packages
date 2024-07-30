// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.player.ContentProgressProvider

/**
 * ProxyApi implementation for [AdsRequest].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdsRequestProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdsRequest(pigeonRegistrar) {
  companion object {
    /**
     * The current version of the `interactive_media_ads` plugin.
     *
     * This must match the version in pubspec.yaml.
     */
    const val pluginVersion = "0.1.0+1"
  }

  override fun setAdTagUrl(pigeon_instance: AdsRequest, adTagUrl: String) {
    pigeon_instance.adTagUrl = "$adTagUrl&request_agent=Flutter-IMA-$pluginVersion"
  }

  override fun setContentProgressProvider(
      pigeon_instance: AdsRequest,
      provider: ContentProgressProvider
  ) {
    pigeon_instance.contentProgressProvider = provider
  }
}
