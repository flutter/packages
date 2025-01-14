// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.ViewGroup
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot.ClickListener

/**
 * ProxyApi implementation for [CompanionAdSlot].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class CompanionAdSlotProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiCompanionAdSlot(pigeonRegistrar) {
  override fun addClickListener(pigeon_instance: CompanionAdSlot, clickListener: ClickListener) {
    return pigeon_instance.addClickListener(clickListener)
  }

  override fun getContainer(pigeon_instance: CompanionAdSlot): ViewGroup {
    return pigeon_instance.container
  }

  override fun getHeight(pigeon_instance: CompanionAdSlot): Long {
    return pigeon_instance.height.toLong()
  }

  override fun getWidth(pigeon_instance: CompanionAdSlot): Long {
    return pigeon_instance.width.toLong()
  }

  override fun isFilled(pigeon_instance: CompanionAdSlot): Boolean {
    return pigeon_instance.isFilled
  }

  override fun removeClickListener(pigeon_instance: CompanionAdSlot, clickListener: ClickListener) {
    pigeon_instance.removeClickListener(clickListener)
  }

  override fun setContainer(pigeon_instance: CompanionAdSlot, container: ViewGroup) {
    pigeon_instance.container = container
  }

  override fun setSize(pigeon_instance: CompanionAdSlot, width: Long, height: Long) {
    pigeon_instance.setSize(width.toInt(), height.toInt())
  }
}
