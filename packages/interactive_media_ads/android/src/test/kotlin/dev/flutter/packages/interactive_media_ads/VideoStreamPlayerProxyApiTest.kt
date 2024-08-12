// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate
import com.google.ads.interactivemedia.v3.api.player.VideoStreamPlayer.VideoStreamPlayerCallback
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class VideoStreamPlayerProxyApiTest {
  @Test
  fun pigeon_defaultConstructor() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoStreamPlayer()

    assertTrue(api.pigeon_defaultConstructor() is VideoStreamPlayerProxyApi.VideoStreamPlayerImpl)
  }

  @Test
  fun addCallback() {
    val mockApi = mock<VideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(mockApi)
    val callback = mock<VideoStreamPlayerCallback>()
    instance.addCallback(callback)

    verify(mockApi).addCallback(eq(instance), eq(callback), any())
  }

  @Test
  fun loadUrl() {
    val mockApi = mock<VideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(mockApi)
    val url = "myString"
    val subtitlesMap = HashMap<String, String>()
    subtitlesMap["myString"] = "myOtherString"
    val subtitles = listOf(subtitlesMap)
    instance.loadUrl(url, subtitles)

    verify(mockApi).loadUrl(eq(instance), eq(url), eq(subtitles), any())
  }

  @Test
  fun onAdBreakEnded() {
    val mockApi = mock<VideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(mockApi)
    instance.onAdBreakEnded()

    verify(mockApi).onAdBreakEnded(eq(instance), any())
  }

  @Test
  fun onAdBreakStarted() {
    val mockApi = mock<VideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(mockApi)
    instance.onAdBreakStarted()

    verify(mockApi).onAdBreakStarted(eq(instance), any())
  }

  @Test
  fun onAdPeriodEnded() {
    val mockApi = mock<VideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(mockApi)
    instance.onAdPeriodEnded()

    verify(mockApi).onAdPeriodEnded(eq(instance), any())
  }

  @Test
  fun onAdPeriodStarted() {
    val mockApi = mock<VideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(mockApi)
    instance.onAdPeriodStarted()

    verify(mockApi).onAdPeriodStarted(eq(instance), any())
  }

  @Test
  fun pause() {
    val mockApi = mock<VideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(mockApi)
    instance.pause()

    verify(mockApi).pause(eq(instance), any())
  }

  @Test
  fun removeCallback() {
    val mockApi = mock<VideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(mockApi)
    val callback = mock<VideoStreamPlayerCallback>()
    instance.removeCallback(callback)

    verify(mockApi).removeCallback(eq(instance), eq(callback), any())
  }

  @Test
  fun resume() {
    val mockApi = mock<VideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(mockApi)
    instance.resume()

    verify(mockApi).resume(eq(instance), any())
  }

  @Test
  fun seek() {
    val mockApi = mock<VideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(mockApi)
    val time = 0L
    instance.seek(time)

    verify(mockApi).seek(eq(instance), eq(time), any())
  }

  @Test
  fun setVolume() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoStreamPlayer()

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(api as VideoStreamPlayerProxyApi)
    api.setVolume(instance, 0)

    assertEquals(0, instance.volume)
  }

  @Test
  fun setAdProgress() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoStreamPlayer()

    val instance = VideoStreamPlayerProxyApi.VideoStreamPlayerImpl(api as VideoStreamPlayerProxyApi)
    val mockProgressUpdate = mock<VideoProgressUpdate>()
    api.setContentProgress(instance, mockProgressUpdate)

    assertEquals(mockProgressUpdate, instance.savedContentProgress)
  }
}
