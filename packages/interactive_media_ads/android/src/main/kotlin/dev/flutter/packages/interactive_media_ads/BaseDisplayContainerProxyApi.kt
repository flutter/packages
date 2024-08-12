// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.ViewGroup
import com.google.ads.interactivemedia.v3.api.BaseDisplayContainer
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot
import com.google.ads.interactivemedia.v3.api.FriendlyObstruction

/**
 * ProxyApi implementation for [BaseDisplayContainer].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class BaseDisplayContainerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiBaseDisplayContainer(pigeonRegistrar) {
  override fun getAdContainer(pigeon_instance: BaseDisplayContainer): ViewGroup? {
    return pigeon_instance.getAdContainer()
  }

  override fun getCompanionSlots(pigeon_instance: BaseDisplayContainer): List<CompanionAdSlot> {
    return pigeon_instance.getCompanionSlots().toList()
  }

  override fun registerFriendlyObstruction(
      pigeon_instance: BaseDisplayContainer,
      friendlyObstruction: FriendlyObstruction
  ) {
    return pigeon_instance.registerFriendlyObstruction(friendlyObstruction)
  }

  override fun setCompanionSlots(
      pigeon_instance: BaseDisplayContainer,
      companionSlots: List<CompanionAdSlot>?
  ) {
    return pigeon_instance.setCompanionSlots(companionSlots)
  }

  override fun unregisterAllFriendlyObstructions(pigeon_instance: BaseDisplayContainer) {
    return pigeon_instance.unregisterAllFriendlyObstructions()
  }
}
