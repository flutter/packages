// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.ViewGroup
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot.ClickListener
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

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
  fun getContainer() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAdSlot()

    val instance = mock<CompanionAdSlot>()
    val value = mock<ViewGroup>()
    whenever(instance.container).thenReturn(value)

    assertEquals(value, api.getContainer(instance))
  }

  @Test
  fun getHeight() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAdSlot()

    val instance = mock<CompanionAdSlot>()
    val value = 0
    whenever(instance.height).thenReturn(value)
    assertEquals(value.toLong(), api.getHeight(instance))
  }

  @Test
  fun getWidth() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAdSlot()

    val instance = mock<CompanionAdSlot>()
    val value = 0
    whenever(instance.width).thenReturn(value)

    assertEquals(value.toLong(), api.getWidth(instance))
  }

  @Test
  fun isFilled() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAdSlot()

    val instance = mock<CompanionAdSlot>()
    val value = true
    whenever(instance.isFilled).thenReturn(value)

    assertEquals(value, api.isFilled(instance))
  }

  @Test
  fun removeClickListener() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAdSlot()

    val instance = mock<CompanionAdSlot>()
    val clickListener = mock<ClickListener>()
    api.removeClickListener(instance, clickListener)

    verify(instance).removeClickListener(clickListener)
  }

  @Test
  fun setContainer() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAdSlot()

    val instance = mock<CompanionAdSlot>()
    val container = mock<ViewGroup>()
    api.setContainer(instance, container)

    verify(instance).container = container
  }

  @Test
  fun setSize() {
    val api = TestProxyApiRegistrar().getPigeonApiCompanionAdSlot()

    val instance = mock<CompanionAdSlot>()
    val width = 0L
    val height = 1L
    api.setSize(instance, width, height)

    verify(instance).setSize(width.toInt(), height.toInt())
  }
}
