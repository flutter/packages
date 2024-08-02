// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.AdMediaInfo
import com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer.VideoAdPlayerCallback
import com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate
import kotlin.test.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify

class VideoAdPlayerCallbackProxyApiTest {
  @Test
  fun onAdProgress() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayerCallback()

    val instance = mock<VideoAdPlayerCallback>()
    val mockInfo = mock<AdMediaInfo>()
    val mockUpdate = mock<VideoProgressUpdate>()
    api.onAdProgress(instance, mockInfo, mockUpdate)

    verify(instance).onAdProgress(mockInfo, mockUpdate)
  }

  @Test
  fun onBuffering() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayerCallback()

    val instance = mock<VideoAdPlayerCallback>()
    val mockInfo = mock<AdMediaInfo>()
    api.onBuffering(instance, mockInfo)

    verify(instance).onBuffering(mockInfo)
  }

  @Test
  fun onContentComplete() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayerCallback()

    val instance = mock<VideoAdPlayerCallback>()
    api.onContentComplete(instance)

    verify(instance).onContentComplete()
  }

  @Test
  fun onEnded() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayerCallback()

    val instance = mock<VideoAdPlayerCallback>()
    val mockInfo = mock<AdMediaInfo>()
    api.onEnded(instance, mockInfo)

    verify(instance).onEnded(mockInfo)
  }

  @Test
  fun onError() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayerCallback()

    val instance = mock<VideoAdPlayerCallback>()
    val mockInfo = mock<AdMediaInfo>()
    api.onError(instance, mockInfo)

    verify(instance).onError(mockInfo)
  }

  @Test
  fun onLoaded() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayerCallback()

    val instance = mock<VideoAdPlayerCallback>()
    val mockInfo = mock<AdMediaInfo>()
    api.onLoaded(instance, mockInfo)

    verify(instance).onLoaded(mockInfo)
  }

  @Test
  fun onPause() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayerCallback()

    val instance = mock<VideoAdPlayerCallback>()
    val mockInfo = mock<AdMediaInfo>()
    api.onPause(instance, mockInfo)

    verify(instance).onPause(mockInfo)
  }

  @Test
  fun onPlay() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayerCallback()

    val instance = mock<VideoAdPlayerCallback>()
    val mockInfo = mock<AdMediaInfo>()
    api.onPlay(instance, mockInfo)

    verify(instance).onPlay(mockInfo)
  }

  @Test
  fun onResume() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayerCallback()

    val instance = mock<VideoAdPlayerCallback>()
    val mockInfo = mock<AdMediaInfo>()
    api.onResume(instance, mockInfo)

    verify(instance).onResume(mockInfo)
  }

  @Test
  fun onVolumeChanged() {
    val api = TestProxyApiRegistrar().getPigeonApiVideoAdPlayerCallback()

    val instance = mock<VideoAdPlayerCallback>()
    val mockInfo = mock<AdMediaInfo>()
    api.onVolumeChanged(instance, mockInfo, 0)

    verify(instance).onVolumeChanged(mockInfo, 0)
  }
}
