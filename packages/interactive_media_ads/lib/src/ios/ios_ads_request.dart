// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../platform_interface/platform_ads_request.dart';
import 'interactive_media_ads.g.dart';

/// iOS implementation of [PlatformAdsRequest].
@immutable
final class IOSAdsRequest extends PlatformAdsRequest {
  /// Constructs an [IOSAdsRequest].
  IOSAdsRequest(super.params) : super.implementation();

  /// Returns the native object to be passed to the pigeon API.
  late final IMAAdsRequest nativeRequest = _createRequest();

  @override
  Future<void> setAdWillAutoPlay(bool adWillAutoPlay) {
    return nativeRequest.setAdWillAutoPlay(adWillAutoPlay);
  }

  @override
  Future<void> setAdWillPlayMuted(bool adWillPlayMuted) {
    return nativeRequest.setAdWillPlayMuted(adWillPlayMuted);
  }

  @override
  Future<void> setContinuousPlayback(bool continuousPlayback) {
    return nativeRequest.setContinuousPlayback(continuousPlayback);
  }

  @override
  Future<void> setContentDuration(double contentDuration) {
    return nativeRequest.setContentDuration(contentDuration);
  }

  @override
  Future<void> setContentKeywords(List<String> contentKeywords) {
    return nativeRequest.setContentKeywords(contentKeywords);
  }

  @override
  Future<void> setContentTitle(String contentTitle) {
    return nativeRequest.setContentTitle(contentTitle);
  }

  @override
  Future<void> setContentUrl(String contentUrl) {
    return nativeRequest.setContentURL(contentUrl);
  }

  @override
  Future<void> setLiveStreamPrefetchSeconds(double liveStreamPrefetchSeconds) {
    return nativeRequest.setLiveStreamPrefetchSeconds(liveStreamPrefetchSeconds);
  }

  @override
  Future<void> setVastLoadTimeout(double vastLoadTimeout) {
    return nativeRequest.setVastLoadTimeout(vastLoadTimeout);
  }

  IMAAdsRequest _createRequest() {
    final IMAContentPlayhead? contentPlayhead;
    if (params.contentProgressProvider != null) {
      // TODO(bparrishMines): Finish content progress provider.
      contentPlayhead = IMAContentPlayhead();
    } else {
      contentPlayhead = null;
    }

    if (params.adTagUrl case final String adTagUrl) {
      return IMAAdsRequest(
        adTagUrl,
        // The ad display container is mainly used for rendering ads and isn't
        // needed until the ads are loaded.
        IMAAdDisplayContainer(null),
        contentPlayhead,
      );
    } else {
      return IMAAdsRequest.withAdsResponse(
        params.adsResponse!,
        // The ad display container is mainly used for rendering ads and isn't
        // needed until the ads are loaded.
        IMAAdDisplayContainer(null),
        contentPlayhead,
      );
    }
  }
}
