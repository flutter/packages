// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'ad_error.dart';
import 'interactive_media_ads_platform.dart';
import 'platform_ad_display_container.dart';
import 'platform_ads_manager.dart';
import 'platform_ads_request.dart';

/// Object specifying creation parameters for creating a [PlatformAdsLoader].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the
/// [PlatformAdsLoaderCreationParams] to provide additional platform specific
/// parameters.
///
/// When extending [PlatformAdsLoaderCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// class AndroidPlatformAdsLoaderCreationParams
///     extends PlatformAdsLoaderCreationParams {
///   AndroidPlatformAdsLoaderCreationParams._(
///     PlatformAdsLoaderCreationParams params, {
///     this.uri,
///   }) : super();
///
///   factory AndroidAdsLoaderCreationParams.fromPlatformAdsLoaderCreationParams(
///     PlatformAdsLoaderCreationParams params, {
///     Uri? uri,
///   }) {
///     return AndroidAdsLoaderCreationParams._(params, uri: uri);
///   }
///
///   final Uri? uri;
/// }
/// ```
@immutable
base class PlatformAdsLoaderCreationParams {
  /// Used by the platform implementation to create a new [PlatformAdsLoader].
  const PlatformAdsLoaderCreationParams({
    required this.container,
    required this.onAdsLoaded,
    required this.onAdsLoadError,
  });

  /// A container object where ads are rendered.
  final PlatformAdDisplayContainer container;

  /// Callback for the ads manager loaded event.
  final void Function(PlatformOnAdsLoadedData data) onAdsLoaded;

  /// Callback for errors that occur during the ads request.
  final void Function(AdsLoadErrorData data) onAdsLoadError;
}

/// Interface for a platform implementation of an object that requests ads and
/// handles events from ads request responses.
abstract base class PlatformAdsLoader {
  /// Creates a new [PlatformAdsLoader]
  factory PlatformAdsLoader(
    PlatformAdsLoaderCreationParams params,
  ) {
    assert(
      InteractiveMediaAdsPlatform.instance != null,
      'A platform implementation for `interactive_media_ads` has not been set. '
      'Please ensure that an implementation of `InteractiveMediaAdsPlatform` '
      'has been set to `InteractiveMediaAdsPlatform.instance` before use. For '
      'unit testing, `InteractiveMediaAdsPlatform.instance` can be set with '
      'your own test implementation.',
    );
    final PlatformAdsLoader implementation =
        InteractiveMediaAdsPlatform.instance!.createPlatformAdsLoader(params);
    return implementation;
  }

  /// Used by the platform implementation to create a new [PlatformAdsLoader].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformAdsLoader.implementation(this.params);

  /// The parameters used to initialize the [PlatformAdsLoader].
  final PlatformAdsLoaderCreationParams params;

  /// Signal to the SDK that the content has completed.
  Future<void> contentComplete();

  /// Requests ads from a server.
  Future<void> requestAds(PlatformAdsRequest request);
}

/// Data when ads are successfully loaded from the ad server through an
/// [PlatformAdsLoader].
@immutable
class PlatformOnAdsLoadedData {
  /// Creates a [PlatformOnAdsLoadedData].
  const PlatformOnAdsLoadedData({required this.manager});

  /// The ads manager instance created by the ads loader.
  final PlatformAdsManager manager;
}

/// Ad error data that is returned when the ads loader fails to load the ad.
@immutable
class AdsLoadErrorData {
  /// Creates a [AdsLoadErrorData].
  const AdsLoadErrorData({required this.error});

  /// The ad error that occurred while loading the ad.
  final AdError error;
}
