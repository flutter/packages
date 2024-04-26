// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger

class ProxyApiRegistrar(binaryMessenger: BinaryMessenger, var context: Context) :
    PigeonProxyApiRegistrar(binaryMessenger) {
  override fun getPigeonApiBaseDisplayContainer(): PigeonApiBaseDisplayContainer {
    return BaseDisplayContainerProxyApi(this)
  }

  override fun getPigeonApiAdDisplayContainer(): PigeonApiAdDisplayContainer {
    return AdDisplayContainerProxyApi(this)
  }

  override fun getPigeonApiAdsLoader(): PigeonApiAdsLoader {
    return AdsLoaderProxyApi(this)
  }

  override fun getPigeonApiAdsRequest(): PigeonApiAdsRequest {
    return AdsRequestProxyApi(this)
  }

  override fun getPigeonApiAdsManager(): PigeonApiAdsManager {
    return AdsManagerProxyApi(this)
  }

  override fun getPigeonApiImaSdkFactory(): PigeonApiImaSdkFactory {
    return ImaSdkFactoryProxyApi(this)
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
}
