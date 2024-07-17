// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'ad_error.dart';

/// Types of events that can occur during ad playback.
enum AdEventType {
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

  /// Fired when the VAST response has been received.
  loaded,
}

/// Simple data class used to transport ad playback information.
@immutable
class AdEvent {
  /// Creates an [AdEvent].
  const AdEvent({required this.type});

  /// The type of event that occurred.
  final AdEventType type;
}

/// An event raised when there is an error loading or playing ads.
@immutable
class AdErrorEvent {
  /// Creates an [AdErrorEvent].
  const AdErrorEvent({required this.error});

  /// The error that caused this event.
  final AdError error;
}
