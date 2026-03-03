// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_test_plugin_code/src/generated/core_tests.gen.dart';

void main() {
  test('NaN equality', () {
    final list = <double?>[double.nan];
    final map = <int, double?>{1: double.nan};
    final all1 = AllNullableTypes(
      aNullableDouble: double.nan,
      doubleList: list,
      recursiveClassList: <AllNullableTypes>[
        AllNullableTypes(aNullableDouble: double.nan),
      ],
      map: map,
    );
    final all2 = AllNullableTypes(
      aNullableDouble: double.nan,
      doubleList: list,
      recursiveClassList: <AllNullableTypes>[
        AllNullableTypes(aNullableDouble: double.nan),
      ],
      map: map,
    );

    expect(all1, all2);
    expect(all1.hashCode, all2.hashCode);
  });

  test('Nested collection equality', () {
    final all1 = AllNullableTypes(
      listList: <List<Object?>>[
        <Object?>[1, 2],
      ],
      mapMap: <int, Map<Object?, Object?>>{
        1: <Object?, Object?>{'a': 'b'},
      },
    );
    final all2 = AllNullableTypes(
      listList: <List<Object?>>[
        <Object?>[1, 2],
      ],
      mapMap: <int, Map<Object?, Object?>>{
        1: <Object?, Object?>{'a': 'b'},
      },
    );

    expect(all1, all2);
    expect(all1.hashCode, all2.hashCode);
  });

  test('Cross-type equality returns false', () {
    final a = AllNullableTypes(aNullableInt: 1);
    final b = AllNullableTypesWithoutRecursion(aNullableInt: 1);
    // ignore: unrelated_type_equality_checks
    expect(a == b, isFalse);
    // ignore: unrelated_type_equality_checks
    expect(b == a, isFalse);
  });
}
