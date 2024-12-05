// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../../google_adsense.dart';
import 'ad_unit_configuration.dart';
import 'ad_unit_widget.dart';

/// Provides the `adUnit` method on [AdSense] to request Ad widgets.
extension AdUnitExtension on AdSense {
  /// Returns an [AdUnitWidget] with the specified [configuration].
  Widget adUnit(AdUnitConfiguration configuration) {
    throw UnsupportedError('Only supported on web');
  }
}
