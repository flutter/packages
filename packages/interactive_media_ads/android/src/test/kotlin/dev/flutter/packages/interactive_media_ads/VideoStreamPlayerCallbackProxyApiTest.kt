// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.VideoStreamPlayer.VideoStreamPlayerCallback
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

class VideoStreamPlayerCallbackProxyApiTest {
  @Test
  fun onContentComplete() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoStreamPlayerCallback()

    val instance = mock<VideoStreamPlayerCallback>()
    api.onContentComplete(instance)

    verify(instance).onContentComplete()
  }

  @Test
  fun onPause() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoStreamPlayerCallback()

    val instance = mock<VideoStreamPlayerCallback>()
    api.onPause(instance)

    verify(instance).onPause()
  }

  @Test
  fun onResume() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoStreamPlayerCallback()

    val instance = mock<VideoStreamPlayerCallback>()
    api.onResume(instance)

    verify(instance).onResume()
  }

  @Test
  fun onUserTextReceived() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoStreamPlayerCallback()

    val instance = mock<VideoStreamPlayerCallback>()
    val userText = "myString"
    api.onUserTextReceived(instance, userText)

    verify(instance).onUserTextReceived(userText)
  }

  @Test
  fun onVolumeChanged() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoStreamPlayerCallback()

    val instance = mock<VideoStreamPlayerCallback>()
    val percentage = 0L
    api.onVolumeChanged(instance, percentage)

    verify(instance).onVolumeChanged(percentage.toInt())
  }
}
