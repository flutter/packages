// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdPodInfo
import com.google.ads.interactivemedia.v3.api.player.AdMediaInfo
import com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer
import com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate

class VideoAdPlayerProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiVideoAdPlayer(pigeonRegistrar) {
  override fun pigeon_defaultConstructor(): VideoAdPlayer {
    return VideoAdPlayerImpl(this)
  }

  private class VideoAdPlayerImpl(val api: VideoAdPlayerProxyApi) : VideoAdPlayer {
    var _volume: Int = 0

    var _adProgress: VideoProgressUpdate = VideoProgressUpdate.VIDEO_TIME_NOT_READY

    override fun getAdProgress(): VideoProgressUpdate {
      return _adProgress
    }

    override fun getVolume(): Int {
      return _volume
    }

    override fun addCallback(callback: VideoAdPlayer.VideoAdPlayerCallback) {
      api.addCallback(this, callbackArg = callback) {}
    }

    override fun loadAd(adMediaInfo: AdMediaInfo, adPodInfo: AdPodInfo) {
      api.loadAd(this, adMediaInfo, adPodInfo) {}
    }

    override fun pauseAd(adMediaInfo: AdMediaInfo) {
      api.pauseAd(this, adMediaInfo) {}
    }

    override fun playAd(adMediaInfo: AdMediaInfo) {
      api.playAd(this, adMediaInfo) {}
    }

    override fun release() {
      api.release(this) {}
    }

    override fun removeCallback(callback: VideoAdPlayer.VideoAdPlayerCallback) {
      api.removeCallback(this, callbackArg = callback) {}
    }

    override fun stopAd(adMediaInfo: AdMediaInfo) {
      api.stopAd(this, adMediaInfo) {}
    }
  }

  override fun setVolume(pigeon_instance: VideoAdPlayer, value: Long) {
    (pigeon_instance as VideoAdPlayerImpl)._volume = value.toInt()
  }

  override fun setAdProgress(pigeon_instance: VideoAdPlayer, progress: VideoProgressUpdate) {
    (pigeon_instance as VideoAdPlayerImpl)._adProgress = progress
  }
}
