// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.View
import android.view.ViewGroup
import com.google.ads.interactivemedia.v3.api.AdDisplayContainer
import com.google.ads.interactivemedia.v3.api.AdsLoader
import com.google.ads.interactivemedia.v3.api.AdsRenderingSettings
import com.google.ads.interactivemedia.v3.api.AdsRequest
import com.google.ads.interactivemedia.v3.api.CompanionAdSlot
import com.google.ads.interactivemedia.v3.api.FriendlyObstructionPurpose
import com.google.ads.interactivemedia.v3.api.ImaSdkFactory
import com.google.ads.interactivemedia.v3.api.ImaSdkSettings
import com.google.ads.interactivemedia.v3.api.StreamDisplayContainer
import com.google.ads.interactivemedia.v3.api.StreamRequest
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

  override fun createStreamAdsLoader(
      pigeon_instance: ImaSdkFactory,
      settings: ImaSdkSettings,
      container: StreamDisplayContainer
  ): AdsLoader {
    return pigeon_instance.createAdsLoader(pigeonRegistrar.context, settings, container)
  }

  override fun createAdsRenderingSettings(pigeon_instance: ImaSdkFactory): AdsRenderingSettings {
    return pigeon_instance.createAdsRenderingSettings()
  }

  override fun createAudioAdDisplayContainer(player: VideoAdPlayer): AdDisplayContainer {
    return ImaSdkFactory.createAudioAdDisplayContainer(pigeonRegistrar.context, player)
  }

  override fun createCompanionAdSlot(pigeon_instance: ImaSdkFactory): CompanionAdSlot {
    return pigeon_instance.createCompanionAdSlot()
  }

  override fun createFriendlyObstruction(
      pigeon_instance: ImaSdkFactory,
      view: View,
      purpose: dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose,
      detailedReason: String?
  ): com.google.ads.interactivemedia.v3.api.FriendlyObstruction {
    val nativePurpose =
        when (purpose) {
          dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.CLOSE_AD ->
              FriendlyObstructionPurpose.CLOSE_AD
          dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.NOT_VISIBLE ->
              FriendlyObstructionPurpose.NOT_VISIBLE
          dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.OTHER ->
              FriendlyObstructionPurpose.OTHER
          dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.VIDEO_CONTROLS ->
              FriendlyObstructionPurpose.VIDEO_CONTROLS
          dev.flutter.packages.interactive_media_ads.FriendlyObstructionPurpose.UNKNOWN ->
              throw UnsupportedOperationException("$purpose is not supported")
        }
    return pigeon_instance.createFriendlyObstruction(view, nativePurpose, detailedReason)
  }

  override fun createLiveStreamRequest(
      pigeon_instance: ImaSdkFactory,
      assetKey: String,
      apiKey: String
  ): StreamRequest {
    return pigeon_instance.createLiveStreamRequest(assetKey, apiKey)
  }

  override fun createPodStreamRequest(
      pigeon_instance: ImaSdkFactory,
      networkCode: String,
      customAssetKey: String,
      apiKey: String
  ): StreamRequest {
    return pigeon_instance.createPodStreamRequest(networkCode, customAssetKey, apiKey)
  }

  override fun createPodVodStreamRequest(
      pigeon_instance: ImaSdkFactory,
      networkCode: String
  ): StreamRequest {
    return pigeon_instance.createPodVodStreamRequest(networkCode)
  }

  override fun createStreamDisplayContainer(
      container: ViewGroup,
      player: com.google.ads.interactivemedia.v3.api.player.VideoStreamPlayer
  ): com.google.ads.interactivemedia.v3.api.StreamDisplayContainer {
    return ImaSdkFactory.createStreamDisplayContainer(container, player)
  }

  override fun createVideoStitcherLiveStreamRequest(
      pigeon_instance: ImaSdkFactory,
      networkCode: String,
      customAssetKey: String,
      liveStreamEventId: String,
      region: String,
      projectNumber: String,
      oAuthToken: String
  ): StreamRequest {
    return pigeon_instance.createVideoStitcherLiveStreamRequest(
        networkCode, customAssetKey, liveStreamEventId, region, projectNumber, oAuthToken)
  }

  override fun createContentSourceVideoStitcherVodStreamRequest(
      pigeon_instance: ImaSdkFactory,
      contentSourceUrl: String,
      networkCode: String,
      region: String,
      projectNumber: String,
      oAuthToken: String,
      adTagUrl: String
  ): StreamRequest {
    return pigeon_instance.createVideoStitcherVodStreamRequest(
        contentSourceUrl, networkCode, region, projectNumber, oAuthToken, adTagUrl)
  }

  override fun createVideoStitcherVodStreamRequest(
      pigeon_instance: ImaSdkFactory,
      networkCode: String,
      region: String,
      projectNumber: String,
      oAuthToken: String,
      vodConfigId: String
  ): StreamRequest {
    return pigeon_instance.createVideoStitcherVodStreamRequest(
        networkCode, region, projectNumber, oAuthToken, vodConfigId)
  }

  override fun createVodStreamRequest(
      pigeon_instance: ImaSdkFactory,
      contentSourceId: String,
      videoId: String,
      apiKey: String
  ): StreamRequest {
    return pigeon_instance.createVodStreamRequest(contentSourceId, videoId, apiKey)
  }
}
