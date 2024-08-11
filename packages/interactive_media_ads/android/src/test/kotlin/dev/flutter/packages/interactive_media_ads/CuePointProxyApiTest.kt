// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.CuePoint
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class CuePointProxyApiTest {
  @Test
  fun endTimeMs() {
    val api = TestProxyApiRegistrar().getPigeonApiCuePoint()

    val instance = mock<CuePoint>()
    val value = 0L
    whenever(instance.endTimeMs).thenReturn(value)

    assertEquals(value, api.endTimeMs(instance))
  }

  @Test
  fun startTimeMs() {
    val api = TestProxyApiRegistrar().getPigeonApiCuePoint()

    val instance = mock<CuePoint>()
    val value = 0L
    whenever(instance.startTimeMs).thenReturn(value)

    assertEquals(value, api.startTimeMs(instance))
  }

  @Test
  fun isPlayed() {
    val api = TestProxyApiRegistrar().getPigeonApiCuePoint()

    val instance = mock<CuePoint>()
    val value = true
    whenever(instance.isPlayed).thenReturn(value)

    assertEquals(value, api.isPlayed(instance))
  }
}
