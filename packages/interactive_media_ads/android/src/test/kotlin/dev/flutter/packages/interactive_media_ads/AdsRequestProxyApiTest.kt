// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.player.ContentProgressProvider
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import kotlin.test.assertEquals

class AdsRequestProxyApiTest {
  @Test
  fun setAdTagUrl() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    api.setAdTagUrl(instance, "adTag?")

    verify(instance).adTagUrl =
        "adTag?&request_agent=Flutter-IMA-${AdsRequestProxyApi.pluginVersion}"
  }

  @Test
  fun setContentProgressProvider() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val mockProvider = mock<ContentProgressProvider>()
    api.setContentProgressProvider(instance, mockProvider)

    verify(instance).contentProgressProvider = mockProvider
  }

  @Test
  fun getAdTagUrl() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val value = "myString"
    whenever(instance.getAdTagUrl()).thenReturn(value)

    assertEquals(value, api.getAdTagUrl(instance ))
  }

  @Test
  fun getContentProgressProvider() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val value = mock<ContentProgressProvider>()
    whenever(instance.getContentProgressProvider()).thenReturn(value)

    assertEquals(value, api.getContentProgressProvider(instance ))
  }

  @Test
  fun setAdWillAutoPlay() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val willAutoPlay = true
    api.setAdWillAutoPlay(instance, willAutoPlay)

    verify(instance).setAdWillAutoPlay(willAutoPlay)
  }

  @Test
  fun setAdWillPlayMuted() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val willPlayMuted = true
    api.setAdWillPlayMuted(instance, willPlayMuted)

    verify(instance).setAdWillPlayMuted(willPlayMuted)
  }

  @Test
  fun setAdsResponse() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val cannedAdResponse = "myString"
    api.setAdsResponse(instance, cannedAdResponse)

    verify(instance).setAdsResponse(cannedAdResponse)
  }

  @Test
  fun setContentDuration() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val duration = 1.0
    api.setContentDuration(instance, duration)

    verify(instance).setContentDuration(duration.toFloat())
  }

  @Test
  fun setContentKeywords() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val keywords = listOf("myString")
    api.setContentKeywords(instance, keywords)

    verify(instance).setContentKeywords(keywords)
  }

  @Test
  fun setContentTitle() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val title = "myString"
    api.setContentTitle(instance, title)

    verify(instance).setContentTitle(title)
  }

  @Test
  fun setContinuousPlayback() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val continuousPlayback = true
    api.setContinuousPlayback(instance, continuousPlayback)

    verify(instance).setContinuousPlayback(continuousPlayback)
  }

  @Test
  fun setLiveStreamPrefetchSeconds() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val prefetchTime = 1.0
    api.setLiveStreamPrefetchSeconds(instance, prefetchTime)

    verify(instance).setLiveStreamPrefetchSeconds(prefetchTime.toFloat())
  }

  @Test
  fun setVastLoadTimeout() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val timeout = 1.0
    api.setVastLoadTimeout(instance, timeout)

    verify(instance).setVastLoadTimeout(timeout.toFloat())
  }
}
