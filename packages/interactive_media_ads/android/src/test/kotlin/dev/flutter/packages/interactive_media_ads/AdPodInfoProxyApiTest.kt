// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdPodInfo
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.Mockito
import org.mockito.kotlin.whenever

class AdPodInfoProxyApiTest {
  @Test
  fun adPosition() {
    val api = TestProxyApiRegistrar().getPigeonApiAdPodInfo()

    val instance = Mockito.mock<AdPodInfo>()
    whenever(instance.adPosition).thenReturn(0)

    assertEquals(0, api.adPosition(instance))
  }

  @Test
  fun maxDuration() {
    val api = TestProxyApiRegistrar().getPigeonApiAdPodInfo()

    val instance = Mockito.mock<AdPodInfo>()
    whenever(instance.maxDuration).thenReturn(0.0)

    assertEquals(0.0, api.maxDuration(instance))
  }

  @Test
  fun podIndex() {
    val api = TestProxyApiRegistrar().getPigeonApiAdPodInfo()

    val instance = Mockito.mock<AdPodInfo>()
    whenever(instance.podIndex).thenReturn(0)

    assertEquals(0, api.podIndex(instance))
  }

  @Test
  fun timeOffset() {
    val api = TestProxyApiRegistrar().getPigeonApiAdPodInfo()

    val instance = Mockito.mock<AdPodInfo>()
    whenever(instance.timeOffset).thenReturn(0.0)

    assertEquals(0.0, api.timeOffset(instance))
  }

  @Test
  fun totalAds() {
    val api = TestProxyApiRegistrar().getPigeonApiAdPodInfo()

    val instance = Mockito.mock<AdPodInfo>()
    whenever(instance.totalAds).thenReturn(0)

    assertEquals(0, api.totalAds(instance))
  }

  @Test
  fun isBumper() {
    val api = TestProxyApiRegistrar().getPigeonApiAdPodInfo()

    val instance = Mockito.mock<AdPodInfo>()
    whenever(instance.isBumper).thenReturn(true)

    assertEquals(true, api.isBumper(instance))
  }
}
