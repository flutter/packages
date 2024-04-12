// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// The types of errors that can be encountered when loading an ad.
enum AdErrorCode {
  /// Generic invalid usage of the API.
  apiError,

  /// Ads player was not provided.
  adsPlayerNotProvided,

  /// There was a problem requesting ads from the server.
  adsRequestNetworkError,

  /// The ad slot is not visible on the page.
  adslotNotVisible,

  /// There was a problem requesting ads from the server.
  companionAdLoadingFailed,

  /// Content playhead was not passed in, but list of ads has been returned from
  /// the server.
  contentPlayheadMissing,

  /// There was a problem requesting ads from the server.
  failedToRequestAds,

  /// There was an error loading the ad.
  failedLoadingAd,

  /// An error internal to the SDK occurred.
  ///
  /// More information may be available in the details.
  internalError,

  /// Invalid arguments were provided to SDK methods.
  invalidArguments,

  /// The version of the runtime is too old.
  osRuntimeTooOld,

  /// An overlay ad failed to load.
  overlayAdLoadingFailed,

  /// An overlay ad failed to render.
  overlayAdPlayingFailed,

  /// Ads list was returned but ContentProgressProvider was not configured.
  playlistNoContentTracking,

  /// Ads list response was malformed.
  playlistMalformedResponse,

  /// Listener for at least one of the required vast events was not added.
  requiredListenersNotAdded,

  /// There was an error initializing the stream.
  streamInitializationFailed,

  /// Ads loader sent ads loaded event when it was not expected.
  unexpectedAdsLoadedEvent,

  /// The ad response was not understood and cannot be parsed.
  unknownAdResponse,

  /// An unexpected error occurred and the cause is not known.
  ///
  /// Refer to the inner error for more information.
  unknownError,

  /// No assets were found in the VAST ad response.
  vastAssetNotFound,

  /// A VAST response containing a single <VAST> tag with no child tags.
  vastEmptyResponse,

  /// Assets were found in the VAST ad response for a linear ad, but none of
  /// them matched the video player's capabilities.
  vastLinearAssetMismatch,

  /// At least one VAST wrapper ad loaded successfully and a subsequent wrapper
  /// or inline ad load has timed out.
  vastLoadTimeout,

  /// The ad response was not recognized as a valid VAST ad.
  vastMalformedResponse,

  /// Failed to load media assets from a VAST response.
  ///
  /// The default timeout for media loading is 8 seconds.
  vastMediaLoadTimeout,

  /// Assets were found in the VAST ad response for a nonlinear ad, but none of
  /// them matched the video player's capabilities.
  vastNonlinearAssetMismatch,

  /// No Ads VAST response after one or more wrappers.
  vastNoAdsAfterWrapper,

  /// The maximum number of VAST wrapper redirects has been reached.
  vastTooManyRedirects,

  /// Trafficking error.
  ///
  /// Video player received an ad type that it was not expecting and/or cannot
  /// display.
  vastTraffickingError,

  /// At least one VAST wrapper loaded and a subsequent wrapper or inline ad
  /// load has resulted in a 404 response code.
  vastInvalidUrl,

  /// There was an error playing the video ad.
  videoPlayError,

  /// Another VideoAdsManager is still using the video.
  ///
  /// It must be unloaded before another ad can play on the same element.
  videoElementUsed,

  /// A video element was not specified where it was required.
  videoElementRequired,
}

/// Possible error types while loading or playing ads.
enum AdErrorType {
  /// Indicates an error occurred while loading the ads.
  loading,

  /// Indicates an error occurred while playing the ads.
  playing,

  /// An unexpected error occurred while loading or playing the ads.
  ///
  /// This may mean that the SDK wasn’t loaded properly.
  unknown,
}

/// Surfaces an error that occurred during ad loading or playing.
@immutable
class AdError {
  /// Creates a [AdError].
  const AdError({required this.type, required this.code, this.message});

  /// Specifies the source of the error.
  final AdErrorType type;

  /// The error code for obtaining more specific information about the error.
  final AdErrorCode code;

  /// A brief description about the error.
  final String? message;
}
