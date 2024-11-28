// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger

/**
 * Implementation of [InteractiveMediaAdsLibraryPigeonProxyApiRegistrar] that provides each ProxyApi
 * implementation and any additional resources needed by an implementation.
 */
open class ProxyApiRegistrar(binaryMessenger: BinaryMessenger, var context: Context) :
    InteractiveMediaAdsLibraryPigeonProxyApiRegistrar(binaryMessenger) {

  // Added to be overriden for tests. The test implementation calls `callback` immediately, instead
  // of waiting for the main thread to run it.
  internal open fun runOnMainThread(callback: Runnable) {
    Handler(Looper.getMainLooper()).post { callback.run() }
  }

  override fun getPigeonApiBaseDisplayContainer(): PigeonApiBaseDisplayContainer {
    return BaseDisplayContainerProxyApi(this)
  }

  override fun getPigeonApiAdDisplayContainer(): PigeonApiAdDisplayContainer {
    return AdDisplayContainerProxyApi(this)
  }

  override fun getPigeonApiAdsLoader(): PigeonApiAdsLoader {
    return AdsLoaderProxyApi(this)
  }

  override fun getPigeonApiAdsManagerLoadedEvent(): PigeonApiAdsManagerLoadedEvent {
    return AdsManagerLoadedEventProxyApi(this)
  }

  override fun getPigeonApiAdsLoadedListener(): PigeonApiAdsLoadedListener {
    return AdsLoadedListenerProxyApi(this)
  }

  override fun getPigeonApiAdErrorListener(): PigeonApiAdErrorListener {
    return AdErrorListenerProxyApi(this)
  }

  override fun getPigeonApiAdErrorEvent(): PigeonApiAdErrorEvent {
    return AdErrorEventProxyApi(this)
  }

  override fun getPigeonApiAdError(): PigeonApiAdError {
    return AdErrorProxyApi(this)
  }

  override fun getPigeonApiAdsRequest(): PigeonApiAdsRequest {
    return AdsRequestProxyApi(this)
  }

  override fun getPigeonApiContentProgressProvider(): PigeonApiContentProgressProvider {
    return ContentProgressProviderProxyApi(this)
  }

  override fun getPigeonApiAdsManager(): PigeonApiAdsManager {
    return AdsManagerProxyApi(this)
  }

  override fun getPigeonApiBaseManager(): PigeonApiBaseManager {
    return BaseManagerProxyApi(this)
  }

  override fun getPigeonApiAdEventListener(): PigeonApiAdEventListener {
    return AdEventListenerProxyApi(this)
  }

  override fun getPigeonApiAdEvent(): PigeonApiAdEvent {
    return AdEventProxyApi(this)
  }

  override fun getPigeonApiImaSdkFactory(): PigeonApiImaSdkFactory {
    return ImaSdkFactoryProxyApi(this)
  }

  override fun getPigeonApiImaSdkSettings(): PigeonApiImaSdkSettings {
    return ImaSdkSettingsProxyApi(this)
  }

  override fun getPigeonApiVideoAdPlayer(): PigeonApiVideoAdPlayer {
    return VideoAdPlayerProxyApi(this)
  }

  override fun getPigeonApiVideoProgressUpdate(): PigeonApiVideoProgressUpdate {
    return VideoProgressUpdateProxyApi(this)
  }

  override fun getPigeonApiVideoAdPlayerCallback(): PigeonApiVideoAdPlayerCallback {
    return VideoAdPlayerCallbackProxyApi(this)
  }

  override fun getPigeonApiAdMediaInfo(): PigeonApiAdMediaInfo {
    return AdMediaInfoProxyApi(this)
  }

  override fun getPigeonApiAdPodInfo(): PigeonApiAdPodInfo {
    return AdPodInfoProxyApi(this)
  }

  override fun getPigeonApiFrameLayout(): PigeonApiFrameLayout {
    return FrameLayoutProxyApi(this)
  }

  override fun getPigeonApiViewGroup(): PigeonApiViewGroup {
    return ViewGroupProxyApi(this)
  }

  override fun getPigeonApiVideoView(): PigeonApiVideoView {
    return VideoViewProxyApi(this)
  }

  override fun getPigeonApiView(): PigeonApiView {
    return ViewProxyApi(this)
  }

  override fun getPigeonApiMediaPlayer(): PigeonApiMediaPlayer {
    return MediaPlayerProxyApi(this)
  }

  override fun getPigeonApiAdsRenderingSettings(): PigeonApiAdsRenderingSettings {
    return AdsRenderingSettingsProxyApi(this)
  }

  override fun getPigeonApiAdProgressInfo(): PigeonApiAdProgressInfo {
    return AdProgressInfoProxyApi(this)
  }

  override fun getPigeonApiCompanionAd(): PigeonApiCompanionAd {
    return CompanionAdProxyApi(this)
  }

  override fun getPigeonApiUniversalAdId(): PigeonApiUniversalAdId {
    return UniversalAdIdProxyApi(this)
  }

  override fun getPigeonApiAd(): PigeonApiAd {
    return AdProxyApi(this)
  }

  override fun getPigeonApiCompanionAdSlotClickListener(): PigeonApiCompanionAdSlotClickListener {
    return CompanionAdSlotClickListenerProxyApi(this)
  }

  override fun getPigeonApiCompanionAdSlot(): PigeonApiCompanionAdSlot {
    return CompanionAdSlotProxyApi(this)
  }
}
