// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.ViewGroup
import com.google.ads.interactivemedia.v3.api.AdSlot
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class AdSlotProxyApiTest {
  @Test
  fun getContainer() {
    val api = TestProxyApiRegistrar().getPigeonApiAdSlot()

    val instance = mock<AdSlot>()
    val value = mock<ViewGroup>()
    whenever(instance.container).thenReturn(value)

    assertEquals(value, api.getContainer(instance))
  }

  @Test
  fun getHeight() {
    val api = TestProxyApiRegistrar().getPigeonApiAdSlot()

    val instance = mock<AdSlot>()
    val value = 0
    whenever(instance.height).thenReturn(value)
    assertEquals(value.toLong(), api.getHeight(instance))
  }

  @Test
  fun getWidth() {
    val api = TestProxyApiRegistrar().getPigeonApiAdSlot()

    val instance = mock<AdSlot>()
    val value = 0
    whenever(instance.width).thenReturn(value)

    assertEquals(value.toLong(), api.getWidth(instance))
  }

  @Test
  fun isFilled() {
    val api = TestProxyApiRegistrar().getPigeonApiAdSlot()

    val instance = mock<AdSlot>()
    val value = true
    whenever(instance.isFilled).thenReturn(value)

    assertEquals(value, api.isFilled(instance))
  }

  @Test
  fun setContainer() {
    val api = TestProxyApiRegistrar().getPigeonApiAdSlot()

    val instance = mock<AdSlot>()
    val container = mock<ViewGroup>()
    api.setContainer(instance, container)

    verify(instance).setContainer(container)
  }

  @Test
  fun setSize() {
    val api = TestProxyApiRegistrar().getPigeonApiAdSlot()

    val instance = mock<AdSlot>()
    val width = 0L
    val height = 1L
    api.setSize(instance, width, height)

    verify(instance).setSize(width.toInt(), height.toInt())
  }

  @Test
  fun setFluidSize() {
    val api = TestProxyApiRegistrar().getPigeonApiAdSlot()

    val instance = mock<AdSlot>()
    api.setFluidSize(instance)

    verify(instance).setSize(CompanionAdSlot.FLUID_SIZE, CompanionAdSlot.FLUID_SIZE)
  }
}
