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
      (api.pigeonRegistrar as ProxyApiRegistrar).runOnMainThread {
        api.addCallback(this, callbackArg = callback) {}
      }
    }

    override fun loadAd(adMediaInfo: AdMediaInfo, adPodInfo: AdPodInfo) {
      (api.pigeonRegistrar as ProxyApiRegistrar).runOnMainThread {
        api.loadAd(this, adMediaInfo, adPodInfo) {}
      }
    }

    override fun pauseAd(adMediaInfo: AdMediaInfo) {
      (api.pigeonRegistrar as ProxyApiRegistrar).runOnMainThread {
        api.pauseAd(this, adMediaInfo) {}
      }
    }

    override fun playAd(adMediaInfo: AdMediaInfo) {
      (api.pigeonRegistrar as ProxyApiRegistrar).runOnMainThread {
        api.playAd(this, adMediaInfo) {}
      }
    }

    override fun release() {
      (api.pigeonRegistrar as ProxyApiRegistrar).runOnMainThread { api.release(this) {} }
    }

    override fun removeCallback(callback: VideoAdPlayer.VideoAdPlayerCallback) {
      (api.pigeonRegistrar as ProxyApiRegistrar).runOnMainThread {
        api.removeCallback(this, callbackArg = callback) {}
      }
    }

    override fun stopAd(adMediaInfo: AdMediaInfo) {
      (api.pigeonRegistrar as ProxyApiRegistrar).runOnMainThread {
        api.stopAd(this, adMediaInfo) {}
      }
    }
  }

  override fun setVolume(pigeon_instance: VideoAdPlayer, value: Long) {
    (pigeon_instance as VideoAdPlayerImpl).savedVolume = value.toInt()
  }

  override fun setAdProgress(pigeon_instance: VideoAdPlayer, progress: VideoProgressUpdate) {
    (pigeon_instance as VideoAdPlayerImpl).savedAdProgress = progress
  }
}
