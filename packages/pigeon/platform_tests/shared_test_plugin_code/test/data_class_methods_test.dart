// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_test_plugin_code/src/generated/core_tests.gen.dart';
import 'package:shared_test_plugin_code/src/generated/non_null_fields.gen.dart';
import 'package:shared_test_plugin_code/test_types.dart';

void main() {
  test('NaN equality', () {
    final list = <double?>[double.nan];
    final map = <int, double?>{1: double.nan};
    final all1 = AllNullableTypes(
      aNullableDouble: double.nan,
      doubleList: list,
      recursiveClassList: <AllNullableTypes>[AllNullableTypes(aNullableDouble: double.nan)],
      map: map,
    );
    final all2 = AllNullableTypes(
      aNullableDouble: double.nan,
      doubleList: list,
      recursiveClassList: <AllNullableTypes>[AllNullableTypes(aNullableDouble: double.nan)],
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

  test('non-null fields equality', () {
    final request1 = NonNullFieldSearchRequest(query: 'hello');
    final request2 = NonNullFieldSearchRequest(query: 'hello');
    final request3 = NonNullFieldSearchRequest(query: 'world');

    expect(request1, request2);
    expect(request1, isNot(request3));
    expect(request1.hashCode, request2.hashCode);
  });

  group('deep equality', () {
    final correctList = <Object?>['a', 2, 'three'];
    final List<Object?> matchingList = correctList.toList();
    final differentList = <Object?>['a', 2, 'three', 4.0];
    final correctMap = <String, Object?>{'a': 1, 'b': 2, 'c': 'three'};
    final matchingMap = <String, Object?>{...correctMap};
    final differentKeyMap = <String, Object?>{'a': 1, 'b': 2, 'd': 'three'};
    final differentValueMap = <String, Object?>{'a': 1, 'b': 2, 'c': 'five'};
    final correctListInMap = <String, Object?>{'a': 1, 'b': 2, 'c': correctList};
    final matchingListInMap = <String, Object?>{'a': 1, 'b': 2, 'c': matchingList};
    final differentListInMap = <String, Object?>{'a': 1, 'b': 2, 'c': differentList};
    final correctMapInList = <Object?>['a', 2, correctMap];
    final matchingMapInList = <Object?>['a', 2, matchingMap];
    final differentKeyMapInList = <Object?>['a', 2, differentKeyMap];
    final differentValueMapInList = <Object?>['a', 2, differentValueMap];

    test('equality method correctly checks deep equality', () {
      final AllNullableTypes generic = genericAllNullableTypes;
      final AllNullableTypes identical = AllNullableTypes.decode(generic.encode());
      expect(identical, generic);
    });

    test('equality method correctly identifies non-matching classes', () {
      final AllNullableTypes generic = genericAllNullableTypes;
      final allNull = AllNullableTypes();
      expect(allNull == generic, false);
    });

    test('equality method correctly identifies non-matching lists in classes', () {
      final withList = AllNullableTypes(list: correctList);
      final withDifferentList = AllNullableTypes(list: differentList);
      expect(withList == withDifferentList, false);
    });

    test('equality method correctly identifies matching -but unique- lists in classes', () {
      final withList = AllNullableTypes(list: correctList);
      final withDifferentList = AllNullableTypes(list: matchingList);
      expect(withList, withDifferentList);
    });

    test('equality method correctly identifies non-matching keys in maps in classes', () {
      final withMap = AllNullableTypes(map: correctMap);
      final withDifferentMap = AllNullableTypes(map: differentKeyMap);
      expect(withMap == withDifferentMap, false);
    });

    test('equality method correctly identifies non-matching values in maps in classes', () {
      final withMap = AllNullableTypes(map: correctMap);
      final withDifferentMap = AllNullableTypes(map: differentValueMap);
      expect(withMap == withDifferentMap, false);
    });

    test('equality method correctly identifies matching -but unique- maps in classes', () {
      final withMap = AllNullableTypes(map: correctMap);
      final withDifferentMap = AllNullableTypes(map: matchingMap);
      expect(withMap, withDifferentMap);
    });
    test('signed zero equality', () {
      final v1 = AllNullableTypes(aNullableDouble: 0.0);
      final v2 = AllNullableTypes(aNullableDouble: -0.0);
      expect(v1, v2);
      expect(v1.hashCode, v2.hashCode);
    });
    test('signed zero map key equality', () {
      final v1 = AllNullableTypes(map: <double, String>{0.0: 'a'});
      final v2 = AllNullableTypes(map: <double, String>{-0.0: 'a'});
      expect(v1, v2);
      expect(v1.hashCode, v2.hashCode);
    });
    test('signed zero map value equality', () {
      final v1 = AllNullableTypes(map: <String, double>{'a': 0.0});
      final v2 = AllNullableTypes(map: <String, double>{'a': -0.0});
      expect(v1, v2);
      expect(v1.hashCode, v2.hashCode);
    });
    test('signed zero nested list equality', () {
      final v1 = AllNullableTypes(doubleList: <double>[0.0]);
      final v2 = AllNullableTypes(doubleList: <double>[-0.0]);
      expect(v1, v2);
      expect(v1.hashCode, v2.hashCode);
    });

    test('equality method correctly identifies non-matching lists nested in maps in classes', () {
      final withListInMap = AllNullableTypes(map: correctListInMap);
      final withDifferentListInMap = AllNullableTypes(map: differentListInMap);
      expect(withListInMap == withDifferentListInMap, false);
    });

    test(
      'equality method correctly identifies matching -but unique- lists nested in maps in classes',
      () {
        final withListInMap = AllNullableTypes(map: correctListInMap);
        final withDifferentListInMap = AllNullableTypes(map: matchingListInMap);
        expect(withListInMap, withDifferentListInMap);
      },
    );

    test(
      'equality method correctly identifies non-matching keys in maps nested in lists in classes',
      () {
        final withMapInList = AllNullableTypes(list: correctMapInList);
        final withDifferentMapInList = AllNullableTypes(list: differentKeyMapInList);
        expect(withMapInList == withDifferentMapInList, false);
      },
    );

    test(
      'equality method correctly identifies non-matching values in maps nested in lists in classes',
      () {
        final withMapInList = AllNullableTypes(list: correctMapInList);
        final withDifferentMapInList = AllNullableTypes(list: differentValueMapInList);
        expect(withMapInList == withDifferentMapInList, false);
      },
    );

    test(
      'equality method correctly identifies matching -but unique- maps nested in lists in classes',
      () {
        final withMapInList = AllNullableTypes(list: correctMapInList);
        final withDifferentMapInList = AllNullableTypes(list: matchingMapInList);
        expect(withMapInList, withDifferentMapInList);
      },
    );

    test('AllTypes toString full output', () {
      expect(
        genericAllTypes.toString(),
        'AllTypes(aBool: true, anInt: 42, anInt64: 3000000000, aDouble: 3.14159, aByteArray: [1, 2, 3], a4ByteArray: [4, 5, 6], a8ByteArray: [7, 8, 9], aFloatArray: [2.71828, 3.14159], anEnum: AnEnum.fortyTwo, anotherEnum: AnotherEnum.justInCase, aString: Hello host!, anObject: 1, list: [Thing 1, 2, true, 3.14, null], stringList: [Thing 1, 2, true, 3.14], intList: [1, 2, 3, 4], doubleList: [1.0, 2.99999, 3.0, 3.14], boolList: [true, false, true, false], enumList: [AnEnum.one, AnEnum.two, AnEnum.three, AnEnum.fortyTwo, AnEnum.fourHundredTwentyTwo], objectList: [Thing 1, 2, true, 3.14], listList: [[Thing 1, 2, true, 3.14], [Thing 1, 2, true, 3.14], [1, 2, 3, 4], [1.0, 2.99999, 3.0, 3.14], [true, false, true, false], [AnEnum.one, AnEnum.two, AnEnum.three, AnEnum.fortyTwo, AnEnum.fourHundredTwentyTwo]], mapList: [{a: 1, b: 2.0, c: three, d: false}, {a: 1, b: 2.0, c: three, d: false}, {0.0: 0.0, 1.1: 2.0, 3.0: 0.3, -0.4: -0.2}, {0: 0, 1: 1, 2: 3, 4: -1}, {0: true, 1: false, 2: true}, {AnEnum.one: AnEnum.one, AnEnum.two: AnEnum.two, AnEnum.three: AnEnum.three, AnEnum.fortyTwo: AnEnum.fortyTwo}], map: {a: 1, b: 2.0, c: three, d: false}, stringMap: {a: 1, b: 2.0, c: three, d: false}, intMap: {0: 0, 1: 1, 2: 3, 4: -1}, enumMap: {AnEnum.one: AnEnum.one, AnEnum.two: AnEnum.two, AnEnum.three: AnEnum.three, AnEnum.fortyTwo: AnEnum.fortyTwo}, objectMap: {a: 1, b: 2.0, c: three, d: false}, listMap: {0: [Thing 1, 2, true, 3.14], 1: [Thing 1, 2, true, 3.14], 2: [1.0, 2.99999, 3.0, 3.14], 4: [1, 2, 3, 4], 5: [true, false, true, false], 6: [AnEnum.one, AnEnum.two, AnEnum.three, AnEnum.fortyTwo, AnEnum.fourHundredTwentyTwo]}, mapMap: {0: {a: 1, b: 2.0, c: three, d: false}, 1: {a: 1, b: 2.0, c: three, d: false}, 2: {0.0: 0.0, 1.1: 2.0, 3.0: 0.3, -0.4: -0.2}, 4: {0: 0, 1: 1, 2: 3, 4: -1}, 5: {0: true, 1: false, 2: true}, 6: {AnEnum.one: AnEnum.one, AnEnum.two: AnEnum.two, AnEnum.three: AnEnum.three, AnEnum.fortyTwo: AnEnum.fortyTwo}})',
      );
    });

    test('constants', () {
      expect(aStringConstant, 'stringConstantValue');
      expect(aStringConstantWithEscapes, r'string\\$ConstantValue');
      expect(anIntConstant, 42);
      expect(aDoubleConstant, 3.14);
      expect(aBoolConstant, true);
    });
  });
}
