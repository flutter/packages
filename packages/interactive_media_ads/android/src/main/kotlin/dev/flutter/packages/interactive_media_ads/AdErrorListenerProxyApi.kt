package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdErrorEvent

class AdErrorListenerProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiAdErrorListener(pigeonRegistrar) {
  private class AdErrorListenerImpl(val api: AdErrorListenerProxyApi) :
      AdErrorEvent.AdErrorListener {
    override fun onAdError(event: AdErrorEvent) {
      api.onAdError(this, event) {}
    }
  }

  override fun pigeon_defaultConstructor(): AdErrorEvent.AdErrorListener {
    return AdErrorListenerImpl(this)
  }
}
