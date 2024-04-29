package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdError
import com.google.ads.interactivemedia.v3.api.AdErrorEvent

class AdErrorEventProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiAdErrorEvent(pigeonRegistrar) {
  override fun error(pigeon_instance: AdErrorEvent): AdError {
    return pigeon_instance.error
  }
}
