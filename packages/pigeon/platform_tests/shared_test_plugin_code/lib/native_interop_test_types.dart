// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';

import 'src/generated/native_interop_tests.gen.dart';

const int biggerThanBigInt = 3000000000;
const int regularInt = 42;
const double doublePi = 3.14159;

final List<Object> nonNullList = <Object>['Thing 1', 2, true, 3.14];

final List<String> nonNullStringList = <String>['Thing 1', '2', 'true', '3.14'];

final List<int> nonNullIntList = <int>[1, 2, 3, 4];

final List<double> nonNullDoubleList = <double>[1, 2.99999, 3, 3.14];

final List<bool> nonNullBoolList = <bool>[true, false, true, false];

final List<NativeInteropAnEnum> nonNullEnumList = <NativeInteropAnEnum>[
  NativeInteropAnEnum.one,
  NativeInteropAnEnum.two,
  NativeInteropAnEnum.three,
  NativeInteropAnEnum.fortyTwo,
  NativeInteropAnEnum.fourHundredTwentyTwo,
];

final List<List<Object>> nonNullListList = <List<Object>>[
  nonNullList,
  nonNullStringList,
  nonNullIntList,
  nonNullDoubleList,
  nonNullBoolList,
  nonNullEnumList,
];

final Map<Object, Object> nonNullMap = <Object, Object>{'a': 1, 'b': 2.0, 'c': 'three', 'd': false};

final Map<String, String> nonNullStringMap = <String, String>{
  'a': '1',
  'b': '2.0',
  'c': 'three',
  'd': 'false',
};

final Map<int, int> nonNullIntMap = <int, int>{0: 0, 1: 1, 2: 3, 4: -1};

final Map<double, double> nonNullDoubleMap = <double, double>{0.0: 0, 1.1: 2.0, 3: 0.3, -.4: -0.2};

final Map<int, bool> nonNullBoolMap = <int, bool>{0: true, 1: false, 2: true};

final Map<NativeInteropAnEnum, NativeInteropAnEnum> nonNullEnumMap =
    <NativeInteropAnEnum, NativeInteropAnEnum>{
      NativeInteropAnEnum.one: NativeInteropAnEnum.one,
      NativeInteropAnEnum.two: NativeInteropAnEnum.two,
      NativeInteropAnEnum.three: NativeInteropAnEnum.three,
      NativeInteropAnEnum.fortyTwo: NativeInteropAnEnum.fortyTwo,
    };

final Map<int, List<Object>> nonNullListMap = <int, List<Object>>{
  0: nonNullList,
  1: nonNullStringList,
  2: nonNullDoubleList,
  4: nonNullIntList,
  5: nonNullBoolList,
  6: nonNullEnumList,
};

final Map<int, Map<Object, Object>> nonNullMapMap = <int, Map<Object, Object>>{
  0: nonNullMap,
  1: nonNullStringMap,
  2: nonNullDoubleMap,
  4: nonNullIntMap,
  5: nonNullBoolMap,
  6: nonNullEnumMap,
};

final List<Map<Object, Object>> nonNullMapList = <Map<Object, Object>>[
  nonNullMap,
  nonNullStringMap,
  nonNullDoubleMap,
  nonNullIntMap,
  nonNullBoolMap,
  nonNullEnumMap,
];

final List<Object?> list = <Object?>['Thing 1', 2, true, 3.14, null];

final List<String?> stringList = <String?>['Thing 1', '2', 'true', '3.14', null];

final List<int?> intList = <int?>[1, 2, 3, 4, null];

final List<double?> doubleList = <double?>[1, 2.99999, 3, 3.14, null];

final List<bool?> boolList = <bool?>[true, false, true, false, null];

final List<NativeInteropAnEnum?> enumList = <NativeInteropAnEnum?>[
  NativeInteropAnEnum.one,
  NativeInteropAnEnum.two,
  NativeInteropAnEnum.three,
  NativeInteropAnEnum.fortyTwo,
  NativeInteropAnEnum.fourHundredTwentyTwo,
  null,
];

final List<List<Object?>?> listList = <List<Object?>?>[
  list,
  stringList,
  intList,
  doubleList,
  boolList,
  enumList,
  null,
];

final Map<Object?, Object?> map = <Object?, Object?>{
  'a': 1,
  'b': 2.0,
  'c': 'three',
  'd': false,
  'e': null,
};

final Map<String?, String?> stringMap = <String?, String?>{
  'a': '1',
  'b': '2.0',
  'c': 'three',
  'd': 'false',
  'e': 'null',
  'f': null,
};

final Map<int?, int?> intMap = <int?, int?>{0: 0, 1: 1, 2: 3, 4: -1, 5: null};

final Map<double?, double?> doubleMap = <double?, double?>{
  0.0: 0,
  1.1: 2.0,
  3: 0.3,
  -.4: -0.2,
  1111111111111111.11111111111111111111111111111111111111111111: null,
};

final Map<int?, bool?> boolMap = <int?, bool?>{0: true, 1: false, 2: true, 3: null};

final Map<NativeInteropAnEnum?, NativeInteropAnEnum?> enumMap =
    <NativeInteropAnEnum?, NativeInteropAnEnum?>{
      NativeInteropAnEnum.one: NativeInteropAnEnum.one,
      NativeInteropAnEnum.two: NativeInteropAnEnum.two,
      NativeInteropAnEnum.three: NativeInteropAnEnum.three,
      NativeInteropAnEnum.fortyTwo: NativeInteropAnEnum.fortyTwo,
      NativeInteropAnEnum.fourHundredTwentyTwo: null,
    };

final Map<int?, List<Object?>?> listMap = <int?, List<Object?>?>{
  0: list,
  1: stringList,
  2: doubleList,
  4: intList,
  5: boolList,
  6: enumList,
  7: null,
};

final Map<int?, Map<Object?, Object?>?> mapMap = <int?, Map<Object?, Object?>?>{
  0: map,
  1: stringMap,
  2: doubleMap,
  4: intMap,
  5: boolMap,
  6: enumMap,
  7: null,
};

final List<Map<Object?, Object?>?> mapList = <Map<Object?, Object?>?>[
  map,
  stringMap,
  doubleMap,
  intMap,
  boolMap,
  enumMap,
  null,
];

final NativeInteropAllNullableTypesWithoutRecursion
genericNativeInteropAllNullableTypesWithoutRecursion =
    NativeInteropAllNullableTypesWithoutRecursion(
      aNullableBool: true,
      aNullableInt: regularInt,
      aNullableInt64: biggerThanBigInt,
      aNullableDouble: doublePi,
      aNullableString: 'Hello host!',
      aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
      aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
      aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
      aNullableFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
      aNullableEnum: NativeInteropAnEnum.fourHundredTwentyTwo,
      aNullableObject: 'nullable',
      list: list,
      stringList: stringList,
      intList: intList,
      doubleList: doubleList,
      boolList: boolList,
      enumList: enumList,
      objectList: list,
      listList: listList,
      mapList: mapList,
      map: map,
      stringMap: stringMap,
      intMap: intMap,
      enumMap: enumMap,
      objectMap: map,
      listMap: listMap,
      mapMap: mapMap,
    );

final List<NativeInteropAllNullableTypesWithoutRecursion?> allNullableTypesWithoutRecursionList =
    <NativeInteropAllNullableTypesWithoutRecursion?>[
      genericNativeInteropAllNullableTypesWithoutRecursion,
      NativeInteropAllNullableTypesWithoutRecursion(),
      null,
    ];

final Map<int, NativeInteropAllNullableTypesWithoutRecursion?> allNullableTypesWithoutRecursionMap =
    <int, NativeInteropAllNullableTypesWithoutRecursion?>{
      0: genericNativeInteropAllNullableTypesWithoutRecursion,
      1: NativeInteropAllNullableTypesWithoutRecursion(),
      2: null,
    };

final NativeInteropAllTypes genericNativeInteropAllTypes = NativeInteropAllTypes(
  aBool: true,
  anInt: regularInt,
  anInt64: biggerThanBigInt,
  aDouble: doublePi,
  aString: 'Hello host!',
  aByteArray: Uint8List.fromList(<int>[1, 2, 3]),
  a4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
  a8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
  aFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
  anEnum: NativeInteropAnEnum.fortyTwo,
  anObject: 'notNullable',
  list: nonNullList,
  stringList: nonNullStringList,
  intList: nonNullIntList,
  doubleList: nonNullDoubleList,
  boolList: nonNullBoolList,
  enumList: nonNullEnumList,
  objectList: nonNullList,
  listList: nonNullListList,
  mapList: nonNullMapList,
  map: nonNullMap,
  stringMap: nonNullStringMap,
  intMap: nonNullIntMap,
  // doubleMap: nonNullDoubleMap,
  // boolMap: nonNullBoolMap,
  enumMap: nonNullEnumMap,
  objectMap: nonNullMap,
  listMap: nonNullListMap,
  mapMap: nonNullMapMap,
);

final List<NativeInteropAllTypes?> allTypesClassList = <NativeInteropAllTypes?>[
  genericNativeInteropAllTypes,
  null,
];

final Map<int, NativeInteropAllTypes?> allTypesClassMap = <int, NativeInteropAllTypes?>{
  0: genericNativeInteropAllTypes,
  1: null,
};

final NativeInteropAllNullableTypes genericNativeInteropAllNullableTypes =
    NativeInteropAllNullableTypes(
      aNullableBool: true,
      aNullableInt: regularInt,
      aNullableInt64: biggerThanBigInt,
      aNullableDouble: doublePi,
      aNullableString: 'Hello host!',
      aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
      aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
      aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
      aNullableFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
      aNullableEnum: NativeInteropAnEnum.fourHundredTwentyTwo,
      aNullableObject: 0,
      list: list,
      stringList: stringList,
      intList: intList,
      doubleList: doubleList,
      boolList: boolList,
      enumList: enumList,
      objectList: list,
      listList: listList,
      mapList: mapList,
      map: map,
      stringMap: stringMap,
      intMap: intMap,
      enumMap: enumMap,
      objectMap: map,
      listMap: listMap,
      mapMap: mapMap,
    );

final List<NativeInteropAllNullableTypes> nonNullNativeInteropAllNullableTypesList =
    <NativeInteropAllNullableTypes>[
      genericNativeInteropAllNullableTypes,
      NativeInteropAllNullableTypes(),
    ];

final Map<int, NativeInteropAllNullableTypes> nonNullNativeInteropAllNullableTypesMap =
    <int, NativeInteropAllNullableTypes>{
      0: genericNativeInteropAllNullableTypes,
      1: NativeInteropAllNullableTypes(),
    };

final List<NativeInteropAllNullableTypesWithoutRecursion>
nonNullNativeInteropAllNullableTypesWithoutRecursionList =
    <NativeInteropAllNullableTypesWithoutRecursion>[
      genericNativeInteropAllNullableTypesWithoutRecursion,
      NativeInteropAllNullableTypesWithoutRecursion(),
    ];

final Map<int, NativeInteropAllNullableTypesWithoutRecursion>
nonNullNativeInteropAllNullableTypesWithoutRecursionMap =
    <int, NativeInteropAllNullableTypesWithoutRecursion>{
      0: genericNativeInteropAllNullableTypesWithoutRecursion,
      1: NativeInteropAllNullableTypesWithoutRecursion(),
    };

final List<NativeInteropAllNullableTypes?> allNullableTypesList = <NativeInteropAllNullableTypes?>[
  genericNativeInteropAllNullableTypes,
  NativeInteropAllNullableTypes(),
  null,
];

final Map<int, NativeInteropAllNullableTypes?> allNullableTypesMap =
    <int, NativeInteropAllNullableTypes?>{
      0: genericNativeInteropAllNullableTypes,
      1: NativeInteropAllNullableTypes(),
      2: null,
    };

final NativeInteropAllNullableTypes recursiveNativeInteropAllNullableTypes =
    NativeInteropAllNullableTypes(
      aNullableBool: true,
      aNullableInt: regularInt,
      aNullableInt64: biggerThanBigInt,
      aNullableDouble: doublePi,
      aNullableString: 'Hello host!',
      aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
      aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
      aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
      aNullableFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
      aNullableEnum: NativeInteropAnEnum.fourHundredTwentyTwo,
      aNullableObject: 0,
      allNullableTypes: genericNativeInteropAllNullableTypes,
      list: list,
      stringList: stringList,
      intList: intList,
      doubleList: doubleList,
      boolList: boolList,
      enumList: enumList,
      objectList: list,
      listList: listList,
      mapList: mapList,
      recursiveClassList: allNullableTypesList,
      map: map,
      stringMap: stringMap,
      intMap: intMap,
      enumMap: enumMap,
      objectMap: map,
      listMap: listMap,
      mapMap: mapMap,
      recursiveClassMap: allNullableTypesMap,
    );

NativeInteropAllClassesWrapper classWrapperMaker() {
  return NativeInteropAllClassesWrapper(
    allNullableTypes: recursiveNativeInteropAllNullableTypes,
    allNullableTypesWithoutRecursion: genericNativeInteropAllNullableTypesWithoutRecursion,
    allTypes: genericNativeInteropAllTypes,
    classList: allTypesClassList,
    classMap: allTypesClassMap,
    nullableClassList: allNullableTypesWithoutRecursionList,
    nullableClassMap: allNullableTypesWithoutRecursionMap,
  );
}
