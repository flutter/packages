// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

/// Skip rasterization if "VECTOR_GRAPHICS_SKIP_RASTER" is "true".
bool get debugSkipRaster {
  final String? skip = Platform.environment['VECTOR_GRAPHICS_SKIP_RASTER'];
  return skip == 'true';
}
