// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'interactive_media_ads_platform.dart';

/// Object specifying creation parameters for creating a
/// [PlatformAdDisplayContainer].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the
/// [PlatformAdDisplayContainerCreationParams] to provide additional platform
/// specific parameters.
///
/// When extending [PlatformAdDisplayContainerCreationParams] additional
/// parameters should always accept `null` or have a default value to prevent
/// breaking changes.
///
/// ```dart
/// class AndroidPlatformAdDisplayContainerCreationParams
///     extends PlatformAdDisplayContainerCreationParams {
///   AndroidPlatformAdDisplayContainerCreationParams._(
///     PlatformAdDisplayContainerCreationParams params, {
///     this.uri,
///   }) : super();
///
///   factory AndroidAdDisplayContainerCreationParams.fromPlatformAdDisplayContainerCreationParams(
///     PlatformAdDisplayContainerCreationParams params, {
///     Uri? uri,
///   }) {
///     return AndroidAdDisplayContainerCreationParams._(params, uri: uri);
///   }
///
///   final Uri? uri;
/// }
/// ```
@immutable
base class PlatformAdDisplayContainerCreationParams {
  /// Used by the platform implementation to create a new [PlatformAdDisplayContainer].
  const PlatformAdDisplayContainerCreationParams();
}

/// Interface for a platform implementation of a `AdDisplayContainer`.
abstract class PlatformAdDisplayContainer extends PlatformInterface {
  /// Creates a new [PlatformAdDisplayContainer]
  factory PlatformAdDisplayContainer(
    PlatformAdDisplayContainerCreationParams params,
  ) {
    assert(
      InteractiveMediaAdsPlatform.instance != null,
      'A platform implementation for `interactive_media_ads` has not been set. '
      'Please ensure that an implementation of `InteractiveMediaAdsPlatform` '
      'has been set to `InteractiveMediaAdsPlatform.instance` before use. For '
      'unit testing, `InteractiveMediaAdsPlatform.instance` can be set with '
      'your own test implementation.',
    );
    final PlatformAdDisplayContainer implementation =
        InteractiveMediaAdsPlatform.instance!
            .createPlatformAdDisplayContainer(params);
    PlatformInterface.verifyToken(implementation, _token);
    return implementation;
  }

  /// Used by the platform implementation to create a new [PlatformAdDisplayContainer].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformAdDisplayContainer.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformAdDisplayContainer].
  final PlatformAdDisplayContainerCreationParams params;
}
