// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsManager

/**
 * ProxyApi implementation for [AdsManager].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdsManagerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdsManager(pigeonRegistrar) {
  override fun discardAdBreak(pigeon_instance: AdsManager) {
    pigeon_instance.discardAdBreak()
  }

  override fun pause(pigeon_instance: AdsManager) {
    pigeon_instance.pause()
  }

  override fun start(pigeon_instance: AdsManager) {
    pigeon_instance.start()
  }

  override fun getAdCuePoints(pigeon_instance: AdsManager): List<Double> {
    return pigeon_instance.adCuePoints.map { it.toDouble() }
  }

  override fun resume(pigeon_instance: AdsManager) {
    pigeon_instance.resume()
  }

  override fun skip(pigeon_instance: AdsManager) {
    pigeon_instance.skip()
  }
}
