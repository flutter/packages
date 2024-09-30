// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart';

import '../platform_interface/platform_content_progress_provider.dart';
import 'interactive_media_ads.g.dart' as ima;
import 'interactive_media_ads_proxy.dart';

/// Android implementation of [PlatformContentProgressProviderCreationParams].
final class AndroidContentProgressProviderCreationParams
    extends PlatformContentProgressProviderCreationParams {
  /// Constructs a [AndroidContentProgressProviderCreationParams].
  const AndroidContentProgressProviderCreationParams({
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  })  : _proxy = proxy ?? const InteractiveMediaAdsProxy(),
        super();

  /// Creates a [AndroidContentProgressProviderCreationParams] from an instance of
  /// [PlatformContentProgressProviderCreationParams].
  factory AndroidContentProgressProviderCreationParams.fromPlatformContentProgressProviderCreationParams(
    // Placeholder to prevent requiring a breaking change if params are added to
    // PlatformContentProgressProviderCreationParams.
    // ignore: avoid_unused_constructor_parameters
    PlatformContentProgressProviderCreationParams params, {
    @visibleForTesting InteractiveMediaAdsProxy? proxy,
  }) {
    return AndroidContentProgressProviderCreationParams(proxy: proxy);
  }

  final InteractiveMediaAdsProxy _proxy;
}

/// Android implementation of [PlatformContentProgressProvider].
base class AndroidContentProgressProvider
    extends PlatformContentProgressProvider {
  /// Constructs an [AndroidContentProgressProvider].
  AndroidContentProgressProvider(super.params) : super.implementation();

  /// The native Android ContentProgressProvider.
  ///
  /// This allows the SDK to track progress of the content video.
  @internal
  late final ima.ContentProgressProvider progressProvider =
      _androidParams._proxy.newContentProgressProvider();

  late final AndroidContentProgressProviderCreationParams _androidParams =
      params is AndroidContentProgressProviderCreationParams
          ? params as AndroidContentProgressProviderCreationParams
          : AndroidContentProgressProviderCreationParams
              .fromPlatformContentProgressProviderCreationParams(
              params,
            );

  @override
  Future<void> setProgress({
    required Duration progress,
    required Duration duration,
  }) async {
    return progressProvider.setContentProgress(
      _androidParams._proxy.newVideoProgressUpdate(
        currentTimeMs: progress.inMilliseconds,
        durationMs: duration.inMilliseconds,
      ),
    );
  }
}
