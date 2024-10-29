// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// Widget displaying an ad unit
abstract class AdUnitWidget extends StatefulWidget {
  /// Constructs [AdUnitWidget]
  const AdUnitWidget({super.key});

  /// See [AdUnitParams.AD_CLIENT]
  String get adClient;

  /// See [AdUnitParams.AD_SLOT]
  String get adSlot;

  /// When 'true' adUnit is more likely to be filled but might not generate impressions/clicks data and therefore any ad revenue
  bool get isAdTest;

  /// Set of required/recommended params depend on ad unit formats. See [AdUnitParams] for some of the most popular ones and links to documentation.
  Map<String, String> get additionalParams;
}
