// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.StreamDisplayContainer
import com.google.ads.interactivemedia.v3.api.player.VideoStreamPlayer
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever

class StreamDisplayContainerProxyApiTest {
  @Test
  fun getVideoStreamPlayer() {
    val api = TestProxyApiRegistrar().getPigeonApiStreamDisplayContainer()

    val instance = mock<StreamDisplayContainer>()
    val value = mock<VideoStreamPlayer>()
    whenever(instance.videoStreamPlayer).thenReturn(value)

    assertEquals(value, api.getVideoStreamPlayer(instance))
  }
}
