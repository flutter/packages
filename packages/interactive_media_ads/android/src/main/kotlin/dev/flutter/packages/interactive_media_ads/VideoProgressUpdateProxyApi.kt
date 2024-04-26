package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.player.VideoProgressUpdate

class VideoProgressUpdateProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiVideoProgressUpdate(pigeonRegistrar) {
  override fun pigeon_defaultConstructor(
      currentTimeMs: Long,
      durationMs: Long
  ): VideoProgressUpdate {
    return VideoProgressUpdate(currentTimeMs, durationMs)
  }

  override fun videoTimeNotReady(): VideoProgressUpdate {
    return VideoProgressUpdate.VIDEO_TIME_NOT_READY
  }
}
