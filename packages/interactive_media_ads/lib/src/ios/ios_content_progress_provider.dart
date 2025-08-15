// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import '../platform_interface/platform_content_progress_provider.dart';
import 'interactive_media_ads.g.dart' as ima;
import 'interactive_media_ads_proxy.dart';

/// Implementation of [PlatformContentProgressProviderCreationParams] for iOS.
final class IOSContentProgressProviderCreationParams
    extends PlatformContentProgressProviderCreationParams {
  /// Constructs an [IOSContentProgressProviderCreationParams].
  const IOSContentProgressProviderCreationParams() : super();

  /// Creates a [IOSContentProgressProviderCreationParams] from an instance of
  /// [PlatformContentProgressProviderCreationParams].
  factory IOSContentProgressProviderCreationParams.fromPlatformContentProgressProviderCreationParams(
    // Placeholder to prevent requiring a breaking change if params are added to
    // PlatformContentProgressProviderCreationParams.
    // ignore: avoid_unused_constructor_parameters
    PlatformContentProgressProviderCreationParams params,
  ) {
    return const IOSContentProgressProviderCreationParams();
  }
}

/// Implementation of [PlatformContentProgressProvider] for iOS.
base class IOSContentProgressProvider extends PlatformContentProgressProvider {
  /// Constructs an [IOSContentProgressProvider].
  IOSContentProgressProvider(super.params) : super.implementation();

  /// The native iOS IMAContentPlayhead.
  ///
  /// This allows the SDK to track progress of the content video.
  @internal
  late final ima.IMAContentPlayhead contentPlayhead = ima.IMAContentPlayhead();

  @override
  Future<void> setProgress({
    required Duration progress,
    required Duration duration,
  }) async {
    return contentPlayhead.setCurrentTime(progress.inSeconds.toDouble());
  }
}
