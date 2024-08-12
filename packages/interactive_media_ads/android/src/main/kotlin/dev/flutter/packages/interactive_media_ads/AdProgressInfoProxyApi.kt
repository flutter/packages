// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdProgressInfo

/**
 * ProxyApi implementation for [AdProgressInfo].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdProgressInfoProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdProgressInfo(pigeonRegistrar) {

  override fun adBreakDuration(pigeon_instance: AdProgressInfo): Double {
    return pigeon_instance.adBreakDuration
  }

  override fun adPeriodDuration(pigeon_instance: AdProgressInfo): Double {
    return pigeon_instance.adPeriodDuration
  }

  override fun adPosition(pigeon_instance: AdProgressInfo): Long {
    return pigeon_instance.adPosition.toLong()
  }

  override fun currentTime(pigeon_instance: AdProgressInfo): Double {
    return pigeon_instance.currentTime
  }

  override fun duration(pigeon_instance: AdProgressInfo): Double {
    return pigeon_instance.duration
  }

  override fun totalAds(pigeon_instance: AdProgressInfo): Long {
    return pigeon_instance.totalAds.toLong()
  }
}
