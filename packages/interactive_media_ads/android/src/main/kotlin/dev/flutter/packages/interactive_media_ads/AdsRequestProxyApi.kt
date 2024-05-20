// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.player.ContentProgressProvider

class AdsRequestProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdsRequest(pigeonRegistrar) {
  override fun setAdTagUrl(pigeon_instance: AdsRequest, adTagUrl: String) {
    pigeon_instance.adTagUrl = adTagUrl
  }

  override fun setContentProgressProvider(
      pigeon_instance: AdsRequest,
      provider: ContentProgressProvider
  ) {
    pigeon_instance.contentProgressProvider = provider
  }
}
