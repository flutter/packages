// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdDisplayContainer
import com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.mockito.Mockito
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class AdDisplayContainerProxyApiTest {
  @Test
  fun getPlayer() {
    val api = TestProxyApiRegistrar().getPigeonApiAdDisplayContainer()

    val instance = mock<AdDisplayContainer>()
    val value = mock<VideoAdPlayer>()
    whenever(instance.player).thenReturn(value)

    assertEquals(value, api.getPlayer(instance ))
  }
}
