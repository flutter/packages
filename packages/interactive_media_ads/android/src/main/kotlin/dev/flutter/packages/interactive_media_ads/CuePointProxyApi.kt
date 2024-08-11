// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.CuePoint

/**
 * ProxyApi implementation for [CuePoint].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class CuePointProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiCuePoint(pigeonRegistrar) {
  override fun endTimeMs(pigeon_instance: CuePoint): Long {
    return pigeon_instance.endTimeMs
  }

  override fun startTimeMs(pigeon_instance: CuePoint): Long {
    return pigeon_instance.startTimeMs
  }

  override fun isPlayed(pigeon_instance: CuePoint): Boolean {
    return pigeon_instance.isPlayed
  }
}
