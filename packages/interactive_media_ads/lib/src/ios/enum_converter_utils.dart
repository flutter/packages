// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../platform_interface/platform_interface.dart';
import 'interactive_media_ads.g.dart' as ima;

/// Converts [ima.AdErrorType] to [AdErrorType].
AdErrorType toInterfaceErrorType(ima.AdErrorType type) {
  return switch (type) {
    ima.AdErrorType.loadingFailed => AdErrorType.loading,
    ima.AdErrorType.adPlayingFailed => AdErrorType.playing,
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
    ima.AdEventType.loaded => AdEventType.loaded,
    ima.AdEventType.clicked => AdEventType.clicked,
    ima.AdEventType.adBreakEnded => AdEventType.adBreakEnded,
    ima.AdEventType.adBreakFetchError => AdEventType.adBreakFetchError,
    ima.AdEventType.adBreakReady => AdEventType.adBreakReady,
    ima.AdEventType.adBreakStarted => AdEventType.adBreakStarted,
    ima.AdEventType.adPeriodEnded => AdEventType.adPeriodEnded,
    ima.AdEventType.adPeriodStarted => AdEventType.adPeriodStarted,
    ima.AdEventType.cuepointsChanged => AdEventType.cuepointsChanged,
    ima.AdEventType.firstQuartile => AdEventType.firstQuartile,
    ima.AdEventType.iconFallbackImageClosed =>
      AdEventType.iconFallbackImageClosed,
    ima.AdEventType.iconTapped => AdEventType.iconTapped,
    ima.AdEventType.log => AdEventType.log,
    ima.AdEventType.midpoint => AdEventType.midpoint,
    ima.AdEventType.pause => AdEventType.paused,
    ima.AdEventType.resume => AdEventType.resumed,
    ima.AdEventType.skipped => AdEventType.skipped,
    ima.AdEventType.started => AdEventType.started,
    ima.AdEventType.streamLoaded => AdEventType.streamLoaded,
    ima.AdEventType.streamStarted => AdEventType.streamStarted,
    ima.AdEventType.tapped => AdEventType.tapped,
    ima.AdEventType.thirdQuartile => AdEventType.thirdQuartile,
    ima.AdEventType.unknown => AdEventType.unknown,
  };
}

/// Converts [ima.AdErrorCode] to [AdErrorCode].
AdErrorCode toInterfaceErrorCode(ima.AdErrorCode code) {
  return switch (code) {
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
    ima.AdErrorCode.vastMalformedResponse => AdErrorCode.vastMalformedResponse,
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
