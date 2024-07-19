// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.AdMediaInfo
import com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer
import com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate

/**
 * ProxyApi implementation for [VideoAdPlayer.VideoAdPlayerCallback].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class VideoAdPlayerCallbackProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiVideoAdPlayerCallback(pigeonRegistrar) {
  override fun onAdProgress(
      pigeon_instance: VideoAdPlayer.VideoAdPlayerCallback,
      adMediaInfo: AdMediaInfo,
      videoProgressUpdate: VideoProgressUpdate
  ) {
    pigeon_instance.onAdProgress(adMediaInfo, videoProgressUpdate)
  }

  override fun onBuffering(
      pigeon_instance: VideoAdPlayer.VideoAdPlayerCallback,
      adMediaInfo: AdMediaInfo
  ) {
    pigeon_instance.onBuffering(adMediaInfo)
  }

  override fun onContentComplete(pigeon_instance: VideoAdPlayer.VideoAdPlayerCallback) {
    pigeon_instance.onContentComplete()
  }

  override fun onEnded(
      pigeon_instance: VideoAdPlayer.VideoAdPlayerCallback,
      adMediaInfo: AdMediaInfo
  ) {
    pigeon_instance.onEnded(adMediaInfo)
  }

  override fun onError(
      pigeon_instance: VideoAdPlayer.VideoAdPlayerCallback,
      adMediaInfo: AdMediaInfo
  ) {
    pigeon_instance.onError(adMediaInfo)
  }

  override fun onLoaded(
      pigeon_instance: VideoAdPlayer.VideoAdPlayerCallback,
      adMediaInfo: AdMediaInfo
  ) {
    pigeon_instance.onLoaded(adMediaInfo)
  }

  override fun onPause(
      pigeon_instance: VideoAdPlayer.VideoAdPlayerCallback,
      adMediaInfo: AdMediaInfo
  ) {
    pigeon_instance.onPause(adMediaInfo)
  }

  override fun onPlay(
      pigeon_instance: VideoAdPlayer.VideoAdPlayerCallback,
      adMediaInfo: AdMediaInfo
  ) {
    pigeon_instance.onPlay(adMediaInfo)
  }

  override fun onResume(
      pigeon_instance: VideoAdPlayer.VideoAdPlayerCallback,
      adMediaInfo: AdMediaInfo
  ) {
    pigeon_instance.onResume(adMediaInfo)
  }

  override fun onVolumeChanged(
      pigeon_instance: VideoAdPlayer.VideoAdPlayerCallback,
      adMediaInfo: AdMediaInfo,
      percentage: Long
  ) {
    pigeon_instance.onVolumeChanged(adMediaInfo, percentage.toInt())
  }
}
