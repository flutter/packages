package dev.flutter.packages.interactive_media_ads

import android.media.MediaPlayer

class MediaPlayerProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiMediaPlayer(pigeonRegistrar) {
  override fun getDuration(pigeon_instance: MediaPlayer): Long {
    return pigeon_instance.duration.toLong()
  }

  override fun seekTo(pigeon_instance: MediaPlayer, mSec: Long) {
    pigeon_instance.seekTo(mSec.toInt())
  }

  override fun start(pigeon_instance: MediaPlayer) {
    pigeon_instance.start()
  }

  override fun pause(pigeon_instance: MediaPlayer) {
    pigeon_instance.pause()
  }

  override fun stop(pigeon_instance: MediaPlayer) {
    pigeon_instance.stop()
  }
}
