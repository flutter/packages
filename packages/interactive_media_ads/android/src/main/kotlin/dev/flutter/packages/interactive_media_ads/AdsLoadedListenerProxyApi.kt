// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsLoader
import com.google.ads.interactivemedia.v3.api.AdsManagerLoadedEvent

class AdsLoadedListenerProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiAdsLoadedListener(pigeonRegistrar) {
  internal class AdsLoadedListenerImpl(val api: AdsLoadedListenerProxyApi) :
      AdsLoader.AdsLoadedListener {
    override fun onAdsManagerLoaded(event: AdsManagerLoadedEvent) {
      (api.pigeonRegistrar as ProxyApiRegistrar).runOnMainThread {
        api.onAdsManagerLoaded(this, event) {}
      }
    }
  }

  override fun pigeon_defaultConstructor(): AdsLoader.AdsLoadedListener {
    return AdsLoadedListenerImpl(this)
  }
}
