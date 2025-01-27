// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdError
import com.google.ads.interactivemedia.v3.api.AdErrorEvent
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.Mockito.mock
import org.mockito.kotlin.whenever

internal class AdErrorEventProxyApiTest {
  @Test
  fun error() {
    val api = TestProxyApiRegistrar().getPigeonApiAdErrorEvent()

    val instance = mock<AdErrorEvent>()
    val mockError = mock<AdError>()
    whenever(instance.error).thenReturn(mockError)

    assertEquals(mockError, api.error(instance))
  }
}
