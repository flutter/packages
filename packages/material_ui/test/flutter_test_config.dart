// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


// Initial testing of instance only, not for merging.
// Plenty to do next (if this works):
// - verify service accounts used by Luci in pre/post submit tests in flutter/packages, auth works
// - Get new Gold frontend up
// - document how to enable golden file testing for a package
// - update flutter/cocoon to add flutter-gold check for triage

import 'dart:async';

import 'goldens_io.dart'
    if (dart.library.js_interop) 'goldens_web.dart'
    as flutter_goldens;

Future<void> testExecutable(FutureOr<void> Function() testMain) {
  // Enable golden file testing using Skia Gold.
  return flutter_goldens.testExecutable(testMain, namePrefix: 'two_dimensional_scrollables');
}
