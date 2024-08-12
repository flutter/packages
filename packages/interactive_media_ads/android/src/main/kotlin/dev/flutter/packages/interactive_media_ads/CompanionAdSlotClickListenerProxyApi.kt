// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.CompanionAdSlot.ClickListener

/**
 * ProxyApi implementation for [ClickListener].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class CompanionAdSlotClickListenerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiCompanionAdSlotClickListener(pigeonRegistrar) {
  internal class ClickListenerImpl(val api: CompanionAdSlotClickListenerProxyApi) : ClickListener {
    override fun onCompanionAdClick() {
      api.pigeonRegistrar.runOnMainThread { api.onCompanionAdClick(this) {} }
    }
  }

  override fun pigeon_defaultConstructor(): ClickListener {
    return ClickListenerImpl(this)
  }
}
