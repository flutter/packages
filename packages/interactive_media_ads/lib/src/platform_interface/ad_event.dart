// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'ad_error.dart';

/// Types of events that can occur during ad playback.
enum AdEventType {
  /// Fired when an ad break in a stream ends.
  adBreakEnded,

  /// Fired when an ad break will not play back any ads.
  adBreakFetchError,

  /// Fired when an ad break is ready from VMAP or ad rule ads.
  adBreakReady,

  /// Fired when an ad break in a stream starts.
  adBreakStarted,

  /// Fired when playback stalls while the ad buffers.
  adBuffering,

  /// Fired when an ad period in a stream ends.
  adPeriodEnded,

  /// Fired when an ad period in a stream starts.
  adPeriodStarted,

  /// Fired to inform of ad progress and can be used by publisher to display a
  /// countdown timer.
  adProgress,

  /// Fired when the ads manager is done playing all the valid ads in the ads
  /// response, or when the response doesn't return any valid ads.
  allAdsCompleted,

  /// Fired when an ad is clicked.
  clicked,

  /// Fired when an ad completes playing.
  complete,

  /// Fired when content should be paused.
  ///
  /// This usually happens right before an ad is about to hide the content.
  contentPauseRequested,

  /// Fired when content should be resumed.
  ///
  /// This usually happens when an ad finishes or collapses.
  contentResumeRequested,

  /// Fired when VOD stream cuepoints have changed.
  cuepointsChanged,

  /// Fired when the ad playhead crosses first quartile.
  firstQuartile,

  /// The user has closed the icon fallback image dialog.
  iconFallbackImageClosed,

  /// The user has tapped an ad icon.
  iconTapped,

  /// Fired when the VAST response has been received.
  loaded,

  /// Fired to enable the SDK to communicate a message to be logged, which is
  /// stored in adData.
  log,

  /// Fired when the ad playhead crosses midpoint.
  midpoint,

  /// Fired when an ad is paused.
  paused,

  /// Fired when an ad is resumed.
  resumed,

  /// Fired when an ad changes its skippable state.
  skippableStateChanged,

  /// Fired when an ad was skipped.
  skipped,

  /// Fired when an ad starts playing.
  started,

  /// Stream request has loaded (only used for dynamic ad insertion).
  streamLoaded,

  /// Stream has started playing (only used for dynamic ad insertion).
  streamStarted,

  /// Fired when a non-clickthrough portion of a video ad is clicked.
  tapped,

  /// Fired when the ad playhead crosses third quartile.
  thirdQuartile,

  /// An unexpected event occurred and the type is not known.
  ///
  /// Refer to the inner error for more information.
  unknown,
}

/// Simple data class used to transport ad playback information.
@immutable
class AdEvent {
  /// Creates an [AdEvent].
  const AdEvent({required this.type, this.adData = const <String, String>{}});

  /// The type of event that occurred.
  final AdEventType type;

  /// A map containing any extra ad data for the event, if needed.
  final Map<String, String> adData;
}

/// An event raised when there is an error loading or playing ads.
@immutable
class AdErrorEvent {
  /// Creates an [AdErrorEvent].
  const AdErrorEvent({required this.error});

  /// The error that caused this event.
  final AdError error;
}
