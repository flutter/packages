// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.Ad
import com.google.ads.interactivemedia.v3.api.AdPodInfo
import com.google.ads.interactivemedia.v3.api.CompanionAd
import com.google.ads.interactivemedia.v3.api.UiElement
import com.google.ads.interactivemedia.v3.api.UniversalAdId
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class AdProxyApiTest {
  @Test
  fun adId() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = "myString"
    whenever(instance.adId).thenReturn(value)

    assertEquals(value, api.adId(instance))
  }

  @Test
  fun adPodInfo() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = mock<AdPodInfo>()
    whenever(instance.adPodInfo).thenReturn(value)

    assertEquals(value, api.adPodInfo(instance))
  }

  @Test
  fun adSystem() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = "myString"
    whenever(instance.adSystem).thenReturn(value)

    assertEquals(value, api.adSystem(instance))
  }

  @Test
  fun adWrapperCreativeIds() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = listOf("myString")
    whenever(instance.adWrapperCreativeIds).thenReturn(arrayOf("myString"))

    assertEquals(value, api.adWrapperCreativeIds(instance))
  }

  @Test
  fun adWrapperIds() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = listOf("myString")
    whenever(instance.adWrapperIds).thenReturn(arrayOf("myString"))

    assertEquals(value, api.adWrapperIds(instance))
  }

  @Test
  fun adWrapperSystems() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = listOf("myString")
    whenever(instance.adWrapperSystems).thenReturn(arrayOf("myString"))

    assertEquals(value, api.adWrapperSystems(instance))
  }

  @Test
  fun advertiserName() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = "myString"
    whenever(instance.advertiserName).thenReturn(value)

    assertEquals(value, api.advertiserName(instance))
  }

  @Test
  fun companionAds() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = listOf(mock<CompanionAd>())
    whenever(instance.companionAds).thenReturn(value)

    assertEquals(value, api.companionAds(instance))
  }

  @Test
  fun contentType() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = "myString"
    whenever(instance.contentType).thenReturn(value)

    assertEquals(value, api.contentType(instance))
  }

  @Test
  fun creativeAdId() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = "myString"
    whenever(instance.creativeAdId).thenReturn(value)

    assertEquals(value, api.creativeAdId(instance))
  }

  @Test
  fun creativeId() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = "myString"
    whenever(instance.creativeId).thenReturn(value)

    assertEquals(value, api.creativeId(instance))
  }

  @Test
  fun dealId() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = "myString"
    whenever(instance.dealId).thenReturn(value)

    assertEquals(value, api.dealId(instance))
  }

  @Test
  fun description() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = "myString"
    whenever(instance.description).thenReturn(value)

    assertEquals(value, api.description(instance))
  }

  @Test
  fun duration() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = 1.0
    whenever(instance.duration).thenReturn(value)

    assertEquals(value, api.duration(instance))
  }

  @Test
  fun height() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = 0
    whenever(instance.height).thenReturn(value)

    assertEquals(value.toLong(), api.height(instance))
  }

  @Test
  fun skipTimeOffset() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = 1.0
    whenever(instance.skipTimeOffset).thenReturn(value)

    assertEquals(value, api.skipTimeOffset(instance))
  }

  @Test
  fun surveyUrl() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = "myString"
    whenever(instance.surveyUrl).thenReturn(value)

    assertEquals(value, api.surveyUrl(instance))
  }

  @Test
  fun title() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = "myString"
    whenever(instance.title).thenReturn(value)

    assertEquals(value, api.title(instance))
  }

  @Test
  fun traffickingParameters() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = "myString"
    whenever(instance.traffickingParameters).thenReturn(value)

    assertEquals(value, api.traffickingParameters(instance))
  }

  @Test
  fun uiElements() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = listOf(UiElement.AD_ATTRIBUTION)
    whenever(instance.uiElements).thenReturn(value.toSet())

    assertEquals(
        listOf(dev.flutter.packages.interactive_media_ads.UiElement.AD_ATTRIBUTION),
        api.uiElements(instance))
  }

  @Test
  fun universalAdIds() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = listOf(mock<UniversalAdId>())
    whenever(instance.universalAdIds).thenReturn(value.toTypedArray())

    assertEquals(value, api.universalAdIds(instance))
  }

  @Test
  fun vastMediaBitrate() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = 0
    whenever(instance.vastMediaBitrate).thenReturn(value)

    assertEquals(value.toLong(), api.vastMediaBitrate(instance))
  }

  @Test
  fun vastMediaHeight() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = 0
    whenever(instance.vastMediaHeight).thenReturn(value)

    assertEquals(value.toLong(), api.vastMediaHeight(instance))
  }

  @Test
  fun vastMediaWidth() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = 0
    whenever(instance.vastMediaWidth).thenReturn(value)

    assertEquals(value.toLong(), api.vastMediaWidth(instance))
  }

  @Test
  fun width() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = 0
    whenever(instance.width).thenReturn(value)

    assertEquals(value.toLong(), api.width(instance))
  }

  @Test
  fun isLinear() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = true
    whenever(instance.isLinear).thenReturn(value)

    assertEquals(value, api.isLinear(instance))
  }

  @Test
  fun isSkippable() {
    val api = TestProxyApiRegistrar().getPigeonApiAd()

    val instance = mock<Ad>()
    val value = true
    whenever(instance.isSkippable).thenReturn(value)

    assertEquals(value, api.isSkippable(instance))
  }
}
