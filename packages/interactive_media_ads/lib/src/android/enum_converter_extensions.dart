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
      ima.AdErrorType.load => AdErrorType.loading,
      ima.AdErrorType.play => AdErrorType.playing,
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
      ima.AdEventType.contentPauseRequested =>
        AdEventType.contentPauseRequested,
      ima.AdEventType.contentResumeRequested =>
        AdEventType.contentResumeRequested,
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
      ima.AdErrorCode.adsPlayerWasNotProvided =>
        AdErrorCode.adsPlayerNotProvided,
      ima.AdErrorCode.adsRequestNetworkError =>
        AdErrorCode.adsRequestNetworkError,
      ima.AdErrorCode.companionAdLoadingFailed =>
        AdErrorCode.companionAdLoadingFailed,
      ima.AdErrorCode.failedToRequestAds => AdErrorCode.failedToRequestAds,
      ima.AdErrorCode.internalError => AdErrorCode.internalError,
      ima.AdErrorCode.invalidArguments => AdErrorCode.invalidArguments,
      ima.AdErrorCode.overlayAdLoadingFailed =>
        AdErrorCode.overlayAdLoadingFailed,
      ima.AdErrorCode.overlayAdPlayingFailed =>
        AdErrorCode.overlayAdPlayingFailed,
      ima.AdErrorCode.playlistNoContentTracking =>
        AdErrorCode.playlistNoContentTracking,
      ima.AdErrorCode.unexpectedAdsLoadedEvent =>
        AdErrorCode.unexpectedAdsLoadedEvent,
      ima.AdErrorCode.unknownAdResponse => AdErrorCode.unknownAdResponse,
      ima.AdErrorCode.unknownError => AdErrorCode.unknownError,
      ima.AdErrorCode.vastAssetNotFound => AdErrorCode.vastAssetNotFound,
      ima.AdErrorCode.vastEmptyResponse => AdErrorCode.vastEmptyResponse,
      ima.AdErrorCode.vastLinearAssetMismatch =>
        AdErrorCode.vastLinearAssetMismatch,
      ima.AdErrorCode.vastLoadTimeout => AdErrorCode.vastLoadTimeout,
      ima.AdErrorCode.vastMalformedResponse =>
        AdErrorCode.vastMalformedResponse,
      ima.AdErrorCode.vastMediaLoadTimeout => AdErrorCode.vastMediaLoadTimeout,
      ima.AdErrorCode.vastNonlinearAssetMismatch =>
        AdErrorCode.vastNonlinearAssetMismatch,
      ima.AdErrorCode.vastNoAdsAfterWrapper =>
        AdErrorCode.vastNoAdsAfterWrapper,
      ima.AdErrorCode.vastTooManyRedirects => AdErrorCode.vastTooManyRedirects,
      ima.AdErrorCode.vastTraffickingError => AdErrorCode.vastTraffickingError,
      ima.AdErrorCode.videoPlayError => AdErrorCode.videoPlayError,
      ima.AdErrorCode.unknown => AdErrorCode.unknownError,
    };
  }
}
