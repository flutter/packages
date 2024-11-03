// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('vm')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_adsense/src/adsense_stub.dart';

void main() {
  late AdSense adsense;

  setUp(() {
    adsense = AdSense.instance;
  });

  test('initialize throws error', () {
    expect(() => adsense.initialize('test-client'),
        throwsA(isA<UnsupportedError>()));
  });

  test('adUnit throws error', () {
    expect(
        () => adsense.adUnit(
              adSlot: 'test-slot',
              adClient: 'test-client',
              isAdTest: true,
              adUnitParams: <String, String>{'key': 'value'},
            ),
        throwsA(isA<UnsupportedError>()));
  });

  test('adUnit throws error with minimal parameters', () {
    expect(() => adsense.adUnit(adSlot: 'test-slot'),
        throwsA(isA<UnsupportedError>()));
  });

  test('adUnit returns Widget type', () {
    expect(
        adsense.adUnit,
        isA<
            Widget Function(
                {required String adSlot,
                String adClient,
                bool isAdTest,
                Map<String, String> adUnitParams})>());
  });
}
