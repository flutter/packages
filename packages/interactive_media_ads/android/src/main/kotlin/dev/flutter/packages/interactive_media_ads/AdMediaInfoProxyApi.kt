// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.AdMediaInfo

/**
 * ProxyApi implementation for [AdMediaInfo].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdMediaInfoProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdMediaInfo(pigeonRegistrar) {
  override fun url(pigeon_instance: AdMediaInfo): String {
    return pigeon_instance.url
  }
}
