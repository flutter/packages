package dev.flutter.packages.interactive_media_ads

import android.app.Activity
import com.google.ads.interactivemedia.v3.api.AdEvent

class AdEventListenerProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiAdEventListener(pigeonRegistrar) {
  private class AdEventListenerImpl(val api: AdEventListenerProxyApi) : AdEvent.AdEventListener {
    override fun onAdEvent(event: AdEvent) {
      ((api.pigeonRegistrar as ProxyApiRegistrar).context as Activity).runOnUiThread {
        api.onAdEvent(this, event) {}
      }
    }
  }

  override fun pigeon_defaultConstructor(): AdEvent.AdEventListener {
    return AdEventListenerImpl(this)
  }
}
