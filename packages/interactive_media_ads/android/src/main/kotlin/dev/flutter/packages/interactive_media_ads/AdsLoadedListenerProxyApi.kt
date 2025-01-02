// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsLoader
import com.google.ads.interactivemedia.v3.api.AdsManagerLoadedEvent

/**
 * ProxyApi implementation for [AdsLoader.AdsLoadedListener].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdsLoadedListenerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdsLoadedListener(pigeonRegistrar) {
  internal class AdsLoadedListenerImpl(val api: AdsLoadedListenerProxyApi) :
      AdsLoader.AdsLoadedListener {
    override fun onAdsManagerLoaded(event: AdsManagerLoadedEvent) {
      api.pigeonRegistrar.runOnMainThread { api.onAdsManagerLoaded(this, event) {} }
    }
  }

  override fun pigeon_defaultConstructor(): AdsLoader.AdsLoadedListener {
    return AdsLoadedListenerImpl(this)
  }
}
