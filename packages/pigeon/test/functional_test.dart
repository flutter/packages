// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/src/functional.dart';
import 'package:test/test.dart';

void main() {
  test('indexMap', () {
    final List<String> items = <String>['a', 'b', 'c'];
    final List<String> result =
        indexMap(items, (int index, String value) => value + index.toString())
            .toList();
    expect(result[0], 'a0');
    expect(result[1], 'b1');
    expect(result[2], 'c2');
  });

  test('enumerate', () {
    final List<String> items = <String>['a', 'b', 'c'];
    int saw = 0;
    enumerate(items, (int index, String value) {
      if (index == 0) {
        expect(value, 'a');
        saw |= 0x1;
      } else if (index == 1) {
        expect(value, 'b');
        saw |= 0x2;
      } else if (index == 2) {
        expect(value, 'c');
        saw |= 0x4;
      }
    });
    expect(saw, 0x7);
  });

  test('map2', () {
    final List<int> result =
        map2(<int>[3, 5, 7], <int>[1, 2, 3], (int x, int y) => x * y).toList();
    expect(result[0], 3);
    expect(result[1], 10);
    expect(result[2], 21);
  });

  test('map2 unequal', () {
    expect(
        () => map2(<int>[], <int>[1, 2, 3], (int x, int y) => x * y).toList(),
        throwsArgumentError);
  });

  test('map3', () {
    final List<int> result = map3(<int>[3, 5, 7], <int>[1, 2, 3],
        <int>[2, 2, 2], (int x, int y, int z) => x * y * z).toList();
    expect(result[0], 6);
    expect(result[1], 20);
    expect(result[2], 42);
  });

  test('map3 unequal', () {
    expect(
        () => map3(<int>[], <int>[1, 2, 3], <int>[],
            (int x, int y, int z) => x * y * z).toList(),
        throwsArgumentError);
  });
  test('wholeNumbers', () {
    final List<int> result = wholeNumbers.take(3).toList();
    expect(result.length, 3);
    expect(result[0], 0);
    expect(result[1], 1);
    expect(result[2], 2);
  });

  test('repeat', () {
    final List<int> result = repeat(123, 3).toList();
    expect(result.length, 3);
    expect(result[0], 123);
    expect(result[1], 123);
    expect(result[2], 123);
  });
}
