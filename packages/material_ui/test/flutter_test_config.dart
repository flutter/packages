// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'goldens_io.dart' if (dart.library.js_interop) 'goldens_web.dart' as flutter_goldens;

Future<void> testExecutable(FutureOr<void> Function() testMain) {
  // Enable golden file testing using Skia Gold.
  return flutter_goldens.testExecutable(testMain);
}
