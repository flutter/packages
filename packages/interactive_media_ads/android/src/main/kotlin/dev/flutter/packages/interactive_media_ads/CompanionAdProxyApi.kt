// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.CompanionAd

/**
 * ProxyApi implementation for [CompanionAd].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class CompanionAdProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiCompanionAd(pigeonRegistrar) {
  override fun apiFramework(pigeon_instance: CompanionAd): String? {
    return pigeon_instance.apiFramework
  }

  override fun height(pigeon_instance: CompanionAd): Long {
    return pigeon_instance.height.toLong()
  }

  override fun resourceValue(pigeon_instance: CompanionAd): String {
    return pigeon_instance.resourceValue
  }

  override fun width(pigeon_instance: CompanionAd): Long {
    return pigeon_instance.width.toLong()
  }
}
