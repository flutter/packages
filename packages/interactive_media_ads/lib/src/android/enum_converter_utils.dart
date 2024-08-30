// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../platform_interface/platform_interface.dart';
import 'interactive_media_ads.g.dart' as ima;

/// Converts [ima.AdErrorType] to [AdErrorType].
AdErrorType toInterfaceErrorType(ima.AdErrorType type) {
  return switch (type) {
    ima.AdErrorType.load => AdErrorType.loading,
    ima.AdErrorType.play => AdErrorType.playing,
    ima.AdErrorType.unknown => AdErrorType.unknown,
  };
}

/// Attempts to convert an [ima.AdEventType] to [AdEventType].
///
/// Returns null is the type is not supported by the platform interface.
AdEventType toInterfaceEventType(ima.AdEventType type) {
  return switch (type) {
    ima.AdEventType.allAdsCompleted => AdEventType.allAdsCompleted,
    ima.AdEventType.completed => AdEventType.complete,
    ima.AdEventType.contentPauseRequested => AdEventType.contentPauseRequested,
    ima.AdEventType.contentResumeRequested =>
      AdEventType.contentResumeRequested,
    ima.AdEventType.loaded => AdEventType.loaded,
    ima.AdEventType.clicked => AdEventType.clicked,
    ima.AdEventType.adBreakEnded => AdEventType.adBreakEnded,
    ima.AdEventType.adBreakFetchError => AdEventType.adBreakFetchError,
    ima.AdEventType.adBreakReady => AdEventType.adBreakReady,
    ima.AdEventType.adBreakStarted => AdEventType.adBreakStarted,
    ima.AdEventType.adBuffering => AdEventType.adBuffering,
    ima.AdEventType.adPeriodEnded => AdEventType.adPeriodEnded,
    ima.AdEventType.adPeriodStarted => AdEventType.adPeriodStarted,
    ima.AdEventType.adProgress => AdEventType.adProgress,
    ima.AdEventType.cuepointsChanged => AdEventType.cuepointsChanged,
    ima.AdEventType.firstQuartile => AdEventType.firstQuartile,
    ima.AdEventType.iconFallbackImageClosed =>
      AdEventType.iconFallbackImageClosed,
    ima.AdEventType.iconTapped => AdEventType.iconTapped,
    ima.AdEventType.log => AdEventType.log,
    ima.AdEventType.midpoint => AdEventType.midpoint,
    ima.AdEventType.paused => AdEventType.paused,
    ima.AdEventType.resumed => AdEventType.resumed,
    ima.AdEventType.skippableStateChanged => AdEventType.skippableStateChanged,
    ima.AdEventType.skipped => AdEventType.skipped,
    ima.AdEventType.started => AdEventType.started,
    ima.AdEventType.tapped => AdEventType.tapped,
    ima.AdEventType.thirdQuartile => AdEventType.thirdQuartile,
    ima.AdEventType.unknown => AdEventType.unknown,
  };
}

/// Converts [ima.AdErrorCode] to [AdErrorCode].
AdErrorCode toInterfaceErrorCode(ima.AdErrorCode code) {
  return switch (code) {
    ima.AdErrorCode.adsPlayerWasNotProvided => AdErrorCode.adsPlayerNotProvided,
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
    ima.AdErrorCode.vastMalformedResponse => AdErrorCode.vastMalformedResponse,
    ima.AdErrorCode.vastMediaLoadTimeout => AdErrorCode.vastMediaLoadTimeout,
    ima.AdErrorCode.vastNonlinearAssetMismatch =>
      AdErrorCode.vastNonlinearAssetMismatch,
    ima.AdErrorCode.vastNoAdsAfterWrapper => AdErrorCode.vastNoAdsAfterWrapper,
    ima.AdErrorCode.vastTooManyRedirects => AdErrorCode.vastTooManyRedirects,
    ima.AdErrorCode.vastTraffickingError => AdErrorCode.vastTraffickingError,
    ima.AdErrorCode.videoPlayError => AdErrorCode.videoPlayError,
    ima.AdErrorCode.unknown => AdErrorCode.unknownError,
  };
}
