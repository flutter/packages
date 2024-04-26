package dev.flutter.packages.interactive_media_ads

import android.widget.FrameLayout

class FrameLayoutProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiFrameLayout(pigeonRegistrar) {
  override fun pigeon_defaultConstructor(): FrameLayout {
    return FrameLayout((pigeonRegistrar as ProxyApiRegistrar).context)
  }
}
