// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.VideoStreamPlayer.VideoStreamPlayerCallback

/**
 * ProxyApi implementation for [VideoStreamPlayerCallback].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class VideoStreamPlayerCallbackProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiVideoStreamPlayerCallback(pigeonRegistrar) {

  override fun onContentComplete(pigeon_instance: VideoStreamPlayerCallback) {
    pigeon_instance.onContentComplete()
  }

  override fun onPause(pigeon_instance: VideoStreamPlayerCallback) {
    pigeon_instance.onPause()
  }

  override fun onResume(pigeon_instance: VideoStreamPlayerCallback) {
    pigeon_instance.onResume()
  }

  override fun onUserTextReceived(pigeon_instance: VideoStreamPlayerCallback, userText: String) {
    pigeon_instance.onUserTextReceived(userText)
  }

  override fun onVolumeChanged(pigeon_instance: VideoStreamPlayerCallback, percentage: Long) {
    pigeon_instance.onVolumeChanged(percentage.toInt())
  }
}
