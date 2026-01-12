// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.widget.VideoView
import androidx.core.net.toUri

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
    pigeon_instance.setVideoURI(uri?.toUri())
  }

  override fun getCurrentPosition(pigeon_instance: VideoView): Long {
    return pigeon_instance.currentPosition.toLong()
  }

  override fun setAudioFocusRequest(pigeon_instance: VideoView, focusGain: AudioManagerAudioFocus) {
    if (pigeonRegistrar.sdkIsAtLeast(Build.VERSION_CODES.O)) {
      pigeon_instance.setAudioFocusRequest(
          when (focusGain) {
            AudioManagerAudioFocus.GAIN -> AudioManager.AUDIOFOCUS_GAIN
            AudioManagerAudioFocus.GAIN_TRANSIENT -> AudioManager.AUDIOFOCUS_GAIN_TRANSIENT
            AudioManagerAudioFocus.GAIN_TRANSIENT_EXCLUSIVE ->
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE
            AudioManagerAudioFocus.GAIN_TRANSIENT_MAY_DUCK ->
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK
            AudioManagerAudioFocus.NONE -> AudioManager.AUDIOFOCUS_NONE
          })
    }
  }
}
