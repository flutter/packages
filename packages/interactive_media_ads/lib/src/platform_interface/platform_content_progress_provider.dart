// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'interactive_media_ads_platform.dart';

/// Object specifying creation parameters for creating a
/// [PlatformContentProgressProvider].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the
/// [PlatformContentProgressProviderCreationParams] to provide additional
/// platform specific parameters.
///
/// When extending [PlatformContentProgressProviderCreationParams] additional
/// parameters should always accept `null` or have a default value to prevent
/// breaking changes.
///
/// ```dart
/// class AndroidPlatformContentProgressProviderCreationParams
///     extends PlatformContentProgressProviderCreationParams {
///   AndroidPlatformContentProgressProviderCreationParams._(
///     PlatformContentProgressProviderCreationParams params, {
///     this.uri,
///   }) : super();
///
///   factory AndroidPlatformContentProgressProviderCreationParams.fromPlatformContentProgressProviderCreationParams(
///     PlatformContentProgressProviderCreationParams params, {
///     Uri? uri,
///   }) {
///     return AndroidPlatformContentProgressProviderCreationParams._(params, uri: uri);
///   }
///
///   final Uri? uri;
/// }
/// ```
@immutable
base class PlatformContentProgressProviderCreationParams {
  /// Used by the platform implementation to create a new
  /// [PlatformContentProgressProvider].
  const PlatformContentProgressProviderCreationParams();
}

/// Interface to allow the SDK to track progress of the content video.
///
/// Provides updates required to enable triggering ads at configured cue points.
abstract class PlatformContentProgressProvider {
  /// Creates a new [PlatformAdsManagerDelegate]
  factory PlatformContentProgressProvider(
    PlatformContentProgressProviderCreationParams params,
  ) {
    assert(
      InteractiveMediaAdsPlatform.instance != null,
      'A platform implementation for `interactive_media_ads` has not been set. '
      'Please ensure that an implementation of `InteractiveMediaAdsPlatform` '
      'has been set to `InteractiveMediaAdsPlatform.instance` before use. For '
      'unit testing, `InteractiveMediaAdsPlatform.instance` can be set with '
      'your own test implementation.',
    );
    final PlatformContentProgressProvider implementation =
        InteractiveMediaAdsPlatform.instance!
            .createPlatformContentProgressProvider(params);
    return implementation;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformContentProgressProvider].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformContentProgressProvider.implementation(this.params);

  /// The parameters used to initialize the [PlatformContentProgressProvider].
  final PlatformContentProgressProviderCreationParams params;

  /// Sends an update on the progress of the content video.
  Future<void> setProgress({
    required Duration progress,
    required Duration duration,
  });
}
