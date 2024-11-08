// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdError
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.Mockito
import org.mockito.kotlin.whenever

class AdErrorProxyApiTest {
  @Test
  fun errorCode() {
    val api = TestProxyApiRegistrar().getPigeonApiAdError()

    val instance = Mockito.mock<AdError>()
    whenever(instance.errorCode).thenReturn(AdError.AdErrorCode.VIDEO_PLAY_ERROR)

    assertEquals(AdErrorCode.VIDEO_PLAY_ERROR, api.errorCode(instance))
  }

  @Test
  fun errorCodeNumber() {
    val api = TestProxyApiRegistrar().getPigeonApiAdError()

    val instance = Mockito.mock<AdError>()
    whenever(instance.errorCodeNumber).thenReturn(0)

    assertEquals(0, api.errorCodeNumber(instance))
  }

  @Test
  fun errorType() {
    val api = TestProxyApiRegistrar().getPigeonApiAdError()

    val instance = Mockito.mock<AdError>()
    whenever(instance.errorType).thenReturn(AdError.AdErrorType.LOAD)

    assertEquals(AdErrorType.LOAD, api.errorType(instance))
  }

  @Test
  fun message() {
    val api = TestProxyApiRegistrar().getPigeonApiAdError()

    val instance = Mockito.mock<AdError>()
    whenever(instance.message).thenReturn("message")

    assertEquals("message", api.message(instance))
  }
}
