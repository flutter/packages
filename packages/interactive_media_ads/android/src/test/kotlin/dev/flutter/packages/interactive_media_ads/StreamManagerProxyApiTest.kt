// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.CuePoint
import com.google.ads.interactivemedia.v3.api.StreamManager
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class StreamManagerProxyApiTest {
  @Test
  fun getContentTimeMsForStreamTimeMs() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamManager()

    val instance = mock<StreamManager>()
    val streamTimeMs = 0L
    val value = 0L
    whenever(instance.getContentTimeMsForStreamTimeMs(streamTimeMs)).thenReturn(value)

    assertEquals(value, api.getContentTimeMsForStreamTimeMs(instance, streamTimeMs))
  }

  @Test
  fun getCuePoints() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamManager()

    val instance = mock<StreamManager>()
    val value = listOf(mock<CuePoint>())
    whenever(instance.cuePoints).thenReturn(value)

    assertEquals(value, api.getCuePoints(instance))
  }

  @Test
  fun getPreviousCuePointForStreamTimeMs() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamManager()

    val instance = mock<StreamManager>()
    val streamTimeMs = 0L
    val value = mock<CuePoint>()
    whenever(instance.getPreviousCuePointForStreamTimeMs(streamTimeMs)).thenReturn(value)

    assertEquals(value, api.getPreviousCuePointForStreamTimeMs(instance, streamTimeMs))
  }

  @Test
  fun getStreamId() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamManager()

    val instance = mock<StreamManager>()
    val value = "myString"
    whenever(instance.streamId).thenReturn(value)

    assertEquals(value, api.getStreamId(instance))
  }

  @Test
  fun getStreamTimeMsForContentTimeMs() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamManager()

    val instance = mock<StreamManager>()
    val contentTimeMs = 0L
    val value = 0L
    whenever(instance.getStreamTimeMsForContentTimeMs(contentTimeMs)).thenReturn(value)

    assertEquals(value, api.getStreamTimeMsForContentTimeMs(instance, contentTimeMs))
  }

  @Test
  fun loadThirdPartyStream() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamManager()

    val instance = mock<StreamManager>()
    val streamUrl = "myString"
    val streamSubtitles = listOf(mapOf("myString" to "myString"))
    api.loadThirdPartyStream(instance, streamUrl, streamSubtitles)

    verify(instance).loadThirdPartyStream(streamUrl, streamSubtitles)
  }

  @Test
  fun replaceAdTagParameters() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamManager()

    val instance = mock<StreamManager>()
    val adTagParameters = mapOf("myString" to "myString")
    api.replaceAdTagParameters(instance, adTagParameters)

    verify(instance).replaceAdTagParameters(adTagParameters)
  }
}
