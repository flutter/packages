// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buttCap', () {
    const Cap cap = Cap.buttCap;
    expect(cap.toJson(), equals(<Object>['buttCap']));
  });

  test('roundCap', () {
    const Cap cap = Cap.roundCap;
    expect(cap.toJson(), equals(<Object>['roundCap']));
  });

  test('squareCap', () {
    const Cap cap = Cap.squareCap;
    expect(cap.toJson(), equals(<Object>['squareCap']));
  });

  test('customCap', () {
    final Cap cap = Cap.customCapFromBitmap(BitmapDescriptor.defaultMarker);
    expect(
        cap.toJson(),
        equals(<Object>[
          'customCap',
          <Object>['defaultMarker'],
          10.0
        ]));
  });

  test('customCapWithWidth', () {
    final Cap cap =
        Cap.customCapFromBitmap(BitmapDescriptor.defaultMarker, refWidth: 100);
    expect(
        cap.toJson(),
        equals(<Object>[
          'customCap',
          <Object>['defaultMarker'],
          100.0
        ]));
  });
}
