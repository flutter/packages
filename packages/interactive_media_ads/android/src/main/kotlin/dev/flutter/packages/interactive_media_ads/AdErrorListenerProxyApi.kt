package dev.flutter.packages.interactive_media_ads

import android.app.Activity
import com.google.ads.interactivemedia.v3.api.AdErrorEvent

class AdErrorListenerProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiAdErrorListener(pigeonRegistrar) {
  private class AdErrorListenerImpl(val api: AdErrorListenerProxyApi) :
      AdErrorEvent.AdErrorListener {
    override fun onAdError(event: AdErrorEvent) {
      ((api.pigeonRegistrar as ProxyApiRegistrar).context as Activity).runOnUiThread {
        api.onAdError(this, event) {}
      }
    }
  }

  override fun pigeon_defaultConstructor(): AdErrorEvent.AdErrorListener {
    return AdErrorListenerImpl(this)
  }
}
