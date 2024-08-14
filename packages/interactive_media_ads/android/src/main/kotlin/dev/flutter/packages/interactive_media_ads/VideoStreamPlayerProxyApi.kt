// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate
import com.google.ads.interactivemedia.v3.api.player.VideoStreamPlayer
import com.google.ads.interactivemedia.v3.api.player.VideoStreamPlayer.VideoStreamPlayerCallback

/**
 * ProxyApi implementation for [VideoStreamPlayer].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class VideoStreamPlayerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiVideoStreamPlayer(pigeonRegistrar) {
  open class VideoStreamPlayerImpl(val api: VideoStreamPlayerProxyApi) : VideoStreamPlayer {
    var savedVolume: Int = 0

    var savedContentProgress: VideoProgressUpdate = VideoProgressUpdate.VIDEO_TIME_NOT_READY

    override fun getContentProgress(): VideoProgressUpdate {
      return savedContentProgress
    }

    override fun getVolume(): Int {
      return savedVolume
    }

    override fun addCallback(callback: VideoStreamPlayerCallback) {
      api.pigeonRegistrar.runOnMainThread { api.addCallback(this, callback) {} }
    }

    override fun loadUrl(url: String, subtitles: List<HashMap<String, String>>) {
      api.pigeonRegistrar.runOnMainThread { api.loadUrl(this, url, subtitles) {} }
    }

    override fun onAdBreakEnded() {
      api.pigeonRegistrar.runOnMainThread { api.onAdBreakEnded(this) {} }
    }

    override fun onAdBreakStarted() {
      api.pigeonRegistrar.runOnMainThread { api.onAdBreakStarted(this) {} }
    }

    override fun onAdPeriodEnded() {
      api.pigeonRegistrar.runOnMainThread { api.onAdPeriodEnded(this) {} }
    }

    override fun onAdPeriodStarted() {
      api.pigeonRegistrar.runOnMainThread { api.onAdPeriodStarted(this) {} }
    }

    override fun pause() {
      api.pigeonRegistrar.runOnMainThread { api.pause(this) {} }
    }

    override fun removeCallback(callback: VideoStreamPlayerCallback) {
      api.pigeonRegistrar.runOnMainThread { api.removeCallback(this, callback) {} }
    }

    override fun resume() {
      api.pigeonRegistrar.runOnMainThread { api.resume(this) {} }
    }

    override fun seek(time: Long) {
      api.pigeonRegistrar.runOnMainThread { api.seek(this, time) {} }
    }
  }

  override fun pigeon_defaultConstructor(): VideoStreamPlayer {
    return VideoStreamPlayerImpl(this)
  }

  override fun setVolume(pigeon_instance: VideoStreamPlayer, value: Long) {
    (pigeon_instance as VideoStreamPlayerImpl).savedVolume = value.toInt()
  }

  override fun setContentProgress(
      pigeon_instance: VideoStreamPlayer,
      progress: VideoProgressUpdate
  ) {
    (pigeon_instance as VideoStreamPlayerImpl).savedContentProgress = progress
  }
}
