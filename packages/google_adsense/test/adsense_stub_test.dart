// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('vm')
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_adsense/src/adsense_stub.dart';

void main() {

  test('initialize throws error', () {
    expect(() => adSense.initialize('test-client'),
        throwsA(isA<UnsupportedError>()));
  });

  test('adUnit throws error', () {
    expect(
        () => adSense.adUnit(
              adSlot: 'test-slot',
              adClient: 'test-client',
              isAdTest: true,
              adUnitParams: <String, String>{'key': 'value'},
            ),
        throwsA(isA<UnsupportedError>()));
  });

  test('adUnit throws error with minimal parameters', () {
    expect(() => adSense.adUnit(adSlot: 'test-slot'),
        throwsA(isA<UnsupportedError>()));
  });

  test('adUnit returns Widget type', () {
    expect(
        adSense.adUnit,
        isA<
            Widget Function(
                {required String adSlot,
                String adClient,
                bool isAdTest,
                Map<String, String> adUnitParams})>());
  });
  test('Tell the user where to find the real tests', () {
    print('---');
    print('This package uses integration_test for its main tests.');
    print('See `example/README.md` for more info.');
    print('---');
  });
}
