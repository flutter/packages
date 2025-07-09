// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdDisplayContainer
import com.google.ads.interactivemedia.v3.api.AdsLoader
import com.google.ads.interactivemedia.v3.api.AdsRenderingSettings
import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot
import com.google.ads.interactivemedia.v3.api.ImaSdkFactory
import com.google.ads.interactivemedia.v3.api.ImaSdkSettings
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class ImaSdkFactoryProxyApiTest {
  @Test
  fun createImaSdkSettings() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val mockSettings = mock<ImaSdkSettings>()
    whenever(instance.createImaSdkSettings()).thenReturn(mockSettings)

    assertEquals(mockSettings, api.createImaSdkSettings(instance))
  }

  @Test
  fun createAdsLoader() {
    val registrar = TestProxyApiRegistrar()
    val api = registrar.getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val mockAdsLoader = mock<AdsLoader>()
    val mockSettings = mock<ImaSdkSettings>()
    val mockContainer = mock<AdDisplayContainer>()
    whenever(instance.createAdsLoader(registrar.context, mockSettings, mockContainer))
        .thenReturn(mockAdsLoader)

    assertEquals(mockAdsLoader, api.createAdsLoader(instance, mockSettings, mockContainer))
  }

  @Test
  fun createCompanionAdSlot() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val mockAdSlot = mock<CompanionAdSlot>()
    whenever(instance.createCompanionAdSlot()).thenReturn(mockAdSlot)

    assertEquals(mockAdSlot, api.createCompanionAdSlot(instance))
  }

  @Test
  fun createAdsRequest() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val mockRequest = mock<AdsRequest>()
    whenever(instance.createAdsRequest()).thenReturn(mockRequest)

    assertEquals(mockRequest, api.createAdsRequest(instance))
  }

  @Test
  fun createAdsRenderingSettings() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val mockSettings = mock<AdsRenderingSettings>()
    whenever(instance.createAdsRenderingSettings()).thenReturn(mockSettings)

    assertEquals(mockSettings, api.createAdsRenderingSettings(instance))
  }
}
