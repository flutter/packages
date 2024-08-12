// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdProgressInfo
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class AdProgressInfoProxyApiTest {
  @Test
  fun adBreakDuration() {
    val api = TestProxyApiRegistrar().getPigeonApiAdProgressInfo()

    val instance = mock<AdProgressInfo>()
    val value = 1.0
    whenever(instance.adBreakDuration).thenReturn(value)

    assertEquals(value, api.adBreakDuration(instance))
  }

  @Test
  fun adPeriodDuration() {
    val api = TestProxyApiRegistrar().getPigeonApiAdProgressInfo()

    val instance = mock<AdProgressInfo>()
    val value = 1.0
    whenever(instance.adPeriodDuration).thenReturn(value)

    assertEquals(value, api.adPeriodDuration(instance))
  }

  @Test
  fun adPosition() {
    val api = TestProxyApiRegistrar().getPigeonApiAdProgressInfo()

    val instance = mock<AdProgressInfo>()
    val value = 0
    whenever(instance.adPosition).thenReturn(value)

    assertEquals(value.toLong(), api.adPosition(instance))
  }

  @Test
  fun currentTime() {
    val api = TestProxyApiRegistrar().getPigeonApiAdProgressInfo()

    val instance = mock<AdProgressInfo>()
    val value = 1.0
    whenever(instance.currentTime).thenReturn(value)

    assertEquals(value, api.currentTime(instance))
  }

  @Test
  fun duration() {
    val api = TestProxyApiRegistrar().getPigeonApiAdProgressInfo()

    val instance = mock<AdProgressInfo>()
    val value = 1.0
    whenever(instance.duration).thenReturn(value)

    assertEquals(value, api.duration(instance))
  }

  @Test
  fun totalAds() {
    val api = TestProxyApiRegistrar().getPigeonApiAdProgressInfo()

    val instance = mock<AdProgressInfo>()
    val value = 0
    whenever(instance.totalAds).thenReturn(value)

    assertEquals(value.toLong(), api.totalAds(instance))
  }
}
