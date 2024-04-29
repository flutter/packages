package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdEvent

class AdEventProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiAdEvent(pigeonRegistrar) {
  override fun type(pigeon_instance: AdEvent): AdEventType {
    when (pigeon_instance.type) {
      AdEvent.AdEventType.ALL_ADS_COMPLETED -> AdEventType.ALL_ADS_COMPLETED
      AdEvent.AdEventType.COMPLETED -> AdEventType.COMPLETED
      AdEvent.AdEventType.CONTENT_PAUSE_REQUESTED -> AdEventType.CONTENT_PAUSE_REQUESTED
      AdEvent.AdEventType.CONTENT_RESUME_REQUESTED -> AdEventType.CONTENT_RESUME_REQUESTED
      AdEvent.AdEventType.AD_BREAK_READY -> AdEventType.AD_BREAK_READY
      AdEvent.AdEventType.LOADED -> AdEventType.LOADED
      else -> AdEventType.UNKNOWN
    }

    return AdEventType.UNKNOWN
  }
}
