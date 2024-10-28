// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_adsense/google_adsense.dart';

void main() {
  group('AdSense exports', () {
    test('AdUnitParams is exported', () {
      expect(AdUnitParams, isNotNull);
    });

    test('AdSense is exported', () {
      expect(AdSense, isNotNull);
    });
  });
}
