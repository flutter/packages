// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import '../google_adsense.dart';

/// Returns a singleton instance of Adsense library public interface
final AdSense adSense = AdSense();

/// Main class to work with the library
class AdSense {

  /// Initialization API. Should be called ASAP, ideally in the main method of your app.
  void initialize(String adClient) {
    throw UnsupportedError('Only supported on web');
  }

  /// Returns a configurable [AdUnitWidget]
  ///
  /// `adSlot`: see [AdUnitParams.AD_SLOT]
  ///
  /// `adClient`: see [AdUnitParams.AD_CLIENT]
  ///
  /// `isAdTest`: testing environment flag, should be set to `false` in production
  ///
  /// `adUnitParams`: see [AdUnitParams] for the non-extensive list of some possible keys.
  AdUnitWidget adUnit(
      {required String adSlot,
      String adClient = '',
      bool isAdTest = kDebugMode,
      Map<String, String> adUnitParams = const <String, String>{},
      String? cssText}) {
    throw UnsupportedError('Only supported on web');
  }
}
