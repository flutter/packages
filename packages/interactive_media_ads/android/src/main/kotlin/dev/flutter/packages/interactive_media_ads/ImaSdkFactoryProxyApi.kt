package dev.flutter.packages.interactive_media_ads

import android.view.ViewGroup
import com.google.ads.interactivemedia.v3.api.AdDisplayContainer
import com.google.ads.interactivemedia.v3.api.ImaSdkFactory
import com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer

class ImaSdkFactoryProxyApi(pigeonRegistrar: PigeonProxyApiRegistrar) :
    PigeonApiImaSdkFactory(pigeonRegistrar) {
  override fun createAdDisplayContainer(
      container: ViewGroup,
      player: VideoAdPlayer
  ): AdDisplayContainer {
    return ImaSdkFactory.createAdDisplayContainer(container, player)
  }
}
