// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdPodInfo
import com.google.ads.interactivemedia.v3.api.player.AdMediaInfo
import com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer
import com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class VideoAdPlayerProxyApiTest {
  @Test
  fun pigeon_defaultConstructor() {
    val api = ProxyApiRegistrar(Mockito.mock(), Mockito.mock()).getPigeonApiVideoAdPlayer()

    assertTrue(api.pigeon_defaultConstructor() is VideoAdPlayerProxyApi.VideoAdPlayerImpl)
  }

  @Test
  fun setVolume() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayer()

    val instance = VideoAdPlayerProxyApi.VideoAdPlayerImpl(api as VideoAdPlayerProxyApi)
    api.setVolume(instance, 0)

    assertEquals(0, instance.volume)
  }

  @Test
  fun setAdProgress() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayer()

    val instance = VideoAdPlayerProxyApi.VideoAdPlayerImpl(api as VideoAdPlayerProxyApi)
    val mockProgressUpdate = mock<VideoProgressUpdate>()
    api.setAdProgress(instance, mockProgressUpdate)

    assertEquals(mockProgressUpdate, instance.adProgress)
  }

  @Test
  fun addCallback() {
    val mockApi = Mockito.mock<VideoAdPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoAdPlayerProxyApi.VideoAdPlayerImpl(mockApi)
    val mockCallback = Mockito.mock<VideoAdPlayer.VideoAdPlayerCallback>()
    instance.addCallback(mockCallback)

    Mockito.verify(mockApi).addCallback(eq(instance), eq(mockCallback), any())
  }

  @Test
  fun loadAd() {
    val mockApi = Mockito.mock<VideoAdPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoAdPlayerProxyApi.VideoAdPlayerImpl(mockApi)
    val mockMediaInfo = mock<AdMediaInfo>()
    val mockPodInfo = mock<AdPodInfo>()
    instance.loadAd(mockMediaInfo, mockPodInfo)

    Mockito.verify(mockApi).loadAd(eq(instance), eq(mockMediaInfo), eq(mockPodInfo), any())
  }

  @Test
  fun pauseAd() {
    val mockApi = Mockito.mock<VideoAdPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoAdPlayerProxyApi.VideoAdPlayerImpl(mockApi)
    val mockMediaInfo = mock<AdMediaInfo>()
    instance.pauseAd(mockMediaInfo)

    Mockito.verify(mockApi).pauseAd(eq(instance), eq(mockMediaInfo), any())
  }

  @Test
  fun playAd() {
    val mockApi = Mockito.mock<VideoAdPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoAdPlayerProxyApi.VideoAdPlayerImpl(mockApi)
    val mockMediaInfo = mock<AdMediaInfo>()
    instance.playAd(mockMediaInfo)

    Mockito.verify(mockApi).playAd(eq(instance), eq(mockMediaInfo), any())
  }

  @Test
  fun release() {
    val mockApi = Mockito.mock<VideoAdPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoAdPlayerProxyApi.VideoAdPlayerImpl(mockApi)
    instance.release()

    Mockito.verify(mockApi).release(eq(instance), any())
  }

  @Test
  fun removeCallback() {
    val mockApi = Mockito.mock<VideoAdPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoAdPlayerProxyApi.VideoAdPlayerImpl(mockApi)
    val mockCallback = Mockito.mock<VideoAdPlayer.VideoAdPlayerCallback>()
    instance.removeCallback(mockCallback)

    Mockito.verify(mockApi).removeCallback(eq(instance), eq(mockCallback), any())
  }

  @Test
  fun stopAd() {
    val mockApi = Mockito.mock<VideoAdPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoAdPlayerProxyApi.VideoAdPlayerImpl(mockApi)
    val mockMediaInfo = mock<AdMediaInfo>()
    instance.stopAd(mockMediaInfo)

    Mockito.verify(mockApi).stopAd(eq(instance), eq(mockMediaInfo), any())
  }
}
