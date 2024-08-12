// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.FriendlyObstruction
import com.google.ads.interactivemedia.v3.api.FriendlyObstructionPurpose
import android.view.View
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class FriendlyObstructionProxyApiTest {
  @Test
  fun detailedReason() {
    val api = TestProxyApiRegistrar().getPigeonApiFriendlyObstruction()

    val instance = mock<FriendlyObstruction>()
    val value = "myString"
    whenever(instance.detailedReason).thenReturn(value)

    assertEquals(value, api.detailedReason(instance))
  }

  @Test
  fun purpose() {
    val api = TestProxyApiRegistrar().getPigeonApiFriendlyObstruction()

    val instance = mock<FriendlyObstruction>()
    val value = dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.CLOSE_AD
    whenever(instance.purpose).thenReturn(FriendlyObstructionPurpose.CLOSE_AD)

    assertEquals(value, api.purpose(instance))
  }

  @Test
  fun view() {
    val api = TestProxyApiRegistrar().getPigeonApiFriendlyObstruction()

    val instance = mock<FriendlyObstruction>()
    val value = mock<View>()
    whenever(instance.view).thenReturn(value)

    assertEquals(value, api.view(instance))
  }
}
