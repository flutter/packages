// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.StreamRequest
import com.google.ads.interactivemedia.v3.api.StreamRequest.StreamFormat
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class StreamRequestProxyApiTest {
  @Test
  fun getAdTagParameters() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = mapOf("myString" to "myString")
    whenever(instance.adTagParameters).thenReturn(value)

    assertEquals(value, api.getAdTagParameters(instance ))
  }

  @Test
  fun getAdTagUrl() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.adTagUrl).thenReturn(value)

    assertEquals(value, api.getAdTagUrl(instance ))
  }

  @Test
  fun getApiKey() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.apiKey).thenReturn(value)

    assertEquals(value, api.getApiKey(instance ))
  }

  @Test
  fun getAssetKey() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.assetKey).thenReturn(value)

    assertEquals(value, api.getAssetKey(instance ))
  }

  @Test
  fun getAuthToken() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.authToken).thenReturn(value)

    assertEquals(value, api.getAuthToken(instance ))
  }

  @Test
  fun getContentSourceId() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.contentSourceId).thenReturn(value)

    assertEquals(value, api.getContentSourceId(instance ))
  }

  @Test
  fun getContentSourceUrl() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.contentSourceUrl).thenReturn(value)

    assertEquals(value, api.getContentSourceUrl(instance ))
  }

  @Test
  fun getCustomAssetKey() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.customAssetKey).thenReturn(value)

    assertEquals(value, api.getCustomAssetKey(instance ))
  }

  @Test
  fun getFormat() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = dev.flutter.packages.interactive_media_ads.StreamFormat.DASH
    whenever(instance.format).thenReturn(StreamFormat.DASH)

    assertEquals(value, api.getFormat(instance))
  }

  @Test
  fun getManifestSuffix() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.manifestSuffix).thenReturn(value)

    assertEquals(value, api.getManifestSuffix(instance ))
  }

  @Test
  fun getNetworkCode() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.networkCode).thenReturn(value)

    assertEquals(value, api.getNetworkCode(instance ))
  }

  @Test
  fun getVideoId() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.videoId).thenReturn(value)

    assertEquals(value, api.getVideoId(instance ))
  }

  @Test
  fun getVideoStitcherSessionOptions() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = mapOf("myString" to -1)
    whenever(instance.videoStitcherSessionOptions).thenReturn(value)

    assertEquals(value, api.getVideoStitcherSessionOptions(instance ))
  }

  @Test
  fun getVodConfigId() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val value = "myString"
    whenever(instance.vodConfigId).thenReturn(value)

    assertEquals(value, api.getVodConfigId(instance ))
  }

  @Test
  fun setAdTagParameters() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val adTagParameters = mapOf("myString" to "myString")
    api.setAdTagParameters(instance, adTagParameters)

    verify(instance).setAdTagParameters(adTagParameters)
  }

  @Test
  fun setAuthToken() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val authToken = "myString"
    api.setAuthToken(instance, authToken)

    verify(instance).authToken = authToken
  }

  @Test
  fun setFormat() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val format = dev.flutter.packages.interactive_media_ads.StreamFormat.DASH
    api.setFormat(instance, format)

    verify(instance).format = StreamFormat.DASH
  }

  @Test
  fun setManifestSuffix() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val manifestSuffix = "myString"
    api.setManifestSuffix(instance, manifestSuffix)

    verify(instance).manifestSuffix = manifestSuffix
  }

  @Test
  fun setStreamActivityMonitorId() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val streamActivityMonitorId = "myString"
    api.setStreamActivityMonitorId(instance, streamActivityMonitorId)

    verify(instance).streamActivityMonitorId = streamActivityMonitorId
  }

  @Test
  fun setVideoStitcherSessionOptions() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamRequest()

    val instance = mock<StreamRequest>()
    val videoStitcherSessionOptions = mapOf("myString" to -1)
    api.setVideoStitcherSessionOptions(instance, videoStitcherSessionOptions)

    verify(instance).setVideoStitcherSessionOptions(videoStitcherSessionOptions)
  }
}
