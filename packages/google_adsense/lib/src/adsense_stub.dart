// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ad_unit_widget_interface.dart';

/// Main class to work with the library
class Adsense {
  /// Returns a singleton instance of Adsense library public interface
  factory Adsense() => _instance ?? Adsense._internal();

  Adsense._internal() {
    _instance = this;
  }

  static Adsense? _instance = Adsense._internal();

  /// Initialization API. Should be called ASAP, ideally in the main method of your app.
  void initialize(String adClient) {
    throw UnsupportedError('Only supported on web');
  }

  /// Returns a configurable [AdUnitWidget]
  AdUnitWidget adUnit(
      {required String adSlot,
      String adClient = '',
      bool isAdTest = false,
      Map<String, dynamic> adUnitParams = const <String, dynamic>{}}) {
    throw UnsupportedError('Only supported on web');
  }

  /// Only for use in tests
  static void resetForTesting() {
    _instance = null;
  }
}
