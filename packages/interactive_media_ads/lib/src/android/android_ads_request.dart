// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../platform_interface/platform_ads_request.dart';
import 'interactive_media_ads.g.dart';

/// Android implementation of [PlatformAdsRequest].
@immutable
final class AndroidAdsRequest extends PlatformAdsRequest {
  /// Constructs an [AndroidAdsRequest].
  AndroidAdsRequest(super.params) : super.implementation();

  late final Future<AdsRequest> _request = _createRequest();

  @override
  Future<void> setAdWillAutoPlay(bool adWillAutoPlay) async {
    (await _request).setAdWillAutoPlay(adWillAutoPlay);
  }

  @override
  Future<void> setAdWillPlayMuted(bool adWillPlayMuted) async {
    (await _request).setAdWillPlayMuted(adWillPlayMuted);
  }

  @override
  Future<void> setContinuousPlayback(bool continuousPlayback) async {
    (await _request).setContinuousPlayback(continuousPlayback);
  }

  @override
  Future<void> setContentDuration(double contentDuration) async {
    (await _request).setContentDuration(contentDuration);
  }

  @override
  Future<void> setContentKeywords(List<String> contentKeywords) async {
    (await _request).setContentKeywords(contentKeywords);
  }

  @override
  Future<void> setContentTitle(String contentTitle) async {
    (await _request).setContentTitle(contentTitle);
  }

  @override
  Future<void> setContentUrl(String contentUrl) async {
    (await _request).setContentUrl(contentUrl);
  }

  @override
  Future<void> setLiveStreamPrefetchSeconds(
    double liveStreamPrefetchSeconds,
  ) async {
    (await _request).setLiveStreamPrefetchSeconds(liveStreamPrefetchSeconds);
  }

  @override
  Future<void> setVastLoadTimeout(double vastLoadTimeout) async {
    (await _request).setVastLoadTimeout(vastLoadTimeout);
  }

  Future<AdsRequest> _createRequest() async {
    final AdsRequest request = await ImaSdkFactory.instance.createAdsRequest();

    final List<Future<void>> futures = <Future<void>>[];
    if (params.adTagUrl case final String adTagUrl) {
      futures.add(request.setAdTagUrl(adTagUrl));
    } else if (params.adsResponse case final String adsResponse) {
      futures.add(request.setAdsResponse(adsResponse));
    }

    // TODO(bparrishMines): Add contentProgressProvider when it's supported on
    // Android.

    await Future.wait(futures);
    return request;
  }
}
