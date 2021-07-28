// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/generator_tools.dart';
import 'package:test/test.dart';

bool _equalSet<T>(Set<T> x, Set<T> y) {
  if (x.length != y.length) {
    return false;
  }
  for (final T object in x) {
    if (!y.contains(object)) {
      return false;
    }
  }
  return true;
}

bool _equalMaps(Map<String, Object> x, Map<String, Object> y) {
  if (!_equalSet(x.keys.toSet(), y.keys.toSet())) {
    return false;
  }
  for (final String key in x.keys) {
    final Object xValue = x[key]!;
    if (xValue is Map<String, Object>) {
      if (!_equalMaps(xValue, (y[key] as Map<String, Object>?)!)) {
        return false;
      }
    } else {
      if (xValue != y[key]) {
        return false;
      }
    }
  }
  return true;
}

void main() {
  test('test merge maps', () {
    final Map<String, Object> source = <String, Object>{
      '1': '1',
      '2': <String, Object>{
        '1': '1',
        '3': '3',
      },
      '3': '3', // not modified
    };
    final Map<String, Object> modification = <String, Object>{
      '1': '2', // modify
      '2': <String, Object>{
        '2': '2', // added
      },
    };
    final Map<String, Object> expected = <String, Object>{
      '1': '2',
      '2': <String, Object>{
        '1': '1',
        '2': '2',
        '3': '3',
      },
      '3': '3',
    };
    expect(_equalMaps(expected, mergeMaps(source, modification)), isTrue);
  });
}
