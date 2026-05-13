// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.ViewGroup
import com.google.ads.interactivemedia.v3.api.AdSlot
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot

/**
 * ProxyApi implementation for [AdSlot].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdSlotProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdSlot(pigeonRegistrar) {
  override fun getContainer(pigeon_instance: AdSlot): ViewGroup? {
    return pigeon_instance.container
  }

  override fun getHeight(pigeon_instance: AdSlot): Long {
    return pigeon_instance.height.toLong()
  }

  override fun getWidth(pigeon_instance: AdSlot): Long {
    return pigeon_instance.width.toLong()
  }

  override fun isFilled(pigeon_instance: AdSlot): Boolean {
    return pigeon_instance.isFilled
  }

  override fun setContainer(pigeon_instance: AdSlot, container: ViewGroup) {
    pigeon_instance.setContainer(container)
  }

  override fun setSize(pigeon_instance: AdSlot, width: Long, height: Long) {
    pigeon_instance.setSize(width.toInt(), height.toInt())
  }

  override fun setFluidSize(pigeon_instance: AdSlot) {
    pigeon_instance.setSize(CompanionAdSlot.FLUID_SIZE, CompanionAdSlot.FLUID_SIZE)
  }
}
