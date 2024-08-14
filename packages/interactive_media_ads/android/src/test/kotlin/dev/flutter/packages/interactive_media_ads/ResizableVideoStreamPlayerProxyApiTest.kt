// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import kotlin.test.Test
import org.mockito.Mockito.mock
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class ResizableVideoStreamPlayerProxyApiTest {
  @Test
  fun resize() {
    val mockApi = mock<ResizableVideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeonRegistrar).thenReturn(TestProxyApiRegistrar())

    val mockVideoStreamPlayerApi = mock<VideoStreamPlayerProxyApi>()
    whenever(mockApi.pigeon_getPigeonApiVideoStreamPlayer()).thenReturn(mockVideoStreamPlayerApi)

    val mockResizablePlayerApi = mock<PigeonApiResizablePlayer>()
    whenever(mockApi.pigeon_getPigeonApiResizablePlayer()).thenReturn(mockResizablePlayerApi)

    val instance = ResizableVideoStreamPlayerProxyApi.ResizableVideoStreamPlayer(mockApi)

    val leftMargin = 0
    val topMargin = 1
    val rightMargin = 2
    val bottomMargin = 3
    instance.resize(0, 1, 2, 3)

    verify(mockResizablePlayerApi)
        .resize(
            eq(instance),
            eq(leftMargin.toLong()),
            eq(topMargin.toLong()),
            eq(rightMargin.toLong()),
            eq(bottomMargin.toLong()),
            any())
  }
}
