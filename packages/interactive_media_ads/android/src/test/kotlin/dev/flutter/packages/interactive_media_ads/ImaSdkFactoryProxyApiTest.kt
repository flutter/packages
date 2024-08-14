// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.View
import com.google.ads.interactivemedia.v3.api.AdDisplayContainer
import com.google.ads.interactivemedia.v3.api.AdsLoader
import com.google.ads.interactivemedia.v3.api.AdsRenderingSettings
import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot
import com.google.ads.interactivemedia.v3.api.FriendlyObstruction
import com.google.ads.interactivemedia.v3.api.FriendlyObstructionPurpose
import com.google.ads.interactivemedia.v3.api.ImaSdkFactory
import com.google.ads.interactivemedia.v3.api.ImaSdkSettings
import com.google.ads.interactivemedia.v3.api.StreamDisplayContainer
import com.google.ads.interactivemedia.v3.api.StreamRequest
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
  fun createAdsRequest() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val mockRequest = mock<AdsRequest>()
    whenever(instance.createAdsRequest()).thenReturn(mockRequest)

    assertEquals(mockRequest, api.createAdsRequest(instance))
  }

  @Test
  fun createStreamAdsLoader() {
    val registrar = TestProxyApiRegistrar()
    val api = registrar.getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val settings = mock<ImaSdkSettings>()
    val container = mock<StreamDisplayContainer>()
    val value = mock<AdsLoader>()
    whenever(instance.createAdsLoader(registrar.context, settings, container)).thenReturn(value)

    assertEquals(value, api.createStreamAdsLoader(instance, settings, container))
  }

  @Test
  fun createAdsRenderingSettings() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val value = mock<AdsRenderingSettings>()
    whenever(instance.createAdsRenderingSettings()).thenReturn(value)

    assertEquals(value, api.createAdsRenderingSettings(instance))
  }

  @Test
  fun createCompanionAdSlot() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val value = mock<CompanionAdSlot>()
    whenever(instance.createCompanionAdSlot()).thenReturn(value)

    assertEquals(value, api.createCompanionAdSlot(instance))
  }

  @Test
  fun createFriendlyObstruction() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val view = mock<View>()
    val purpose = dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.CLOSE_AD
    val detailedReason = "myString"
    val value = mock<FriendlyObstruction>()
    whenever(
            instance.createFriendlyObstruction(
                view, FriendlyObstructionPurpose.CLOSE_AD, detailedReason))
        .thenReturn(value)

    assertEquals(value, api.createFriendlyObstruction(instance, view, purpose, detailedReason))
  }

  @Test
  fun createLiveStreamRequest() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val assetKey = "myString1"
    val apiKey = "myString2"
    val value = mock<StreamRequest>()
    whenever(instance.createLiveStreamRequest(assetKey, apiKey)).thenReturn(value)

    assertEquals(value, api.createLiveStreamRequest(instance, assetKey, apiKey))
  }

  @Test
  fun createPodStreamRequest() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val networkCode = "myString"
    val customAssetKey = "myString1"
    val apiKey = "myString2"
    val value = mock<StreamRequest>()
    whenever(instance.createPodStreamRequest(networkCode, customAssetKey, apiKey)).thenReturn(value)

    assertEquals(value, api.createPodStreamRequest(instance, networkCode, customAssetKey, apiKey))
  }

  @Test
  fun createPodVodStreamRequest() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val networkCode = "myString"
    val value = mock<StreamRequest>()
    whenever(instance.createPodVodStreamRequest(networkCode)).thenReturn(value)

    assertEquals(value, api.createPodVodStreamRequest(instance, networkCode))
  }

  @Test
  fun createVideoStitcherLiveStreamRequest() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val networkCode = "myString"
    val customAssetKey = "myString1"
    val liveStreamEventId = "myString2"
    val region = "myString3"
    val projectNumber = "myString4"
    val oAuthToken = "myString5"
    val value = mock<StreamRequest>()
    whenever(
            instance.createVideoStitcherLiveStreamRequest(
                networkCode, customAssetKey, liveStreamEventId, region, projectNumber, oAuthToken))
        .thenReturn(value)

    assertEquals(
        value,
        api.createVideoStitcherLiveStreamRequest(
            instance,
            networkCode,
            customAssetKey,
            liveStreamEventId,
            region,
            projectNumber,
            oAuthToken))
  }

  @Test
  fun createContentSourceVideoStitcherVodStreamRequest() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val contentSourceUrl = "myString"
    val networkCode = "myString1"
    val region = "myString2"
    val projectNumber = "myString3"
    val oAuthToken = "myString4"
    val adTagUrl = "myString5"
    val value = mock<StreamRequest>()
    whenever(
            instance.createVideoStitcherVodStreamRequest(
                contentSourceUrl, networkCode, region, projectNumber, oAuthToken, adTagUrl))
        .thenReturn(value)

    assertEquals(
        value,
        api.createContentSourceVideoStitcherVodStreamRequest(
            instance, contentSourceUrl, networkCode, region, projectNumber, oAuthToken, adTagUrl))
  }

  @Test
  fun createVideoStitcherVodStreamRequest() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val networkCode = "myString"
    val region = "myString1"
    val projectNumber = "myString2"
    val oAuthToken = "myString3"
    val vodConfigId = "myString4"
    val value = mock<StreamRequest>()
    whenever(
            instance.createVideoStitcherVodStreamRequest(
                networkCode, region, projectNumber, oAuthToken, vodConfigId))
        .thenReturn(value)

    assertEquals(
        value,
        api.createVideoStitcherVodStreamRequest(
            instance, networkCode, region, projectNumber, oAuthToken, vodConfigId))
  }

  @Test
  fun createVodStreamRequest() {
    val api = TestProxyApiRegistrar().getPigeonApiImaSdkFactory()

    val instance = mock<ImaSdkFactory>()
    val contentSourceId = "myString"
    val videoId = "myString1"
    val apiKey = "myString2"
    val value = mock<StreamRequest>()
    whenever(instance.createVodStreamRequest(contentSourceId, videoId, apiKey)).thenReturn(value)

    assertEquals(value, api.createVodStreamRequest(instance, contentSourceId, videoId, apiKey))
  }
}
