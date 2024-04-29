package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsLoader
import com.google.ads.interactivemedia.v3.api.AdsManagerLoadedEvent

class AdsLoadedListenerProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiAdsLoadedListener(pigeonRegistrar) {
  private class AdsLoadedListenerImpl(val api: AdsLoadedListenerProxyApi) :
      AdsLoader.AdsLoadedListener {
    override fun onAdsManagerLoaded(event: AdsManagerLoadedEvent) {
      api.onAdsManagerLoaded(this, event) {}
    }
  }

  override fun pigeon_defaultConstructor(): AdsLoader.AdsLoadedListener {
    return AdsLoadedListenerImpl(this)
  }
}
