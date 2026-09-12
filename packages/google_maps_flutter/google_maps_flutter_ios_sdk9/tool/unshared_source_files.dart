// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

const intentionallyUnsharedSourceFiles = <String>[
  // Package dependencies are platform-specific due to versioning.
  'ios/google_maps_flutter_ios_sdk9/Package.swift',
  // Intentionally unshared since it has almost no code, and would need
  // special handling for the filename being different.
  'lib/google_maps_flutter_ios_sdk9.dart',
  // Intentionally unshared to isolate import name differences.
  'test/package_specific_test_import.dart',
  // Each package will have its own list.
  'tool/unshared_source_files.dart',
];
