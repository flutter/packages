// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'ad_event.dart';
import 'interactive_media_ads_platform.dart';

/// Object specifying creation parameters for creating a
/// [PlatformAdsManagerDelegate].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the
/// [PlatformAdsManagerDelegateCreationParams] to provide additional platform
/// specific parameters.
///
/// When extending [PlatformAdsManagerDelegateCreationParams] additional
/// parameters should always accept `null` or have a default value to prevent
/// breaking changes.
///
/// ```dart
/// class AndroidPlatformAdsManagerDelegateCreationParams
///     extends PlatformAdsManagerDelegateCreationParams {
///   AndroidPlatformAdsManagerDelegateCreationParams._(
///     PlatformAdsManagerDelegateCreationParams params, {
///     this.uri,
///   }) : super();
///
///   factory AndroidAdsManagerDelegateCreationParams.fromPlatformAdsManagerDelegateCreationParams(
///     PlatformAdsManagerDelegateCreationParams params, {
///     Uri? uri,
///   }) {
///     return AndroidAdsManagerDelegateCreationParams._(params, uri: uri);
///   }
///
///   final Uri? uri;
/// }
/// ```
@immutable
base class PlatformAdsManagerDelegateCreationParams {
  /// Used by the platform implementation to create a new [PlatformAdsManagerDelegate].
  const PlatformAdsManagerDelegateCreationParams({
    this.onAdEvent,
    this.onAdErrorEvent,
  });

  /// Invoked when there is an [AdEvent].
  final void Function(AdEvent event)? onAdEvent;

  /// Invoked when there was an error playing the ad. Log the error and resume
  /// playing content.
  final void Function(AdErrorEvent event)? onAdErrorEvent;
}

/// Interface for a platform implementation of a `AdsManagerDelegate`.
abstract base class PlatformAdsManagerDelegate {
  /// Creates a new [PlatformAdsManagerDelegate]
  factory PlatformAdsManagerDelegate(
    PlatformAdsManagerDelegateCreationParams params,
  ) {
    assert(
      InteractiveMediaAdsPlatform.instance != null,
      'A platform implementation for `interactive_media_ads` has not been set. '
      'Please ensure that an implementation of `InteractiveMediaAdsPlatform` '
      'has been set to `InteractiveMediaAdsPlatform.instance` before use. For '
      'unit testing, `InteractiveMediaAdsPlatform.instance` can be set with '
      'your own test implementation.',
    );
    final PlatformAdsManagerDelegate implementation =
        InteractiveMediaAdsPlatform.instance!
            .createPlatformAdsManagerDelegate(params);
    return implementation;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformAdsManagerDelegate].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformAdsManagerDelegate.implementation(this.params);

  /// The parameters used to initialize the [PlatformAdsManagerDelegate].
  final PlatformAdsManagerDelegateCreationParams params;
}
