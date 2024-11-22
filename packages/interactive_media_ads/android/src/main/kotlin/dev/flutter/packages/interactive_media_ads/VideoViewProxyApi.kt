// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.media.MediaPlayer
import android.net.Uri
import android.widget.VideoView

/**
 * ProxyApi implementation for [VideoView].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class VideoViewProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiVideoView(pigeonRegistrar) {

  override fun pigeon_defaultConstructor(): VideoView {
    val instance = VideoView(pigeonRegistrar.context)
    instance.setOnPreparedListener { player: MediaPlayer -> onPrepared(instance, player) {} }
    instance.setOnErrorListener { player: MediaPlayer, what: Int, extra: Int ->
      onError(instance, player, what.toLong(), extra.toLong()) {}
      true
    }
    instance.setOnCompletionListener { player: MediaPlayer -> onCompletion(instance, player) {} }
    return instance
  }

  override fun setVideoUri(pigeon_instance: VideoView, uri: String?) {
    pigeon_instance.setVideoURI(if (uri != null) Uri.parse(uri) else null)
  }

  override fun getCurrentPosition(pigeon_instance: VideoView): Long {
    return pigeon_instance.currentPosition.toLong()
  }
}
