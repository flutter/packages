// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdPodInfo
import com.google.ads.interactivemedia.v3.api.player.AdMediaInfo
import com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer
import com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate

/**
 * ProxyApi implementation for [VideoAdPlayer].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class VideoAdPlayerProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiVideoAdPlayer(pigeonRegistrar) {
  override fun pigeon_defaultConstructor(): VideoAdPlayer {
    return VideoAdPlayerImpl(this)
  }

  internal class VideoAdPlayerImpl(val api: VideoAdPlayerProxyApi) : VideoAdPlayer {
    var savedVolume: Int = 0

    var savedAdProgress: VideoProgressUpdate = VideoProgressUpdate.VIDEO_TIME_NOT_READY

    override fun getAdProgress(): VideoProgressUpdate {
      return savedAdProgress
    }

    override fun getVolume(): Int {
      return savedVolume
    }

    override fun addCallback(callback: VideoAdPlayer.VideoAdPlayerCallback) {
      api.pigeonRegistrar.runOnMainThread { api.addCallback(this, callbackArg = callback) {} }
    }

    override fun loadAd(adMediaInfo: AdMediaInfo, adPodInfo: AdPodInfo) {
      api.pigeonRegistrar.runOnMainThread { api.loadAd(this, adMediaInfo, adPodInfo) {} }
    }

    override fun pauseAd(adMediaInfo: AdMediaInfo) {
      api.pigeonRegistrar.runOnMainThread { api.pauseAd(this, adMediaInfo) {} }
    }

    override fun playAd(adMediaInfo: AdMediaInfo) {
      api.pigeonRegistrar.runOnMainThread { api.playAd(this, adMediaInfo) {} }
    }

    override fun release() {
      api.pigeonRegistrar.runOnMainThread { api.release(this) {} }
    }

    override fun removeCallback(callback: VideoAdPlayer.VideoAdPlayerCallback) {
      api.pigeonRegistrar.runOnMainThread { api.removeCallback(this, callbackArg = callback) {} }
    }

    override fun stopAd(adMediaInfo: AdMediaInfo) {
      api.pigeonRegistrar.runOnMainThread { api.stopAd(this, adMediaInfo) {} }
    }
  }

  /**
   * Sets the internal `volume` variable that is returned in the [VideoAdPlayer.getVolume] callback.
   */
  override fun setVolume(pigeon_instance: VideoAdPlayer, value: Long) {
    (pigeon_instance as VideoAdPlayerImpl).savedVolume = value.toInt()
  }

  /**
   * Sets the internal `adProgress` variable that is returned in the [VideoAdPlayer.getAdProgress]
   * callback.
   */
  override fun setAdProgress(pigeon_instance: VideoAdPlayer, progress: VideoProgressUpdate) {
    (pigeon_instance as VideoAdPlayerImpl).savedAdProgress = progress
  }
}
