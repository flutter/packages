// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.AdError

/**
 * ProxyApi implementation for [AdError].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class AdErrorProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiAdError(pigeonRegistrar) {
  override fun errorCode(pigeon_instance: AdError): AdErrorCode {
    return when (pigeon_instance.errorCode) {
      AdError.AdErrorCode.ADS_PLAYER_NOT_PROVIDED -> AdErrorCode.ADS_PLAYER_WAS_NOT_PROVIDED
      AdError.AdErrorCode.INTERNAL_ERROR -> AdErrorCode.INTERNAL_ERROR
      AdError.AdErrorCode.VAST_MALFORMED_RESPONSE -> AdErrorCode.VAST_MALFORMED_RESPONSE
      AdError.AdErrorCode.UNKNOWN_AD_RESPONSE -> AdErrorCode.UNKNOWN_AD_RESPONSE
      AdError.AdErrorCode.VAST_TRAFFICKING_ERROR -> AdErrorCode.VAST_TRAFFICKING_ERROR
      AdError.AdErrorCode.VAST_LOAD_TIMEOUT -> AdErrorCode.VAST_LOAD_TIMEOUT
      AdError.AdErrorCode.VAST_TOO_MANY_REDIRECTS -> AdErrorCode.VAST_TOO_MANY_REDIRECTS
      AdError.AdErrorCode.VAST_NO_ADS_AFTER_WRAPPER -> AdErrorCode.VAST_NO_ADS_AFTER_WRAPPER
      AdError.AdErrorCode.VIDEO_PLAY_ERROR -> AdErrorCode.VIDEO_PLAY_ERROR
      AdError.AdErrorCode.VAST_MEDIA_LOAD_TIMEOUT -> AdErrorCode.VAST_MEDIA_LOAD_TIMEOUT
      AdError.AdErrorCode.VAST_LINEAR_ASSET_MISMATCH -> AdErrorCode.VAST_LINEAR_ASSET_MISMATCH
      AdError.AdErrorCode.OVERLAY_AD_PLAYING_FAILED -> AdErrorCode.OVERLAY_AD_PLAYING_FAILED
      AdError.AdErrorCode.OVERLAY_AD_LOADING_FAILED -> AdErrorCode.OVERLAY_AD_LOADING_FAILED
      AdError.AdErrorCode.VAST_NONLINEAR_ASSET_MISMATCH -> AdErrorCode.VAST_NONLINEAR_ASSET_MISMATCH
      AdError.AdErrorCode.COMPANION_AD_LOADING_FAILED -> AdErrorCode.COMPANION_AD_LOADING_FAILED
      AdError.AdErrorCode.UNKNOWN_ERROR -> AdErrorCode.UNKNOWN_ERROR
      AdError.AdErrorCode.VAST_EMPTY_RESPONSE -> AdErrorCode.VAST_EMPTY_RESPONSE
      AdError.AdErrorCode.FAILED_TO_REQUEST_ADS -> AdErrorCode.FAILED_TO_REQUEST_ADS
      AdError.AdErrorCode.VAST_ASSET_NOT_FOUND -> AdErrorCode.VAST_ASSET_NOT_FOUND
      AdError.AdErrorCode.ADS_REQUEST_NETWORK_ERROR -> AdErrorCode.ADS_REQUEST_NETWORK_ERROR
      AdError.AdErrorCode.INVALID_ARGUMENTS -> AdErrorCode.INVALID_ARGUMENTS
      AdError.AdErrorCode.PLAYLIST_NO_CONTENT_TRACKING -> AdErrorCode.PLAYLIST_NO_CONTENT_TRACKING
      AdError.AdErrorCode.UNEXPECTED_ADS_LOADED_EVENT -> AdErrorCode.UNEXPECTED_ADS_LOADED_EVENT
      else -> AdErrorCode.UNKNOWN
    }
  }

  override fun errorCodeNumber(pigeon_instance: AdError): Long {
    return pigeon_instance.errorCodeNumber.toLong()
  }

  override fun errorType(pigeon_instance: AdError): AdErrorType {
    return when (pigeon_instance.errorType) {
      AdError.AdErrorType.LOAD -> AdErrorType.LOAD
      AdError.AdErrorType.PLAY -> AdErrorType.PLAY
      else -> AdErrorType.UNKNOWN
    }
  }

  override fun message(pigeon_instance: AdError): String {
    return pigeon_instance.message
  }
}
