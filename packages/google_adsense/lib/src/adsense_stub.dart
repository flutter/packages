// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ad_unit_widget.dart';

/// Main class to work with the library
class AdSense {
  // Internal constructor
  AdSense._internal();

  /// Returns a singleton instance of Adsense library public interface
  static AdSense get instance => _instance;

  // Singleton property
  static AdSense _instance = AdSense._internal();

  /// Initialization API. Should be called ASAP, ideally in the main method of your app.
  void initialize(String adClient) {
    throw UnsupportedError('Only supported on web');
  }

  /// Returns a configurable [AdUnitWidget]
  AdUnitWidget adUnit(
      {required String adSlot,
      String adClient = '',
      bool isAdTest = false,
      Map<String, String> adUnitParams = const <String, String>{},
      String? cssText}) {
    throw UnsupportedError('Only supported on web');
  }

  /// Only for use in tests
  static void resetForTesting() {
    _instance = AdSense._internal();
  }
}
