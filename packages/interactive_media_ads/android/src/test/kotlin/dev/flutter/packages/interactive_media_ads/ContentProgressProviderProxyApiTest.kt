// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.mockito.kotlin.mock

class ContentProgressProviderProxyApiTest {
  @Test
  fun pigeon_defaultConstructor() {
    val api = TestProxyApiRegistrar().getPigeonApiContentProgressProvider()

    assertTrue(
        api.pigeon_defaultConstructor()
            is ContentProgressProviderProxyApi.ContentProgressProviderImpl)
  }

  @Test
  fun setContentProgress() {
    val api = TestProxyApiRegistrar().getPigeonApiContentProgressProvider()

    val instance =
        ContentProgressProviderProxyApi.ContentProgressProviderImpl(
            api as ContentProgressProviderProxyApi)
    val mockProgressUpdate = mock<VideoProgressUpdate>()
    api.setContentProgress(instance, mockProgressUpdate)

    assertEquals(mockProgressUpdate, instance.currentProgress)
    assertEquals(mockProgressUpdate, instance.contentProgress)
  }
}
