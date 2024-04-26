package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer
import com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate

class VideoAdPlayerProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiVideoAdPlayer(pigeonRegistrar) {
  override fun setVolume(pigeon_instance: VideoAdPlayer, value: Long) {
    TODO("Not yet implemented")
  }

  override fun setAdProgress(pigeon_instance: VideoAdPlayer, progress: VideoProgressUpdate) {
    TODO("Not yet implemented")
  }
}
