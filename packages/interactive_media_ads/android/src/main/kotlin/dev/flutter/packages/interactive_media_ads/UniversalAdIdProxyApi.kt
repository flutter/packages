// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.UniversalAdId

/**
 * ProxyApi implementation for [UniversalAdId].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class UniversalAdIdProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiUniversalAdId(pigeonRegistrar) {
  override fun adIdRegistry(pigeon_instance: UniversalAdId): String {
    return pigeon_instance.adIdRegistry
  }

  override fun adIdValue(pigeon_instance: UniversalAdId): String {
    return pigeon_instance.adIdValue
  }
}
