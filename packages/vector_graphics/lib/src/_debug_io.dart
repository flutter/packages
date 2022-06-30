// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

/// Skip rasterization if "VECTOR_GRAPHICS_SKIP_RASTER" is "true".
bool get debugSkipRaster {
  final String? skip = Platform.environment['VECTOR_GRAPHICS_SKIP_RASTER'];
  return skip == 'true';
}

/// A debug only override for controlling the value of [debugRunningOnTester].
bool? debugRunningOnTesterOverride;

/// Whether this code is being executed in the flutter tester.
bool get debugRunningOnTester {
  return debugRunningOnTesterOverride ??
      Platform.executable.contains('flutter_tester');
}
