// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.player.ContentProgressProvider

/**
 * ProxyApi implementation for [AdsRequest].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdsRequestProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdsRequest(pigeonRegistrar) {
  companion object {
    /**
     * The current version of the `interactive_media_ads` plugin.
     *
     * This must match the version in pubspec.yaml.
     */
    const val pluginVersion = "0.1.2+2"
  }

  override fun setAdTagUrl(pigeon_instance: AdsRequest, adTagUrl: String) {
    // Ensure adTag can append a custom parameter.
    require(adTagUrl.contains("?"))
    require(!adTagUrl.contains("#"))

    pigeon_instance.adTagUrl = "$adTagUrl&request_agent=Flutter-IMA-$pluginVersion"
  }

  override fun setContentProgressProvider(
      pigeon_instance: AdsRequest,
      provider: ContentProgressProvider
  ) {
    pigeon_instance.contentProgressProvider = provider
  }

  override fun getAdTagUrl(pigeon_instance: AdsRequest): String {
    return pigeon_instance.adTagUrl
  }

  override fun getContentProgressProvider(pigeon_instance: AdsRequest): ContentProgressProvider {
    return pigeon_instance.contentProgressProvider
  }

  override fun setAdWillAutoPlay(pigeon_instance: AdsRequest, willAutoPlay: Boolean) {
    pigeon_instance.setAdWillAutoPlay(willAutoPlay)
  }

  override fun setAdWillPlayMuted(pigeon_instance: AdsRequest, willPlayMuted: Boolean) {
    pigeon_instance.setAdWillPlayMuted(willPlayMuted)
  }

  override fun setAdsResponse(pigeon_instance: AdsRequest, cannedAdResponse: String) {
    pigeon_instance.adsResponse = cannedAdResponse
  }

  override fun setContentDuration(pigeon_instance: AdsRequest, duration: Double) {
    pigeon_instance.setContentDuration(duration.toFloat())
  }

  override fun setContentKeywords(pigeon_instance: AdsRequest, keywords: List<String>) {
    pigeon_instance.setContentKeywords(keywords)
  }

  override fun setContentTitle(pigeon_instance: AdsRequest, title: String) {
    pigeon_instance.setContentTitle(title)
  }

  override fun setContinuousPlayback(pigeon_instance: AdsRequest, continuousPlayback: Boolean) {
    pigeon_instance.setContinuousPlayback(continuousPlayback)
  }

  override fun setLiveStreamPrefetchSeconds(pigeon_instance: AdsRequest, prefetchTime: Double) {
    pigeon_instance.setLiveStreamPrefetchSeconds(prefetchTime.toFloat())
  }

  override fun setVastLoadTimeout(pigeon_instance: AdsRequest, timeout: Double) {
    pigeon_instance.setVastLoadTimeout(timeout.toFloat())
  }
}
