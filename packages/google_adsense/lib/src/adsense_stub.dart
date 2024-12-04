// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../experimental/google_adsense.dart';

/// A singleton instance of AdSense library public interface.
final AdSense adSense = AdSense();

/// AdSense package interface.
class AdSense {
  /// Initialization API. Should be called ASAP, ideally in the main method of your app.
  void initialize(
    String adClient, {
    @visibleForTesting bool skipJsLoader = false,
    @visibleForTesting Object? jsLoaderTarget,
  }) {
    throw UnsupportedError('Only supported on web');
  }

  /// Returns a configurable [AdUnitWidget]<br>
  /// `configuration`: see [AdUnitConfiguration]
  Widget adUnit(AdUnitConfiguration configuration) {
    throw UnsupportedError('Only supported on web');
  }
}
