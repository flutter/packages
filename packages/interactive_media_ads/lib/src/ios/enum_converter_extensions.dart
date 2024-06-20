// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../platform_interface/platform_interface.dart';
import 'interactive_media_ads.g.dart' as ima;

/// Adds a method to convert native AdErrorType to platform interface
/// AdErrorType.
extension NativeAdErrorTypeConverter on ima.AdErrorType {
  /// Converts [ima.AdErrorType] to [AdErrorType].
  AdErrorType asInterfaceErrorType() {
    return switch (this) {
      ima.AdErrorType.loadingFailed => AdErrorType.loading,
      ima.AdErrorType.adPlayingFailed => AdErrorType.playing,
      ima.AdErrorType.unknown => AdErrorType.unknown,
    };
  }
}

/// Adds a method to convert native AdEventType to platform interface
/// AdEventType.
extension NativeAdEventTypeConverter on ima.AdEventType {
  /// Attempts to convert an [ima.AdEventType] to [AdEventType].
  ///
  /// Returns null is the type is not supported by the platform interface.
  AdEventType? asInterfaceAdEventType() {
    return switch (this) {
      ima.AdEventType.allAdsCompleted => AdEventType.allAdsCompleted,
      ima.AdEventType.completed => AdEventType.complete,
      ima.AdEventType.loaded => AdEventType.loaded,
      ima.AdEventType.clicked => AdEventType.clicked,
      _ => null,
    };
  }
}

/// Adds a method to convert native AdErrorCode to platform interface
/// AdErrorCode.
extension NativeAdErrorCodeConverter on ima.AdErrorCode {
  /// Converts [ima.AdErrorCode] to [AdErrorCode].
  AdErrorCode asInterfaceErrorCode() {
    return switch (this) {
      ima.AdErrorCode.companionAdLoadingFailed =>
        AdErrorCode.companionAdLoadingFailed,
      ima.AdErrorCode.failedToRequestAds => AdErrorCode.failedToRequestAds,
      ima.AdErrorCode.invalidArguments => AdErrorCode.invalidArguments,
      ima.AdErrorCode.unknownError => AdErrorCode.unknownError,
      ima.AdErrorCode.vastAssetNotFound => AdErrorCode.vastAssetNotFound,
      ima.AdErrorCode.vastEmptyResponse => AdErrorCode.vastEmptyResponse,
      ima.AdErrorCode.vastLinearAssetMismatch =>
        AdErrorCode.vastLinearAssetMismatch,
      ima.AdErrorCode.vastLoadTimeout => AdErrorCode.vastLoadTimeout,
      ima.AdErrorCode.vastMalformedResponse =>
        AdErrorCode.vastMalformedResponse,
      ima.AdErrorCode.vastMediaLoadTimeout => AdErrorCode.vastMediaLoadTimeout,
      ima.AdErrorCode.vastTooManyRedirects => AdErrorCode.vastTooManyRedirects,
      ima.AdErrorCode.vastTraffickingError => AdErrorCode.vastTraffickingError,
      ima.AdErrorCode.videoPlayError => AdErrorCode.videoPlayError,
      ima.AdErrorCode.adslotNotVisible => AdErrorCode.adslotNotVisible,
      ima.AdErrorCode.apiError => AdErrorCode.apiError,
      ima.AdErrorCode.contentPlayheadMissing =>
        AdErrorCode.contentPlayheadMissing,
      ima.AdErrorCode.failedLoadingAd => AdErrorCode.failedLoadingAd,
      ima.AdErrorCode.osRuntimeTooOld => AdErrorCode.osRuntimeTooOld,
      ima.AdErrorCode.playlistMalformedResponse =>
        AdErrorCode.playlistMalformedResponse,
      ima.AdErrorCode.requiredListenersNotAdded =>
        AdErrorCode.requiredListenersNotAdded,
      ima.AdErrorCode.streamInitializationFailed =>
        AdErrorCode.streamInitializationFailed,
      ima.AdErrorCode.vastInvalidUrl => AdErrorCode.vastInvalidUrl,
      ima.AdErrorCode.videoElementUsed => AdErrorCode.videoElementUsed,
      ima.AdErrorCode.videoElementRequired => AdErrorCode.videoElementRequired,
    };
  }
}
