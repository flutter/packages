// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';

import 'src/generated/ni_tests.gen.dart';

const int biggerThanBigInt = 3000000000;
const int regularInt = 42;
const double doublePi = 3.14159;

final List<Object> nonNullList = <Object>['Thing 1', 2, true, 3.14];

final List<String> nonNullStringList = <String>['Thing 1', '2', 'true', '3.14'];

final List<int> nonNullIntList = <int>[1, 2, 3, 4];

final List<double> nonNullDoubleList = <double>[1, 2.99999, 3, 3.14];

final List<bool> nonNullBoolList = <bool>[true, false, true, false];

final List<NIAnEnum> nonNullEnumList = <NIAnEnum>[
  NIAnEnum.one,
  NIAnEnum.two,
  NIAnEnum.three,
  NIAnEnum.fortyTwo,
  NIAnEnum.fourHundredTwentyTwo,
];

final List<List<Object>> nonNullListList = <List<Object>>[
  nonNullList,
  nonNullStringList,
  nonNullIntList,
  nonNullDoubleList,
  nonNullBoolList,
  nonNullEnumList,
];

final Map<Object, Object> nonNullMap = <Object, Object>{
  'a': 1,
  'b': 2.0,
  'c': 'three',
  'd': false,
};

final Map<String, String> nonNullStringMap = <String, String>{
  'a': '1',
  'b': '2.0',
  'c': 'three',
  'd': 'false',
};

final Map<int, int> nonNullIntMap = <int, int>{0: 0, 1: 1, 2: 3, 4: -1};

final Map<double, double> nonNullDoubleMap = <double, double>{
  0.0: 0,
  1.1: 2.0,
  3: 0.3,
  -.4: -0.2,
};

final Map<int, bool> nonNullBoolMap = <int, bool>{0: true, 1: false, 2: true};

final Map<NIAnEnum, NIAnEnum> nonNullEnumMap = <NIAnEnum, NIAnEnum>{
  NIAnEnum.one: NIAnEnum.one,
  NIAnEnum.two: NIAnEnum.two,
  NIAnEnum.three: NIAnEnum.three,
  NIAnEnum.fortyTwo: NIAnEnum.fortyTwo,
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

final List<String?> stringList = <String?>[
  'Thing 1',
  '2',
  'true',
  '3.14',
  null,
];

final List<int?> intList = <int?>[1, 2, 3, 4, null];

final List<double?> doubleList = <double?>[1, 2.99999, 3, 3.14, null];

final List<bool?> boolList = <bool?>[true, false, true, false, null];

final List<NIAnEnum?> enumList = <NIAnEnum?>[
  NIAnEnum.one,
  NIAnEnum.two,
  NIAnEnum.three,
  NIAnEnum.fortyTwo,
  NIAnEnum.fourHundredTwentyTwo,
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
  // 'e': null
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

final Map<int?, bool?> boolMap = <int?, bool?>{
  0: true,
  1: false,
  2: true,
  3: null,
};

final Map<NIAnEnum?, NIAnEnum?> enumMap = <NIAnEnum?, NIAnEnum?>{
  NIAnEnum.one: NIAnEnum.one,
  NIAnEnum.two: NIAnEnum.two,
  NIAnEnum.three: NIAnEnum.three,
  NIAnEnum.fortyTwo: NIAnEnum.fortyTwo,
  NIAnEnum.fourHundredTwentyTwo: null,
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

final NIAllNullableTypesWithoutRecursion
genericNIAllNullableTypesWithoutRecursion = NIAllNullableTypesWithoutRecursion(
  aNullableBool: true,
  aNullableInt: regularInt,
  aNullableInt64: biggerThanBigInt,
  aNullableDouble: doublePi,
  aNullableString: 'Hello host!',
  aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
  aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
  aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
  aNullableFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
  aNullableEnum: NIAnEnum.fourHundredTwentyTwo,
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

final List<NIAllNullableTypesWithoutRecursion?>
allNullableTypesWithoutRecursionList = <NIAllNullableTypesWithoutRecursion?>[
  genericNIAllNullableTypesWithoutRecursion,
  NIAllNullableTypesWithoutRecursion(),
  null,
];

final Map<int, NIAllNullableTypesWithoutRecursion?>
allNullableTypesWithoutRecursionMap =
    <int, NIAllNullableTypesWithoutRecursion?>{
      0: genericNIAllNullableTypesWithoutRecursion,
      1: NIAllNullableTypesWithoutRecursion(),
      2: null,
    };

final NIAllTypes genericNIAllTypes = NIAllTypes(
  aBool: true,
  anInt: regularInt,
  anInt64: biggerThanBigInt,
  aDouble: doublePi,
  aString: 'Hello host!',
  aByteArray: Uint8List.fromList(<int>[1, 2, 3]),
  a4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
  a8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
  aFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
  anEnum: NIAnEnum.fortyTwo,
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

final List<NIAllTypes?> allTypesClassList = <NIAllTypes?>[
  genericNIAllTypes,
  null,
];

final Map<int, NIAllTypes?> allTypesClassMap = <int, NIAllTypes?>{
  0: genericNIAllTypes,
  1: null,
};

// final NIAllNullableTypes genericNIAllNullableTypes = NIAllNullableTypes(
//   aNullableBool: true,
//   aNullableInt: regularInt,
//   aNullableInt64: biggerThanBigInt,
//   aNullableDouble: doublePi,
//   aNullableString: 'Hello host!',
//   // aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
//   // aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
//   // aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
//   // aNullableFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
//   aNullableEnum: NIAnEnum.fourHundredTwentyTwo,
//   aNullableObject: 0,
//   list: list,
//   stringList: stringList,
//   intList: intList,
//   doubleList: doubleList,
//   boolList: boolList,
//   enumList: enumList,
//   objectList: list,
//   listList: listList,
//   mapList: mapList,
//   map: map,
//   stringMap: stringMap,
//   intMap: intMap,
//   enumMap: enumMap,
//   objectMap: map,
//   listMap: listMap,
//   mapMap: mapMap,
// );

// final List<NIAllNullableTypes> nonNullNIAllNullableTypesList =
//     <NIAllNullableTypes>[
//   genericNIAllNullableTypes,
//   NIAllNullableTypes(),
// ];

// final Map<int, NIAllNullableTypes> nonNullNIAllNullableTypesMap =
//     <int, NIAllNullableTypes>{
//   0: genericNIAllNullableTypes,
//   1: NIAllNullableTypes(),
// };

final List<NIAllNullableTypesWithoutRecursion>
nonNullNIAllNullableTypesWithoutRecursionList =
    <NIAllNullableTypesWithoutRecursion>[
      genericNIAllNullableTypesWithoutRecursion,
      NIAllNullableTypesWithoutRecursion(),
    ];

final Map<int, NIAllNullableTypesWithoutRecursion>
nonNullNIAllNullableTypesWithoutRecursionMap =
    <int, NIAllNullableTypesWithoutRecursion>{
      0: genericNIAllNullableTypesWithoutRecursion,
      1: NIAllNullableTypesWithoutRecursion(),
    };

// final List<NIAllNullableTypes?> allNullableTypesList = <NIAllNullableTypes?>[
//   genericNIAllNullableTypes,
//   NIAllNullableTypes(),
//   null,
// ];

// final List<NIAllNullableTypes?>
// allNullableTypesList = <NIAllNullableTypes?>[
//   genericNIAllNullableTypes,
//   NIAllNullableTypes(),
//   null,
// ];

// final Map<int, NIAllNullableTypes?> allNullableTypesMap =
//     <int, NIAllNullableTypes?>{
//   0: genericNIAllNullableTypes,
//   1: NIAllNullableTypes(),
//   2: null,
// };

// final NIAllNullableTypes recursiveNIAllNullableTypes = NIAllNullableTypes(
//   aNullableBool: true,
//   aNullableInt: regularInt,
//   aNullableInt64: biggerThanBigInt,
//   aNullableDouble: doublePi,
//   aNullableString: 'Hello host!',
//   // aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
//   // aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
//   // aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
//   // aNullableFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
//   aNullableEnum: NIAnEnum.fourHundredTwentyTwo,
//   aNullableObject: 0,
//   allNullableTypes: genericNIAllNullableTypes,
//   list: list,
//   stringList: stringList,
//   intList: intList,
//   doubleList: doubleList,
//   boolList: boolList,
//   enumList: enumList,
//   objectList: list,
//   listList: listList,
//   mapList: mapList,
//   recursiveClassList: allNullableTypesList,
//   map: map,
//   stringMap: stringMap,
//   intMap: intMap,
//   enumMap: enumMap,
//   objectMap: map,
//   listMap: listMap,
//   mapMap: mapMap,
//   recursiveClassMap: allNullableTypesMap,
// );

NIAllClassesWrapper classWrapperMaker() {
  return NIAllClassesWrapper(
    //     allNullableTypes: recursiveNIAllNullableTypes,
    allNullableTypesWithoutRecursion: genericNIAllNullableTypesWithoutRecursion,
    allTypes: genericNIAllTypes,
    classList: allTypesClassList,
    classMap: allTypesClassMap,
    nullableClassList: allNullableTypesWithoutRecursionList,
    nullableClassMap: allNullableTypesWithoutRecursionMap,
  );
}
