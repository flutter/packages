// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated.dart';

const int biggerThanBigInt = 3000000000;
const int regularInt = 42;
const double doublePi = 3.14159;

void compareComplexLists(List<dynamic>? listOne, List<dynamic>? listTwo) {
  expect(listOne == null, listTwo == null);
  if (listOne == null || listTwo == null) {
    return;
  }
  expect(listOne.length, listTwo.length);
  for (int i = 0; i < listOne.length; i++) {
    if (listOne[i] is List) {
      compareComplexLists(
          listOne[i] as List<dynamic>, listTwo[i] as List<dynamic>);
    } else if (listOne[i] is Map) {
      compareComplexMaps(listOne[i] as Map<dynamic, dynamic>,
          listTwo[i] as Map<dynamic, dynamic>);
    } else if (listOne[i] is AllTypes) {
      compareAllTypes(listOne[i] as AllTypes, listTwo[i] as AllTypes);
    } else if (listOne[i] is AllNullableTypes) {
      compareAllNullableTypes(
          listOne[i] as AllNullableTypes, listTwo[i] as AllNullableTypes);
    } else if (listOne[i] is AllNullableTypesWithoutRecursion) {
      compareAllNullableTypesWithoutRecursion(
          listOne[i] as AllNullableTypesWithoutRecursion,
          listTwo[i] as AllNullableTypesWithoutRecursion);
    } else if (listOne[i] is AllClassesWrapper) {
      compareAllClassesWrapper(
          listOne[i] as AllClassesWrapper, listTwo[i] as AllClassesWrapper);
    } else {
      expect(listOne[i], listTwo[i]);
    }
  }
}

void compareComplexMaps(
    Map<dynamic, dynamic>? mapOne, Map<dynamic, dynamic>? mapTwo) {
  expect(mapOne == null, mapTwo == null);
  if (mapOne == null || mapTwo == null) {
    return;
  }
  expect(mapOne.length, mapTwo.length);
  for (final dynamic key in mapOne.keys) {
    if (mapOne[key] is List) {
      compareComplexLists(
          mapOne[key] as List<dynamic>, mapTwo[key] as List<dynamic>);
    } else if (mapOne[key] is Map) {
      compareComplexMaps(mapOne[key] as Map<dynamic, dynamic>,
          mapTwo[key] as Map<dynamic, dynamic>);
    } else if (mapOne[key] is AllTypes) {
      compareAllTypes(mapOne[key] as AllTypes, mapTwo[key] as AllTypes);
    } else if (mapOne[key] is AllNullableTypes) {
      compareAllNullableTypes(
          mapOne[key] as AllNullableTypes, mapTwo[key] as AllNullableTypes);
    } else if (mapOne[key] is AllNullableTypesWithoutRecursion) {
      compareAllNullableTypesWithoutRecursion(
          mapOne[key] as AllNullableTypesWithoutRecursion,
          mapTwo[key] as AllNullableTypesWithoutRecursion);
    } else if (mapOne[key] is AllClassesWrapper) {
      compareAllClassesWrapper(
          mapOne[key] as AllClassesWrapper, mapTwo[key] as AllClassesWrapper);
    } else {
      expect(mapOne[key], mapTwo[key]);
    }
  }
}

void compareAllNullableTypesWithoutRecursion(
    AllNullableTypesWithoutRecursion? allNullableTypesOne,
    AllNullableTypesWithoutRecursion? allNullableTypesTwo) {
  expect(allNullableTypesOne == null, allNullableTypesTwo == null);
  if (allNullableTypesOne == null || allNullableTypesTwo == null) {
    return;
  }
  expect(allNullableTypesOne.aNullableBool, allNullableTypesTwo.aNullableBool);
  expect(allNullableTypesOne.aNullableInt, allNullableTypesTwo.aNullableInt);
  expect(
      allNullableTypesOne.aNullableInt64, allNullableTypesTwo.aNullableInt64);
  expect(
      allNullableTypesOne.aNullableDouble, allNullableTypesTwo.aNullableDouble);
  expect(
      allNullableTypesOne.aNullableString, allNullableTypesTwo.aNullableString);
  expect(allNullableTypesOne.aNullableByteArray,
      allNullableTypesTwo.aNullableByteArray);
  expect(allNullableTypesOne.aNullable4ByteArray,
      allNullableTypesTwo.aNullable4ByteArray);
  expect(allNullableTypesOne.aNullable8ByteArray,
      allNullableTypesTwo.aNullable8ByteArray);
  expect(allNullableTypesOne.aNullableFloatArray,
      allNullableTypesTwo.aNullableFloatArray);
  expect(
      allNullableTypesOne.aNullableObject, allNullableTypesTwo.aNullableObject);
  expect(allNullableTypesOne.aNullableEnum, allNullableTypesTwo.aNullableEnum);
  compareComplexLists(allNullableTypesOne.list, allNullableTypesTwo.list);
  compareComplexLists(
      allNullableTypesOne.stringList, allNullableTypesTwo.stringList);
  compareComplexLists(
      allNullableTypesOne.boolList, allNullableTypesTwo.boolList);
  compareComplexLists(
      allNullableTypesOne.doubleList, allNullableTypesTwo.doubleList);
  compareComplexLists(allNullableTypesOne.intList, allNullableTypesTwo.intList);
  compareComplexLists(
      allNullableTypesOne.enumList, allNullableTypesTwo.enumList);
  compareComplexLists(
      allNullableTypesOne.objectList, allNullableTypesTwo.objectList);
  compareComplexLists(
      allNullableTypesOne.listList, allNullableTypesTwo.listList);
  compareComplexLists(allNullableTypesOne.mapList, allNullableTypesTwo.mapList);
  compareComplexMaps(allNullableTypesOne.map, allNullableTypesTwo.map);
  compareComplexMaps(
      allNullableTypesOne.stringMap, allNullableTypesTwo.stringMap);
  compareComplexMaps(allNullableTypesOne.intMap, allNullableTypesTwo.intMap);
  compareComplexMaps(allNullableTypesOne.enumMap, allNullableTypesTwo.enumMap);
  compareComplexMaps(
      allNullableTypesOne.objectMap, allNullableTypesTwo.objectMap);
  compareComplexMaps(allNullableTypesOne.listMap, allNullableTypesTwo.listMap);
  compareComplexMaps(allNullableTypesOne.mapMap, allNullableTypesTwo.mapMap);
}

void compareAllTypes(AllTypes? allTypesOne, AllTypes? allTypesTwo) {
  expect(allTypesOne == null, allTypesTwo == null);
  if (allTypesOne == null || allTypesTwo == null) {
    return;
  }
  expect(allTypesOne.aBool, allTypesTwo.aBool);
  expect(allTypesOne.anInt, allTypesTwo.anInt);
  expect(allTypesOne.anInt64, allTypesTwo.anInt64);
  expect(allTypesOne.aDouble, allTypesTwo.aDouble);
  expect(allTypesOne.aString, allTypesTwo.aString);
  expect(allTypesOne.aByteArray, allTypesTwo.aByteArray);
  expect(allTypesOne.a4ByteArray, allTypesTwo.a4ByteArray);
  expect(allTypesOne.a8ByteArray, allTypesTwo.a8ByteArray);
  expect(allTypesOne.aFloatArray, allTypesTwo.aFloatArray);
  expect(allTypesOne.anEnum, allTypesTwo.anEnum);
  expect(allTypesOne.anObject, allTypesTwo.anObject);
  compareComplexLists(allTypesOne.list, allTypesTwo.list);
  compareComplexLists(allTypesOne.stringList, allTypesTwo.stringList);
  compareComplexLists(allTypesOne.boolList, allTypesTwo.boolList);
  compareComplexLists(allTypesOne.doubleList, allTypesTwo.doubleList);
  compareComplexLists(allTypesOne.intList, allTypesTwo.intList);
  compareComplexLists(allTypesOne.enumList, allTypesTwo.enumList);
  compareComplexLists(allTypesOne.objectList, allTypesTwo.objectList);
  compareComplexLists(allTypesOne.listList, allTypesTwo.listList);
  compareComplexLists(allTypesOne.mapList, allTypesTwo.mapList);
  compareComplexMaps(allTypesOne.map, allTypesTwo.map);
  compareComplexMaps(allTypesOne.stringMap, allTypesTwo.stringMap);
  compareComplexMaps(allTypesOne.intMap, allTypesTwo.intMap);
  compareComplexMaps(allTypesOne.enumMap, allTypesTwo.enumMap);
  compareComplexMaps(allTypesOne.objectMap, allTypesTwo.objectMap);
  compareComplexMaps(allTypesOne.listMap, allTypesTwo.listMap);
  compareComplexMaps(allTypesOne.mapMap, allTypesTwo.mapMap);
}

void compareAllNullableTypes(AllNullableTypes? allNullableTypesOne,
    AllNullableTypes? allNullableTypesTwo) {
  expect(allNullableTypesOne == null, allNullableTypesTwo == null);
  if (allNullableTypesOne == null || allNullableTypesTwo == null) {
    return;
  }
  expect(allNullableTypesOne.aNullableBool, allNullableTypesTwo.aNullableBool);
  expect(allNullableTypesOne.aNullableInt, allNullableTypesTwo.aNullableInt);
  expect(
      allNullableTypesOne.aNullableInt64, allNullableTypesTwo.aNullableInt64);
  expect(
      allNullableTypesOne.aNullableDouble, allNullableTypesTwo.aNullableDouble);
  expect(
      allNullableTypesOne.aNullableString, allNullableTypesTwo.aNullableString);
  expect(allNullableTypesOne.aNullableByteArray,
      allNullableTypesTwo.aNullableByteArray);
  expect(allNullableTypesOne.aNullable4ByteArray,
      allNullableTypesTwo.aNullable4ByteArray);
  expect(allNullableTypesOne.aNullable8ByteArray,
      allNullableTypesTwo.aNullable8ByteArray);
  expect(allNullableTypesOne.aNullableFloatArray,
      allNullableTypesTwo.aNullableFloatArray);
  expect(
      allNullableTypesOne.aNullableObject, allNullableTypesTwo.aNullableObject);
  expect(allNullableTypesOne.aNullableEnum, allNullableTypesTwo.aNullableEnum);
  compareAllNullableTypes(allNullableTypesOne.allNullableTypes,
      allNullableTypesTwo.allNullableTypes);
  compareComplexLists(allNullableTypesOne.list, allNullableTypesTwo.list);
  compareComplexLists(
      allNullableTypesOne.stringList, allNullableTypesTwo.stringList);
  compareComplexLists(
      allNullableTypesOne.boolList, allNullableTypesTwo.boolList);
  compareComplexLists(
      allNullableTypesOne.doubleList, allNullableTypesTwo.doubleList);
  compareComplexLists(allNullableTypesOne.intList, allNullableTypesTwo.intList);
  compareComplexLists(
      allNullableTypesOne.enumList, allNullableTypesTwo.enumList);
  compareComplexLists(
      allNullableTypesOne.objectList, allNullableTypesTwo.objectList);
  compareComplexLists(
      allNullableTypesOne.listList, allNullableTypesTwo.listList);
  compareComplexLists(allNullableTypesOne.recursiveClassList,
      allNullableTypesTwo.recursiveClassList);
  compareComplexLists(allNullableTypesOne.mapList, allNullableTypesTwo.mapList);
  compareComplexMaps(allNullableTypesOne.map, allNullableTypesTwo.map);
  compareComplexMaps(
      allNullableTypesOne.stringMap, allNullableTypesTwo.stringMap);
  compareComplexMaps(allNullableTypesOne.intMap, allNullableTypesTwo.intMap);
  compareComplexMaps(allNullableTypesOne.enumMap, allNullableTypesTwo.enumMap);
  compareComplexMaps(
      allNullableTypesOne.objectMap, allNullableTypesTwo.objectMap);
  compareComplexMaps(allNullableTypesOne.listMap, allNullableTypesTwo.listMap);
  compareComplexMaps(allNullableTypesOne.mapMap, allNullableTypesTwo.mapMap);
  compareComplexMaps(allNullableTypesOne.recursiveClassMap,
      allNullableTypesTwo.recursiveClassMap);
}

void compareAllClassesWrapper(
    AllClassesWrapper? wrapperOne, AllClassesWrapper? wrapperTwo) {
  expect(wrapperOne == null, wrapperTwo == null);
  if (wrapperOne == null || wrapperTwo == null) {
    return;
  }

  compareAllNullableTypes(
      wrapperOne.allNullableTypes, wrapperTwo.allNullableTypes);
  compareAllNullableTypesWithoutRecursion(
    wrapperOne.allNullableTypesWithoutRecursion,
    wrapperTwo.allNullableTypesWithoutRecursion,
  );
  compareAllTypes(wrapperOne.allTypes, wrapperTwo.allTypes);

  for (int i = 0; i < (wrapperOne.classList.length); i++) {
    compareAllTypes(wrapperOne.classList[i], wrapperTwo.classList[i]);
  }

  for (int i = 0; i < (wrapperOne.nullableClassList?.length ?? 0); i++) {
    compareAllNullableTypesWithoutRecursion(
        wrapperOne.nullableClassList![i], wrapperTwo.nullableClassList![i]);
  }
  compareComplexMaps(wrapperOne.classMap, wrapperTwo.classMap);
  compareComplexMaps(wrapperOne.nullableClassMap, wrapperTwo.nullableClassMap);
}

final List<Object> nonNullList = <Object>[
  'Thing 1',
  2,
  true,
  3.14,
];

final List<String> nonNullStringList = <String>[
  'Thing 1',
  '2',
  'true',
  '3.14',
];

final List<int> nonNullIntList = <int>[
  1,
  2,
  3,
  4,
];

final List<double> nonNullDoubleList = <double>[
  1,
  2.99999,
  3,
  3.14,
];

final List<bool> nonNullBoolList = <bool>[
  true,
  false,
  true,
  false,
];

final List<AnEnum> nonNullEnumList = <AnEnum>[
  AnEnum.one,
  AnEnum.two,
  AnEnum.three,
  AnEnum.fortyTwo,
  AnEnum.fourHundredTwentyTwo,
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

final Map<int, int> nonNullIntMap = <int, int>{
  0: 0,
  1: 1,
  2: 3,
  4: -1,
};

final Map<double, double> nonNullDoubleMap = <double, double>{
  0.0: 0,
  1.1: 2.0,
  3: 0.3,
  -.4: -0.2,
};

final Map<int, bool> nonNullBoolMap = <int, bool>{
  0: true,
  1: false,
  2: true,
};

final Map<AnEnum, AnEnum> nonNullEnumMap = <AnEnum, AnEnum>{
  AnEnum.one: AnEnum.one,
  AnEnum.two: AnEnum.two,
  AnEnum.three: AnEnum.three,
  AnEnum.fortyTwo: AnEnum.fortyTwo,
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

final List<Object?> list = <Object?>[
  'Thing 1',
  2,
  true,
  3.14,
  null,
];

final List<String?> stringList = <String?>[
  'Thing 1',
  '2',
  'true',
  '3.14',
  null,
];

final List<int?> intList = <int?>[
  1,
  2,
  3,
  4,
  null,
];

final List<double?> doubleList = <double?>[
  1,
  2.99999,
  3,
  3.14,
  null,
];

final List<bool?> boolList = <bool?>[
  true,
  false,
  true,
  false,
  null,
];

final List<AnEnum?> enumList = <AnEnum?>[
  AnEnum.one,
  AnEnum.two,
  AnEnum.three,
  AnEnum.fortyTwo,
  AnEnum.fourHundredTwentyTwo,
  null
];

final List<List<Object?>?> listList = <List<Object?>?>[
  list,
  stringList,
  intList,
  doubleList,
  boolList,
  enumList,
  null
];

final Map<Object?, Object?> map = <Object?, Object?>{
  'a': 1,
  'b': 2.0,
  'c': 'three',
  'd': false,
  'e': null
};

final Map<String?, String?> stringMap = <String?, String?>{
  'a': '1',
  'b': '2.0',
  'c': 'three',
  'd': 'false',
  'e': 'null',
  'f': null
};

final Map<int?, int?> intMap = <int?, int?>{
  0: 0,
  1: 1,
  2: 3,
  4: -1,
  5: null,
};

final Map<double?, double?> doubleMap = <double?, double?>{
  0.0: 0,
  1.1: 2.0,
  3: 0.3,
  -.4: -0.2,
  1111111111111111.11111111111111111111111111111111111111111111: null
};

final Map<int?, bool?> boolMap = <int?, bool?>{
  0: true,
  1: false,
  2: true,
  3: null,
};

final Map<AnEnum?, AnEnum?> enumMap = <AnEnum?, AnEnum?>{
  AnEnum.one: AnEnum.one,
  AnEnum.two: AnEnum.two,
  AnEnum.three: AnEnum.three,
  AnEnum.fortyTwo: AnEnum.fortyTwo,
  AnEnum.fourHundredTwentyTwo: null,
};

final Map<int?, List<Object?>?> listMap = <int?, List<Object?>?>{
  0: list,
  1: stringList,
  2: doubleList,
  4: intList,
  5: boolList,
  6: enumList,
  7: null
};

final Map<int?, Map<Object?, Object?>?> mapMap = <int?, Map<Object?, Object?>?>{
  0: map,
  1: stringMap,
  2: doubleMap,
  4: intMap,
  5: boolMap,
  6: enumMap,
  7: null
};

final List<Map<Object?, Object?>?> mapList = <Map<Object?, Object?>?>[
  map,
  stringMap,
  doubleMap,
  intMap,
  boolMap,
  enumMap,
  null
];

final AllNullableTypesWithoutRecursion genericAllNullableTypesWithoutRecursion =
    AllNullableTypesWithoutRecursion(
  aNullableBool: true,
  aNullableInt: regularInt,
  aNullableInt64: biggerThanBigInt,
  aNullableDouble: doublePi,
  aNullableString: 'Hello host!',
  aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
  aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
  aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
  aNullableFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
  aNullableEnum: AnEnum.fourHundredTwentyTwo,
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

final List<AllNullableTypesWithoutRecursion?>
    allNullableTypesWithoutRecursionClassList =
    <AllNullableTypesWithoutRecursion?>[
  genericAllNullableTypesWithoutRecursion,
  AllNullableTypesWithoutRecursion(),
  null,
];

final Map<int, AllNullableTypesWithoutRecursion?>
    allNullableTypesWithoutRecursionClassMap =
    <int, AllNullableTypesWithoutRecursion?>{
  0: genericAllNullableTypesWithoutRecursion,
  1: AllNullableTypesWithoutRecursion(),
  2: null,
};

final AllTypes genericAllTypes = AllTypes(
  aBool: true,
  anInt: regularInt,
  anInt64: biggerThanBigInt,
  aDouble: doublePi,
  aString: 'Hello host!',
  aByteArray: Uint8List.fromList(<int>[1, 2, 3]),
  a4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
  a8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
  aFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
  anEnum: AnEnum.fortyTwo,
  anObject: 1,
  list: list,
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

final List<AllTypes?> allTypesClassList = <AllTypes?>[
  genericAllTypes,
  null,
];

final Map<int, AllTypes?> allTypesClassMap = <int, AllTypes?>{
  0: genericAllTypes,
  1: null,
};

final AllNullableTypes genericAllNullableTypes = AllNullableTypes(
  aNullableBool: true,
  aNullableInt: regularInt,
  aNullableInt64: biggerThanBigInt,
  aNullableDouble: doublePi,
  aNullableString: 'Hello host!',
  aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
  aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
  aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
  aNullableFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
  aNullableEnum: AnEnum.fourHundredTwentyTwo,
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

final List<AllNullableTypes> nonNullAllNullableTypesList = <AllNullableTypes>[
  genericAllNullableTypes,
  AllNullableTypes(),
];

final Map<int, AllNullableTypes> nonNullAllNullableTypesMap =
    <int, AllNullableTypes>{
  0: genericAllNullableTypes,
  1: AllNullableTypes(),
};

final List<AllNullableTypes?> allNullableTypesList = <AllNullableTypes?>[
  genericAllNullableTypes,
  AllNullableTypes(),
  null,
];

final Map<int, AllNullableTypes?> allNullableTypesMap =
    <int, AllNullableTypes?>{
  0: genericAllNullableTypes,
  1: AllNullableTypes(),
  2: null,
};

final AllNullableTypes recursiveAllNullableTypes = AllNullableTypes(
  aNullableBool: true,
  aNullableInt: regularInt,
  aNullableInt64: biggerThanBigInt,
  aNullableDouble: doublePi,
  aNullableString: 'Hello host!',
  aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
  aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
  aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
  aNullableFloatArray: Float64List.fromList(<double>[2.71828, doublePi]),
  aNullableEnum: AnEnum.fourHundredTwentyTwo,
  aNullableObject: 0,
  allNullableTypes: genericAllNullableTypes,
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

AllClassesWrapper classWrapperMaker() {
  return AllClassesWrapper(
    allNullableTypes: recursiveAllNullableTypes,
    allNullableTypesWithoutRecursion: genericAllNullableTypesWithoutRecursion,
    allTypes: genericAllTypes,
    classList: allTypesClassList,
    classMap: allTypesClassMap,
    nullableClassList: allNullableTypesWithoutRecursionClassList,
    nullableClassMap: allNullableTypesWithoutRecursionClassMap,
  );
}
