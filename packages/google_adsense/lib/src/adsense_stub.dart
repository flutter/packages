// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../google_adsense.dart';

/// Returns a singleton instance of Adsense library public interface
final AdSense adSense = AdSense();

/// Main class to work with the library
class AdSense {
  /// Getter for adClient passed on initialization
  late String adClientId;

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
