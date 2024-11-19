// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.ViewGroup
import com.google.ads.interactivemedia.v3.api.AdDisplayContainer
import com.google.ads.interactivemedia.v3.api.AdsLoader
import com.google.ads.interactivemedia.v3.api.AdsRenderingSettings
import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.ImaSdkFactory
import com.google.ads.interactivemedia.v3.api.ImaSdkSettings
import com.google.ads.interactivemedia.v3.api.player.VideoAdPlayer

/**
 * ProxyApi implementation for [ImaSdkFactory].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class ImaSdkFactoryProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiImaSdkFactory(pigeonRegistrar) {
  override fun instance(): ImaSdkFactory {
    return ImaSdkFactory.getInstance()
  }

  override fun createAdDisplayContainer(
      container: ViewGroup,
      player: VideoAdPlayer
  ): AdDisplayContainer {
    return ImaSdkFactory.createAdDisplayContainer(container, player)
  }

  override fun createImaSdkSettings(pigeon_instance: ImaSdkFactory): ImaSdkSettings {
    return pigeon_instance.createImaSdkSettings()
  }

  override fun createAdsLoader(
      pigeon_instance: ImaSdkFactory,
      settings: ImaSdkSettings,
      container: AdDisplayContainer
  ): AdsLoader {
    return pigeon_instance.createAdsLoader(pigeonRegistrar.context, settings, container)
  }

  override fun createAdsRequest(pigeon_instance: ImaSdkFactory): AdsRequest {
    return pigeon_instance.createAdsRequest()
  }

  override fun createAdsRenderingSettings(pigeon_instance: ImaSdkFactory): AdsRenderingSettings {
    return pigeon_instance.createAdsRenderingSettings()
  }
}
