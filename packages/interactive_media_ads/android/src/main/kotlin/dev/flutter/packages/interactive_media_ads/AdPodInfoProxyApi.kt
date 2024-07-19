// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdPodInfo

/**
 * ProxyApi implementation for [AdPodInfo].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdPodInfoProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdPodInfo(pigeonRegistrar) {
  override fun adPosition(pigeon_instance: AdPodInfo): Long {
    return pigeon_instance.adPosition.toLong()
  }

  override fun maxDuration(pigeon_instance: AdPodInfo): Double {
    return pigeon_instance.maxDuration
  }

  override fun podIndex(pigeon_instance: AdPodInfo): Long {
    return pigeon_instance.podIndex.toLong()
  }

  override fun timeOffset(pigeon_instance: AdPodInfo): Double {
    return pigeon_instance.timeOffset
  }

  override fun totalAds(pigeon_instance: AdPodInfo): Long {
    return pigeon_instance.totalAds.toLong()
  }

  override fun isBumper(pigeon_instance: AdPodInfo): Boolean {
    return pigeon_instance.isBumper
  }
}
