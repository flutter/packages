// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.CompanionAdSlot
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot.ClickListener
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

class CompanionAdSlotProxyApiTest {
  @Test
  fun addClickListener() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAdSlot()

    val instance = mock<CompanionAdSlot>()
    val clickListener = mock<ClickListener>()
    api.addClickListener(instance, clickListener)

    verify(instance).addClickListener(clickListener)
  }

  @Test
  fun removeClickListener() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAdSlot()

    val instance = mock<CompanionAdSlot>()
    val clickListener = mock<ClickListener>()
    api.removeClickListener(instance, clickListener)

    verify(instance).removeClickListener(clickListener)
  }
}
