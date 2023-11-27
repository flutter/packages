// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'metering_point.dart';

/// somethin
abstract class MeteringPointFactory {
  /// somethin
  Future<MeteringPoint> createPoint(int x, int y, int? size);

  /// something
  Future<int> getDefaultPointSize();
}
// here