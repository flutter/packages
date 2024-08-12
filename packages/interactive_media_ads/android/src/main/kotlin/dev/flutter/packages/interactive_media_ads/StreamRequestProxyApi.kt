// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.StreamRequest

/**
 * ProxyApi implementation for [StreamRequest].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class StreamRequestProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiStreamRequest(pigeonRegistrar) {

  override fun getAdTagParameters(pigeon_instance: StreamRequest): Map<String, String>? {
    return pigeon_instance.adTagParameters
  }

  override fun getAdTagUrl(pigeon_instance: StreamRequest): String? {
    return pigeon_instance.adTagUrl
  }

  override fun getApiKey(pigeon_instance: StreamRequest): String {
    return pigeon_instance.apiKey
  }

  override fun getAssetKey(pigeon_instance: StreamRequest): String? {
    return pigeon_instance.assetKey
  }

  override fun getAuthToken(pigeon_instance: StreamRequest): String {
    return pigeon_instance.authToken
  }

  override fun getContentSourceId(pigeon_instance: StreamRequest): String? {
    return pigeon_instance.contentSourceId
  }

  override fun getContentSourceUrl(pigeon_instance: StreamRequest): String? {
    return pigeon_instance.contentSourceUrl
  }

  override fun getCustomAssetKey(pigeon_instance: StreamRequest): String? {
    return pigeon_instance.customAssetKey
  }

  override fun getFormat(pigeon_instance: StreamRequest): StreamFormat {
    return when (pigeon_instance.format) {
      StreamRequest.StreamFormat.DASH -> StreamFormat.DASH
      StreamRequest.StreamFormat.HLS -> StreamFormat.HLS
      else -> StreamFormat.UNKNOWN
    }
  }

  override fun getManifestSuffix(pigeon_instance: StreamRequest): String {
    return pigeon_instance.manifestSuffix
  }

  override fun getNetworkCode(pigeon_instance: StreamRequest): String? {
    return pigeon_instance.networkCode
  }

  override fun getVideoId(pigeon_instance: StreamRequest): String? {
    return pigeon_instance.videoId
  }

  override fun getVideoStitcherSessionOptions(pigeon_instance: StreamRequest): Map<String, Any>? {
    return pigeon_instance.videoStitcherSessionOptions
  }

  override fun getVodConfigId(pigeon_instance: StreamRequest): String? {
    return pigeon_instance.vodConfigId
  }

  override fun setAdTagParameters(
      pigeon_instance: StreamRequest,
      adTagParameters: Map<String, String>
  ) {
    return pigeon_instance.setAdTagParameters(adTagParameters)
  }

  override fun setAuthToken(pigeon_instance: StreamRequest, authToken: String) {
    return pigeon_instance.setAuthToken(authToken)
  }

  override fun setFormat(pigeon_instance: StreamRequest, format: StreamFormat) {
    return pigeon_instance.setFormat(
        when (format) {
          StreamFormat.DASH -> StreamRequest.StreamFormat.DASH
          StreamFormat.HLS -> StreamRequest.StreamFormat.HLS
          StreamFormat.UNKNOWN -> throw UnsupportedOperationException()
        })
  }

  override fun setManifestSuffix(pigeon_instance: StreamRequest, manifestSuffix: String) {
    return pigeon_instance.setManifestSuffix(manifestSuffix)
  }

  override fun setStreamActivityMonitorId(
      pigeon_instance: StreamRequest,
      streamActivityMonitorId: String
  ) {
    return pigeon_instance.setStreamActivityMonitorId(streamActivityMonitorId)
  }

  override fun setVideoStitcherSessionOptions(
      pigeon_instance: StreamRequest,
      videoStitcherSessionOptions: Map<String, Any>
  ) {
    return pigeon_instance.setVideoStitcherSessionOptions(videoStitcherSessionOptions)
  }
}
