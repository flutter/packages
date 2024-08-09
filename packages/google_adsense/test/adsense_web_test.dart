// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_adsense/google_adsense.dart';

void main() {
  group('Adsense', () {
    test('Singleton instance', () {
      final Adsense instance1 = Adsense();
      final Adsense instance2 = Adsense();
      expect(instance1, same(instance2));
    });
  });
}
