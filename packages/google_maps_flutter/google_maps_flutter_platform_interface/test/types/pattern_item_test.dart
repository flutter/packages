// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('dot', () {
    const PatternItem item = PatternItem.dot;
    expect(item.toJson(), equals(<Object>['dot']));
  });

  test('dash', () {
    final PatternItem item = PatternItem.dash(10.0);
    expect(item, isA<VariableLengthPatternItem>());
    expect(item.toJson(), equals(<Object>['dash', 10.0]));
  });

  test('gap', () {
    final PatternItem item = PatternItem.gap(20.0);
    expect(item, isA<VariableLengthPatternItem>());
    expect(item.toJson(), equals(<Object>['gap', 20.0]));
  });
}
