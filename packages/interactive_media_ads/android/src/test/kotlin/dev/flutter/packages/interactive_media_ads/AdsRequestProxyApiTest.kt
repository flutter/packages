// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.player.ContentProgressProvider
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

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
  fun setAdTagUrlDoesNotAddRequestAgentToIncompatibleUrls() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()

    api.setAdTagUrl(instance, "adTag#")
    verify(instance).adTagUrl = "adTag#"

    api.setAdTagUrl(instance, "adTag?#")
    verify(instance).adTagUrl = "adTag?#"
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
    val willPlayMuted = false
    api.setAdWillPlayMuted(instance, willPlayMuted)

    verify(instance).setAdWillPlayMuted(willPlayMuted)
  }

  @Test
  fun setAdsResponse() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val cannedAdResponse = "response"
    api.setAdsResponse(instance, cannedAdResponse)

    verify(instance).adsResponse = cannedAdResponse
  }

  @Test
  fun setContentDuration() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val duration = 3.0
    api.setContentDuration(instance, duration)

    verify(instance).setContentDuration(duration.toFloat())
  }

  @Test
  fun setContentKeywords() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val keywords = listOf("good", "by")
    api.setContentKeywords(instance, keywords)

    verify(instance).setContentKeywords(keywords)
  }

  @Test
  fun setContentTitle() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val title = "title"
    api.setContentTitle(instance, title)

    verify(instance).setContentTitle(title)
  }

  @Test
  fun setContinuousPlayback() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val continuousPlayback = false
    api.setContinuousPlayback(instance, continuousPlayback)

    verify(instance).setContinuousPlayback(continuousPlayback)
  }

  @Test
  fun setLiveStreamPrefetchSeconds() {
    val api = TestProxyApiRegistrar().getPigeonApiAdsRequest()

    val instance = mock<AdsRequest>()
    val prefetchTime = 4.0
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
