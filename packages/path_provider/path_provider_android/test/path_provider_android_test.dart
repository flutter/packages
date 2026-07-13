// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_android/path_provider_android.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

// Most tests are in integration_test rather than here, because anything that
// needs to create Java objects has to run in the real runtime.

void main() {
  test('registers instance', () {
    PathProviderAndroid.registerWith();
    expect(PathProviderPlatform.instance, isA<PathProviderAndroid>());
  });
}
