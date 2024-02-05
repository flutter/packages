// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'interactive_media_ads_platform.dart';

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
  const PlatformAdsLoaderCreationParams();
}

/// Interface for a platform implementation of a `AdsLoader`.
abstract class PlatformAdsLoader extends PlatformInterface {
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
    PlatformInterface.verify(implementation, _token);
    return implementation;
  }

  /// Used by the platform implementation to create a new [PlatformAdsLoader].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformAdsLoader.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformAdsLoader].
  final PlatformAdsLoaderCreationParams params;
}
