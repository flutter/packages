package dev.flutter.packages.interactive_media_ads

import android.media.MediaPlayer
import android.net.Uri
import android.widget.VideoView

class VideoViewProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiVideoView(pigeonRegistrar) {

  override fun pigeon_defaultConstructor(): VideoView {
    val instance = VideoView((pigeonRegistrar as ProxyApiRegistrar).context)
    instance.setOnPreparedListener { player: MediaPlayer -> onPrepared(instance, player) {} }
    instance.setOnErrorListener { player: MediaPlayer, what: Int, extra: Int ->
      onError(instance, player, what.toLong(), extra.toLong()) {}
      true
    }
    instance.setOnCompletionListener { player: MediaPlayer -> onCompletion(instance, player) {} }
    return instance
  }

  override fun setVideoUri(pigeon_instance: VideoView, uri: String) {
    pigeon_instance.setVideoURI(Uri.parse(uri))
  }

  override fun getCurrentPosition(pigeon_instance: VideoView): Long {
    return pigeon_instance.currentPosition.toLong()
  }
}
