// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.ViewGroup
import com.google.ads.interactivemedia.v3.api.BaseDisplayContainer
import com.google.ads.interactivemedia.v3.api.FriendlyObstruction
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class BaseDisplayContainerProxyApiTest {
  @Test
  fun getAdContainer() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseDisplayContainer()

    val instance = mock<BaseDisplayContainer>()
    val value = mock<ViewGroup>()
    whenever(instance.adContainer).thenReturn(value)

    assertEquals(value, api.getAdContainer(instance ))
  }

  @Test
  fun getCompanionSlots() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseDisplayContainer()

    val instance = mock<BaseDisplayContainer>()
    val value = listOf(mock<CompanionAdSlot>())
    whenever(instance.companionSlots).thenReturn(value)

    assertEquals(value, api.getCompanionSlots(instance ))
  }

  @Test
  fun registerFriendlyObstruction() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseDisplayContainer()

    val instance = mock<BaseDisplayContainer>()
    val friendlyObstruction = mock<FriendlyObstruction>()
    api.registerFriendlyObstruction(instance, friendlyObstruction)

    verify(instance).registerFriendlyObstruction(friendlyObstruction)
  }

  @Test
  fun setCompanionSlots() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseDisplayContainer()

    val instance = mock<BaseDisplayContainer>()
    val companionSlots = listOf(mock<CompanionAdSlot>())
    api.setCompanionSlots(instance, companionSlots)

    verify(instance).setCompanionSlots(companionSlots)
  }

  @Test
  fun unregisterAllFriendlyObstructions() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseDisplayContainer()

    val instance = mock<BaseDisplayContainer>()
    api.unregisterAllFriendlyObstructions(instance )

    verify(instance).unregisterAllFriendlyObstructions()
  }
}
