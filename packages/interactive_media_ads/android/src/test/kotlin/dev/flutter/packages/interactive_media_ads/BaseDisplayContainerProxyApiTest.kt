// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.BaseDisplayContainer
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

class BaseDisplayContainerProxyApiTest {
  @Test
  fun setCompanionSlots() {
    val api = TestProxyApiRegistrar().getPigeonApiBaseDisplayContainer()

    val instance = mock<BaseDisplayContainer>()
    val companionSlots = listOf(mock<CompanionAdSlot>())
    api.setCompanionSlots(instance, companionSlots)

    verify(instance).setCompanionSlots(companionSlots)
  }
}
