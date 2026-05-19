// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This is a separate file so that all test files that need to import the
// implementation package can do so without causing diffs among the shared code
// due to the package names being different. This way, all the test files can
// be shared exactly, and only this file needs to diverge between the packages.

export 'package:google_maps_flutter_ios_sdk10/google_maps_flutter_ios_sdk10.dart';
export 'package:google_maps_flutter_ios_sdk10/src/messages.g.dart';
