// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.media.AudioManager
import android.net.Uri
import android.widget.VideoView
import kotlin.test.Test
import kotlin.test.assertEquals
import org.mockito.kotlin.isNotNull
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever

class VideoViewProxyApiTest {
  @Test
  fun setVideoURI() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoView()

    val instance = mock<VideoView>()
    api.setVideoUri(instance, "adTag")

    verify(instance).setVideoURI(isNotNull())
    assertEquals("adTag", Uri.lastValue)
  }

  @Test
  fun getCurrentPosition() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoView()

    val instance = mock<VideoView>()
    whenever(instance.currentPosition).thenReturn(0)
    api.getCurrentPosition(instance)

    assertEquals(0, api.getCurrentPosition(instance))
  }

  @Test
  fun setAudioFocusRequest() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoView()

    val instance = mock<VideoView>()
    api.setAudioFocusRequest(instance, AudioManagerAudioFocus.GAIN)

    verify(instance).setAudioFocusRequest(AudioManager.AUDIOFOCUS_GAIN)
  }
}
