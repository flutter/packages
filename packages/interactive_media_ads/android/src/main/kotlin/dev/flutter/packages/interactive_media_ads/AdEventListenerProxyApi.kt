package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdEvent

class AdEventListenerProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiAdEventListener(pigeonRegistrar) {
  private class AdEventListenerImpl(val api: AdEventListenerProxyApi) : AdEvent.AdEventListener {
    override fun onAdEvent(event: AdEvent) {
      api.onAdEvent(this, event) {}
    }
  }

  override fun pigeon_defaultConstructor(): AdEvent.AdEventListener {
    return AdEventListenerImpl(this)
  }
}
