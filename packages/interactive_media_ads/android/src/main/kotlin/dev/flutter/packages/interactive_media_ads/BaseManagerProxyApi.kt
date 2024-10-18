// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.Ad
import com.google.ads.interactivemedia.v3.api.AdErrorEvent
import com.google.ads.interactivemedia.v3.api.AdEvent
import com.google.ads.interactivemedia.v3.api.AdProgressInfo
import com.google.ads.interactivemedia.v3.api.AdsRenderingSettings
import com.google.ads.interactivemedia.v3.api.BaseManager

/**
 * ProxyApi implementation for [BaseManager].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class BaseManagerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiBaseManager(pigeonRegistrar) {
  override fun addAdErrorListener(
      pigeon_instance: BaseManager,
      errorListener: AdErrorEvent.AdErrorListener
  ) {
    pigeon_instance.addAdErrorListener(errorListener)
  }

  override fun addAdEventListener(
      pigeon_instance: BaseManager,
      adEventListener: AdEvent.AdEventListener
  ) {
    pigeon_instance.addAdEventListener(adEventListener)
  }

  override fun destroy(pigeon_instance: BaseManager) {
    pigeon_instance.destroy()
  }

  override fun init(pigeon_instance: BaseManager, settings: AdsRenderingSettings?) {
    if (settings == null) {
      pigeon_instance.init()
    } else {
      pigeon_instance.init(settings)
    }
  }

  override fun focus(pigeon_instance: BaseManager) {
    pigeon_instance.focus()
  }

  override fun getAdProgressInfo(pigeon_instance: BaseManager): AdProgressInfo? {
    return pigeon_instance.adProgressInfo
  }

  override fun getCurrentAd(pigeon_instance: BaseManager): Ad? {
    return pigeon_instance.currentAd
  }

  override fun removeAdErrorListener(
      pigeon_instance: BaseManager,
      errorListener: AdErrorEvent.AdErrorListener
  ) {
    pigeon_instance.removeAdErrorListener(errorListener)
  }

  override fun removeAdEventListener(
      pigeon_instance: BaseManager,
      adEventListener: AdEvent.AdEventListener
  ) {
    pigeon_instance.removeAdEventListener(adEventListener)
  }
}
