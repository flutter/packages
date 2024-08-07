// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'generated.dart';

const int _biggerThanBigInt = 3000000000;
const int _regularInt = 42;
const double _doublePi = 3.14159;

/// Possible host languages that test can target.
enum TargetGenerator {
  /// The Windows C++ generator.
  cpp,

  /// The Linux GObject generator.
  gobject,

  /// The Android Java generator.
  java,

  /// The Android Kotlin generator.
  kotlin,

  /// The iOS Objective-C generator.
  objc,

  /// The iOS or macOS Swift generator.
  swift,
}

/// Sets up and runs the integration tests.
void runPigeonIntegrationTests(TargetGenerator targetGenerator) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
    expect(listEquals(allTypesOne.list, allTypesTwo.list), true);
    expect(listEquals(allTypesOne.stringList, allTypesTwo.stringList), true);
    expect(listEquals(allTypesOne.boolList, allTypesTwo.boolList), true);
    expect(listEquals(allTypesOne.doubleList, allTypesTwo.doubleList), true);
    expect(listEquals(allTypesOne.intList, allTypesTwo.intList), true);
    expect(mapEquals(allTypesOne.map, allTypesTwo.map), true);
  }

  void compareAllNullableTypes(AllNullableTypes? allNullableTypesOne,
      AllNullableTypes? allNullableTypesTwo) {
    expect(allNullableTypesOne == null, allNullableTypesTwo == null);
    if (allNullableTypesOne == null || allNullableTypesTwo == null) {
      return;
    }
    expect(
        allNullableTypesOne.aNullableBool, allNullableTypesTwo.aNullableBool);
    expect(allNullableTypesOne.aNullableInt, allNullableTypesTwo.aNullableInt);
    expect(
        allNullableTypesOne.aNullableInt64, allNullableTypesTwo.aNullableInt64);
    expect(allNullableTypesOne.aNullableDouble,
        allNullableTypesTwo.aNullableDouble);
    expect(allNullableTypesOne.aNullableString,
        allNullableTypesTwo.aNullableString);
    expect(allNullableTypesOne.aNullableByteArray,
        allNullableTypesTwo.aNullableByteArray);
    expect(allNullableTypesOne.aNullable4ByteArray,
        allNullableTypesTwo.aNullable4ByteArray);
    expect(allNullableTypesOne.aNullable8ByteArray,
        allNullableTypesTwo.aNullable8ByteArray);
    expect(allNullableTypesOne.aNullableFloatArray,
        allNullableTypesTwo.aNullableFloatArray);
    expect(allNullableTypesOne.nullableNestedList?.length,
        allNullableTypesTwo.nullableNestedList?.length);
    // TODO(stuartmorgan): Enable this once the Dart types are fixed; see
    // https://github.com/flutter/flutter/issues/116117
    //for (int i = 0; i < allNullableTypesOne.nullableNestedList!.length; i++) {
    //  expect(listEquals(allNullableTypesOne.nullableNestedList![i], allNullableTypesTwo.nullableNestedList![i]),
    //      true);
    //}
    expect(
        mapEquals(allNullableTypesOne.nullableMapWithAnnotations,
            allNullableTypesTwo.nullableMapWithAnnotations),
        true);
    expect(
        mapEquals(allNullableTypesOne.nullableMapWithObject,
            allNullableTypesTwo.nullableMapWithObject),
        true);
    expect(allNullableTypesOne.aNullableObject,
        allNullableTypesTwo.aNullableObject);
    expect(
        allNullableTypesOne.aNullableEnum, allNullableTypesTwo.aNullableEnum);
    compareAllNullableTypes(allNullableTypesOne.allNullableTypes,
        allNullableTypesTwo.allNullableTypes);
    expect(
        listEquals(allNullableTypesOne.list, allNullableTypesTwo.list), true);
    expect(
        listEquals(
            allNullableTypesOne.stringList, allNullableTypesTwo.stringList),
        true);
    expect(
        listEquals(allNullableTypesOne.boolList, allNullableTypesTwo.boolList),
        true);
    expect(
        listEquals(
            allNullableTypesOne.doubleList, allNullableTypesTwo.doubleList),
        true);
    expect(listEquals(allNullableTypesOne.intList, allNullableTypesTwo.intList),
        true);
    expect(allNullableTypesOne.nestedClassList?.length,
        allNullableTypesTwo.nestedClassList?.length);
    for (int i = 0;
        i < (allNullableTypesOne.nestedClassList?.length ?? 0);
        i++) {
      compareAllNullableTypes(allNullableTypesOne.nestedClassList?[i],
          allNullableTypesTwo.nestedClassList?[i]);
    }
    expect(mapEquals(allNullableTypesOne.map, allNullableTypesTwo.map), true);
  }

  void compareAllNullableTypesWithoutRecursion(
      AllNullableTypesWithoutRecursion? allNullableTypesOne,
      AllNullableTypesWithoutRecursion? allNullableTypesTwo) {
    expect(allNullableTypesOne == null, allNullableTypesTwo == null);
    if (allNullableTypesOne == null || allNullableTypesTwo == null) {
      return;
    }
    expect(
        allNullableTypesOne.aNullableBool, allNullableTypesTwo.aNullableBool);
    expect(allNullableTypesOne.aNullableInt, allNullableTypesTwo.aNullableInt);
    expect(
        allNullableTypesOne.aNullableInt64, allNullableTypesTwo.aNullableInt64);
    expect(allNullableTypesOne.aNullableDouble,
        allNullableTypesTwo.aNullableDouble);
    expect(allNullableTypesOne.aNullableString,
        allNullableTypesTwo.aNullableString);
    expect(allNullableTypesOne.aNullableByteArray,
        allNullableTypesTwo.aNullableByteArray);
    expect(allNullableTypesOne.aNullable4ByteArray,
        allNullableTypesTwo.aNullable4ByteArray);
    expect(allNullableTypesOne.aNullable8ByteArray,
        allNullableTypesTwo.aNullable8ByteArray);
    expect(allNullableTypesOne.aNullableFloatArray,
        allNullableTypesTwo.aNullableFloatArray);
    expect(allNullableTypesOne.nullableNestedList?.length,
        allNullableTypesTwo.nullableNestedList?.length);
    // TODO(stuartmorgan): Enable this once the Dart types are fixed; see
    // https://github.com/flutter/flutter/issues/116117
    //for (int i = 0; i < allNullableTypesOne.nullableNestedList!.length; i++) {
    //  expect(listEquals(allNullableTypesOne.nullableNestedList![i], allNullableTypesTwo.nullableNestedList![i]),
    //      true);
    //}
    expect(
        mapEquals(allNullableTypesOne.nullableMapWithAnnotations,
            allNullableTypesTwo.nullableMapWithAnnotations),
        true);
    expect(
        mapEquals(allNullableTypesOne.nullableMapWithObject,
            allNullableTypesTwo.nullableMapWithObject),
        true);
    expect(allNullableTypesOne.aNullableObject,
        allNullableTypesTwo.aNullableObject);
    expect(
        allNullableTypesOne.aNullableEnum, allNullableTypesTwo.aNullableEnum);
    expect(
        listEquals(allNullableTypesOne.list, allNullableTypesTwo.list), true);
    expect(
        listEquals(
            allNullableTypesOne.stringList, allNullableTypesTwo.stringList),
        true);
    expect(
        listEquals(allNullableTypesOne.boolList, allNullableTypesTwo.boolList),
        true);
    expect(
        listEquals(
            allNullableTypesOne.doubleList, allNullableTypesTwo.doubleList),
        true);
    expect(listEquals(allNullableTypesOne.intList, allNullableTypesTwo.intList),
        true);
    expect(mapEquals(allNullableTypesOne.map, allNullableTypesTwo.map), true);
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
  }

  final Map<Object?, Object?> map = <Object?, Object?>{
    'a': 1,
    'b': 2.0,
    'c': 'three',
    'd': false,
    'e': null
  };

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

  final AllTypes genericAllTypes = AllTypes(
    aBool: true,
    anInt: _regularInt,
    anInt64: _biggerThanBigInt,
    aDouble: _doublePi,
    aString: 'Hello host!',
    aByteArray: Uint8List.fromList(<int>[1, 2, 3]),
    a4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
    a8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
    aFloatArray: Float64List.fromList(<double>[2.71828, _doublePi]),
    anEnum: AnEnum.fortyTwo,
    anObject: 1,
    list: list,
    stringList: stringList,
    intList: intList,
    doubleList: doubleList,
    boolList: boolList,
    map: map,
  );

  final AllNullableTypes genericAllNullableTypes = AllNullableTypes(
    aNullableBool: true,
    aNullableInt: _regularInt,
    aNullableInt64: _biggerThanBigInt,
    aNullableDouble: _doublePi,
    aNullableString: 'Hello host!',
    aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
    aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
    aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
    aNullableFloatArray: Float64List.fromList(<double>[2.71828, _doublePi]),
    nullableNestedList: <List<bool>>[
      <bool>[true, false],
      <bool>[false, true]
    ],
    nullableMapWithAnnotations: <String?, String?>{},
    nullableMapWithObject: <String?, Object?>{},
    aNullableEnum: AnEnum.fourHundredTwentyTwo,
    aNullableObject: 0,
    list: list,
    stringList: stringList,
    intList: intList,
    doubleList: doubleList,
    boolList: boolList,
    map: map,
  );

  final List<AllNullableTypes?> allNullableTypesList = <AllNullableTypes?>[
    genericAllNullableTypes,
    AllNullableTypes(),
    null,
  ];

  final AllNullableTypes recursiveAllNullableTypes = AllNullableTypes(
    aNullableBool: true,
    aNullableInt: _regularInt,
    aNullableInt64: _biggerThanBigInt,
    aNullableDouble: _doublePi,
    aNullableString: 'Hello host!',
    aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
    aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
    aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
    aNullableFloatArray: Float64List.fromList(<double>[2.71828, _doublePi]),
    nullableNestedList: <List<bool>>[
      <bool>[true, false],
      <bool>[false, true]
    ],
    nullableMapWithAnnotations: <String?, String?>{},
    nullableMapWithObject: <String?, Object?>{},
    aNullableEnum: AnEnum.fourHundredTwentyTwo,
    aNullableObject: 0,
    allNullableTypes: genericAllNullableTypes,
    list: list,
    stringList: stringList,
    intList: intList,
    doubleList: doubleList,
    boolList: boolList,
    nestedClassList: allNullableTypesList,
    map: map,
  );

  final AllNullableTypesWithoutRecursion
      genericAllNullableTypesWithoutRecursion =
      AllNullableTypesWithoutRecursion(
    aNullableBool: true,
    aNullableInt: _regularInt,
    aNullableInt64: _biggerThanBigInt,
    aNullableDouble: _doublePi,
    aNullableString: 'Hello host!',
    aNullableByteArray: Uint8List.fromList(<int>[1, 2, 3]),
    aNullable4ByteArray: Int32List.fromList(<int>[4, 5, 6]),
    aNullable8ByteArray: Int64List.fromList(<int>[7, 8, 9]),
    aNullableFloatArray: Float64List.fromList(<double>[2.71828, _doublePi]),
    nullableNestedList: <List<bool>>[
      <bool>[true, false],
      <bool>[false, true]
    ],
    nullableMapWithAnnotations: <String?, String?>{},
    nullableMapWithObject: <String?, Object?>{},
    aNullableEnum: AnEnum.fourHundredTwentyTwo,
    aNullableObject: 0,
    list: list,
    stringList: stringList,
    intList: intList,
    doubleList: doubleList,
    boolList: boolList,
    map: map,
  );

  group('Host sync API tests', () {
    testWidgets('basic void->void call works', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(api.noop(), completes);
    });

    testWidgets('all datatypes serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllTypes echoObject = await api.echoAllTypes(genericAllTypes);
      compareAllTypes(echoObject, genericAllTypes);
    });

    testWidgets('all nullable datatypes serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes? echoObject =
          await api.echoAllNullableTypes(recursiveAllNullableTypes);

      compareAllNullableTypes(echoObject, recursiveAllNullableTypes);
    });

    testWidgets('all null datatypes serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes allTypesNull = AllNullableTypes();

      final AllNullableTypes? echoNullFilledClass =
          await api.echoAllNullableTypes(allTypesNull);
      compareAllNullableTypes(allTypesNull, echoNullFilledClass);
    });

    testWidgets('Classes with list of null serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes nullableListTypes =
          AllNullableTypes(list: <String?>['String', null]);

      final AllNullableTypes? echoNullFilledClass =
          await api.echoAllNullableTypes(nullableListTypes);

      compareAllNullableTypes(nullableListTypes, echoNullFilledClass);
    });

    testWidgets('Classes with map of null serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes nullableListTypes = AllNullableTypes(
          map: <String?, String?>{'String': 'string', 'null': null});

      final AllNullableTypes? echoNullFilledClass =
          await api.echoAllNullableTypes(nullableListTypes);

      compareAllNullableTypes(nullableListTypes, echoNullFilledClass);
    });

    testWidgets(
        'all nullable datatypes without recursion serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypesWithoutRecursion? echoObject =
          await api.echoAllNullableTypesWithoutRecursion(
              genericAllNullableTypesWithoutRecursion);

      compareAllNullableTypesWithoutRecursion(
          echoObject, genericAllNullableTypesWithoutRecursion);
    });

    testWidgets(
        'all null datatypes without recursion serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypesWithoutRecursion allTypesNull =
          AllNullableTypesWithoutRecursion();

      final AllNullableTypesWithoutRecursion? echoNullFilledClass =
          await api.echoAllNullableTypesWithoutRecursion(allTypesNull);
      compareAllNullableTypesWithoutRecursion(
          allTypesNull, echoNullFilledClass);
    });

    testWidgets(
        'Classes without recursion with list of null serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypesWithoutRecursion nullableListTypes =
          AllNullableTypesWithoutRecursion(
        list: <String?>['String', null],
      );

      final AllNullableTypesWithoutRecursion? echoNullFilledClass =
          await api.echoAllNullableTypesWithoutRecursion(nullableListTypes);

      compareAllNullableTypesWithoutRecursion(
          nullableListTypes, echoNullFilledClass);
    });

    testWidgets(
        'Classes without recursion with map of null serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypesWithoutRecursion nullableListTypes =
          AllNullableTypesWithoutRecursion(
        map: <String?, String?>{'String': 'string', 'null': null},
      );

      final AllNullableTypesWithoutRecursion? echoNullFilledClass =
          await api.echoAllNullableTypesWithoutRecursion(nullableListTypes);

      compareAllNullableTypesWithoutRecursion(
          nullableListTypes, echoNullFilledClass);
    });

    testWidgets('errors are returned correctly', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('errors are returned from void methods correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('flutter errors are returned correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(
          () => api.throwFlutterError(),
          throwsA((dynamic e) =>
              e is PlatformException &&
              e.code == 'code' &&
              e.message == 'message' &&
              e.details == 'details'));
    });

    testWidgets('nested objects can be sent correctly', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllClassesWrapper sentObject = AllClassesWrapper(
          allNullableTypes: recursiveAllNullableTypes,
          allNullableTypesWithoutRecursion:
              genericAllNullableTypesWithoutRecursion,
          allTypes: genericAllTypes);

      final String? receivedString =
          await api.extractNestedNullableString(sentObject);
      expect(receivedString, sentObject.allNullableTypes.aNullableString);
    });

    testWidgets('nested objects can be received correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentString = 'Some string';
      final AllClassesWrapper receivedObject =
          await api.createNestedNullableString(sentString);
      expect(receivedObject.allNullableTypes.aNullableString, sentString);
    });

    testWidgets('nested classes can serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllClassesWrapper sentWrapper = AllClassesWrapper(
        allNullableTypes: AllNullableTypes(),
        allNullableTypesWithoutRecursion: AllNullableTypesWithoutRecursion(),
        allTypes: genericAllTypes,
      );

      final AllClassesWrapper receivedClassWrapper =
          await api.echoClassWrapper(sentWrapper);
      compareAllClassesWrapper(sentWrapper, receivedClassWrapper);
    });

    testWidgets('nested null classes can serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllClassesWrapper sentWrapper = AllClassesWrapper(
        allNullableTypes: AllNullableTypes(),
        allNullableTypesWithoutRecursion: AllNullableTypesWithoutRecursion(),
      );

      final AllClassesWrapper receivedClassWrapper =
          await api.echoClassWrapper(sentWrapper);
      compareAllClassesWrapper(sentWrapper, receivedClassWrapper);
    });

    testWidgets(
        'Arguments of multiple types serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String aNullableString = 'this is a String';
      const bool aNullableBool = false;
      const int aNullableInt = _regularInt;

      final AllNullableTypes echoObject = await api.sendMultipleNullableTypes(
          aNullableBool, aNullableInt, aNullableString);
      expect(echoObject.aNullableInt, aNullableInt);
      expect(echoObject.aNullableBool, aNullableBool);
      expect(echoObject.aNullableString, aNullableString);
    });

    testWidgets(
        'Arguments of multiple null types serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes echoNullFilledClass =
          await api.sendMultipleNullableTypes(null, null, null);
      expect(echoNullFilledClass.aNullableInt, null);
      expect(echoNullFilledClass.aNullableBool, null);
      expect(echoNullFilledClass.aNullableString, null);
    });

    testWidgets(
        'Arguments of multiple types serialize and deserialize correctly (WithoutRecursion)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String aNullableString = 'this is a String';
      const bool aNullableBool = false;
      const int aNullableInt = _regularInt;

      final AllNullableTypesWithoutRecursion echoObject =
          await api.sendMultipleNullableTypesWithoutRecursion(
              aNullableBool, aNullableInt, aNullableString);
      expect(echoObject.aNullableInt, aNullableInt);
      expect(echoObject.aNullableBool, aNullableBool);
      expect(echoObject.aNullableString, aNullableString);
    });

    testWidgets(
        'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypesWithoutRecursion echoNullFilledClass =
          await api.sendMultipleNullableTypesWithoutRecursion(null, null, null);
      expect(echoNullFilledClass.aNullableInt, null);
      expect(echoNullFilledClass.aNullableBool, null);
      expect(echoNullFilledClass.aNullableString, null);
    });

    testWidgets('Int serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const int sentInt = _regularInt;
      final int receivedInt = await api.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = _biggerThanBigInt;
      final int receivedInt = await api.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Doubles serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentDouble = 2.0694;
      final double receivedDouble = await api.echoDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('booleans serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool sentBool in <bool>[true, false]) {
        final bool receivedBool = await api.echoBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String sentString = 'default';
      final String receivedString = await api.echoString(sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Uint8List serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0
      ];
      final Uint8List sentUint8List = Uint8List.fromList(data);
      final Uint8List receivedUint8List =
          await api.echoUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('generic Objects serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const Object sentString = "I'm a computer";
      final Object receivedString = await api.echoObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = _regularInt;
      final Object receivedInt = await api.echoObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const List<Object?> sentObject = <Object>[7, 'Hello Dart!'];
      final List<Object?> echoObject = await api.echoList(sentObject);
      expect(listEquals(echoObject, sentObject), true);
    });

    testWidgets('maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const Map<String?, Object?> sentObject = <String?, Object?>{
        'a': 1,
        'b': 2.3,
        'c': 'four',
      };
      final Map<String?, Object?> echoObject = await api.echoMap(sentObject);
      expect(mapEquals(echoObject, sentObject), true);
    });

    testWidgets('enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.two;
      final AnEnum receivedEnum = await api.echoEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fortyTwo;
      final AnEnum receivedEnum = await api.echoEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('required named parameter', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      // This number corresponds with the default value of this method.
      const int sentInt = _regularInt;
      final int receivedInt = await api.echoRequiredInt(anInt: sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('optional default parameter no arg', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      // This number corresponds with the default value of this method.
      const double sentDouble = 3.14;
      final double receivedDouble = await api.echoOptionalDefaultDouble();
      expect(receivedDouble, sentDouble);
    });

    testWidgets('optional default parameter with arg', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentDouble = 3.15;
      final double receivedDouble =
          await api.echoOptionalDefaultDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('named default parameter no arg', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      // This string corresponds with the default value of this method.
      const String sentString = 'default';
      final String receivedString = await api.echoNamedDefaultString();
      expect(receivedString, sentString);
    });

    testWidgets('named default parameter with arg', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      // This string corresponds with the default value of this method.
      const String sentString = 'notDefault';
      final String receivedString =
          await api.echoNamedDefaultString(aString: sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Nullable Int serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = _regularInt;
      final int? receivedInt = await api.echoNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Nullable Int64 serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = _biggerThanBigInt;
      final int? receivedInt = await api.echoNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null Ints serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final int? receivedNullInt = await api.echoNullableInt(null);
      expect(receivedNullInt, null);
    });

    testWidgets('Nullable Doubles serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentDouble = 2.0694;
      final double? receivedDouble = await api.echoNullableDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('Null Doubles serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final double? receivedNullDouble = await api.echoNullableDouble(null);
      expect(receivedNullDouble, null);
    });

    testWidgets('Nullable booleans serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool? sentBool in <bool?>[true, false]) {
        final bool? receivedBool = await api.echoNullableBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('Null booleans serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const bool? sentBool = null;
      final bool? receivedBool = await api.echoNullableBool(sentBool);
      expect(receivedBool, sentBool);
    });

    testWidgets('Nullable strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String sentString = "I'm a computer";
      final String? receivedString = await api.echoNullableString(sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Null strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final String? receivedNullString = await api.echoNullableString(null);
      expect(receivedNullString, null);
    });

    testWidgets('Nullable Uint8List serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0
      ];
      final Uint8List sentUint8List = Uint8List.fromList(data);
      final Uint8List? receivedUint8List =
          await api.echoNullableUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('Null Uint8List serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Uint8List? receivedNullUint8List =
          await api.echoNullableUint8List(null);
      expect(receivedNullUint8List, null);
    });

    testWidgets('generic nullable Objects serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const Object sentString = "I'm a computer";
      final Object? receivedString = await api.echoNullableObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = _regularInt;
      final Object? receivedInt = await api.echoNullableObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null generic Objects serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Object? receivedNullObject = await api.echoNullableObject(null);
      expect(receivedNullObject, null);
    });

    testWidgets('nullable lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const List<Object?> sentObject = <Object?>[7, 'Hello Dart!', null];
      final List<Object?>? echoObject = await api.echoNullableList(sentObject);
      expect(listEquals(echoObject, sentObject), true);
    });

    testWidgets('nullable maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const Map<String?, Object?> sentObject = <String?, Object?>{
        'a': 1,
        'b': 2.3,
        'c': 'four',
        'd': null,
      };
      final Map<String?, Object?>? echoObject =
          await api.echoNullableMap(sentObject);
      expect(mapEquals(echoObject, sentObject), true);
    });

    testWidgets('nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fourHundredTwentyTwo;
      final AnEnum? echoEnum = await api.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.echoNullableList(null);
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('null maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<String?, Object?>? echoObject = await api.echoNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum? sentEnum = null;
      final AnEnum? echoEnum = await api.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null classes serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes? echoObject = await api.echoAllNullableTypes(null);

      expect(echoObject, isNull);
    });

    testWidgets('optional nullable parameter', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = _regularInt;
      final int? receivedInt = await api.echoOptionalNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null optional nullable parameter', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final int? receivedNullInt = await api.echoOptionalNullableInt();
      expect(receivedNullInt, null);
    });

    testWidgets('named nullable parameter', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String sentString = "I'm a computer";
      final String? receivedString =
          await api.echoNamedNullableString(aNullableString: sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Null named nullable parameter', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final String? receivedNullString = await api.echoNamedNullableString();
      expect(receivedNullString, null);
    });
  });

  group('Host async API tests', () {
    testWidgets('basic void->void call works', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(api.noopAsync(), completes);
    });

    testWidgets('async errors are returned from non void methods correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwAsyncError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('async errors are returned from void methods correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwAsyncErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets(
        'async flutter errors are returned from non void methods correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(
          () => api.throwAsyncFlutterError(),
          throwsA((dynamic e) =>
              e is PlatformException &&
              e.code == 'code' &&
              e.message == 'message' &&
              e.details == 'details'));
    });

    testWidgets('all datatypes async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllTypes echoObject = await api.echoAsyncAllTypes(genericAllTypes);

      compareAllTypes(echoObject, genericAllTypes);
    });

    testWidgets(
        'all nullable async datatypes serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes? echoObject = await api
          .echoAsyncNullableAllNullableTypes(recursiveAllNullableTypes);

      compareAllNullableTypes(echoObject, recursiveAllNullableTypes);
    });

    testWidgets('all null datatypes async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes allTypesNull = AllNullableTypes();

      final AllNullableTypes? echoNullFilledClass =
          await api.echoAsyncNullableAllNullableTypes(allTypesNull);
      compareAllNullableTypes(echoNullFilledClass, allTypesNull);
    });

    testWidgets(
        'all nullable async datatypes without recursion serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypesWithoutRecursion? echoObject =
          await api.echoAsyncNullableAllNullableTypesWithoutRecursion(
              genericAllNullableTypesWithoutRecursion);

      compareAllNullableTypesWithoutRecursion(
          echoObject, genericAllNullableTypesWithoutRecursion);
    });

    testWidgets(
        'all null datatypes without recursion async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypesWithoutRecursion allTypesNull =
          AllNullableTypesWithoutRecursion();

      final AllNullableTypesWithoutRecursion? echoNullFilledClass = await api
          .echoAsyncNullableAllNullableTypesWithoutRecursion(allTypesNull);
      compareAllNullableTypesWithoutRecursion(
          echoNullFilledClass, allTypesNull);
    });

    testWidgets('Int async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = _regularInt;
      final int receivedInt = await api.echoAsyncInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = _biggerThanBigInt;
      final int receivedInt = await api.echoAsyncInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Doubles async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentDouble = 2.0694;
      final double receivedDouble = await api.echoAsyncDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('booleans async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool sentBool in <bool>[true, false]) {
        final bool receivedBool = await api.echoAsyncBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('strings async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentObject = 'Hello, asynchronously!';

      final String echoObject = await api.echoAsyncString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('Uint8List async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0
      ];
      final Uint8List sentUint8List = Uint8List.fromList(data);
      final Uint8List receivedUint8List =
          await api.echoAsyncUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('generic Objects async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const Object sentString = "I'm a computer";
      final Object receivedString = await api.echoAsyncObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = _regularInt;
      final Object receivedInt = await api.echoAsyncObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const List<Object?> sentObject = <Object>[7, 'Hello Dart!'];
      final List<Object?> echoObject = await api.echoAsyncList(sentObject);
      expect(listEquals(echoObject, sentObject), true);
    });

    testWidgets('maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const Map<String?, Object?> sentObject = <String?, Object?>{
        'a': 1,
        'b': 2.3,
        'c': 'four',
      };
      final Map<String?, Object?> echoObject =
          await api.echoAsyncMap(sentObject);
      expect(mapEquals(echoObject, sentObject), true);
    });

    testWidgets('enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum echoEnum = await api.echoAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fourHundredTwentyTwo;
      final AnEnum echoEnum = await api.echoAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable Int async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = _regularInt;
      final int? receivedInt = await api.echoAsyncNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable Int64 async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = _biggerThanBigInt;
      final int? receivedInt = await api.echoAsyncNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable Doubles async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentDouble = 2.0694;
      final double? receivedDouble =
          await api.echoAsyncNullableDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('nullable booleans async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool sentBool in <bool>[true, false]) {
        final bool? receivedBool = await api.echoAsyncNullableBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('nullable strings async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentObject = 'Hello, asynchronously!';

      final String? echoObject = await api.echoAsyncNullableString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('nullable Uint8List async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0
      ];
      final Uint8List sentUint8List = Uint8List.fromList(data);
      final Uint8List? receivedUint8List =
          await api.echoAsyncNullableUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets(
        'nullable generic Objects async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const Object sentString = "I'm a computer";
      final Object? receivedString =
          await api.echoAsyncNullableObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = _regularInt;
      final Object? receivedInt = await api.echoAsyncNullableObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const List<Object?> sentObject = <Object>[7, 'Hello Dart!'];
      final List<Object?>? echoObject =
          await api.echoAsyncNullableList(sentObject);
      expect(listEquals(echoObject, sentObject), true);
    });

    testWidgets('nullable maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const Map<String?, Object?> sentObject = <String?, Object?>{
        'a': 1,
        'b': 2.3,
        'c': 'four',
      };
      final Map<String?, Object?>? echoObject =
          await api.echoAsyncNullableMap(sentObject);
      expect(mapEquals(echoObject, sentObject), true);
    });

    testWidgets('nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.echoAsyncNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fortyTwo;
      final AnEnum? echoEnum = await api.echoAsyncNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null Ints async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final int? receivedInt = await api.echoAsyncNullableInt(null);
      expect(receivedInt, null);
    });

    testWidgets('null Doubles async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final double? receivedDouble = await api.echoAsyncNullableDouble(null);
      expect(receivedDouble, null);
    });

    testWidgets('null booleans async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final bool? receivedBool = await api.echoAsyncNullableBool(null);
      expect(receivedBool, null);
    });

    testWidgets('null strings async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final String? echoObject = await api.echoAsyncNullableString(null);
      expect(echoObject, null);
    });

    testWidgets('null Uint8List async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Uint8List? receivedUint8List =
          await api.echoAsyncNullableUint8List(null);
      expect(receivedUint8List, null);
    });

    testWidgets(
        'null generic Objects async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Object? receivedString = await api.echoAsyncNullableObject(null);
      expect(receivedString, null);
    });

    testWidgets('null lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.echoAsyncNullableList(null);
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('null maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<String?, Object?>? echoObject =
          await api.echoAsyncNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum? sentEnum = null;
      final AnEnum? echoEnum = await api.echoAsyncNullableEnum(null);
      expect(echoEnum, sentEnum);
    });
  });

  group('Host API with suffix', () {
    testWidgets('echo string succeeds with suffix with multiple instances',
        (_) async {
      final HostSmallApi apiWithSuffixOne =
          HostSmallApi(messageChannelSuffix: 'suffixOne');
      final HostSmallApi apiWithSuffixTwo =
          HostSmallApi(messageChannelSuffix: 'suffixTwo');
      const String sentString = "I'm a computer";
      final String echoStringOne = await apiWithSuffixOne.echo(sentString);
      final String echoStringTwo = await apiWithSuffixTwo.echo(sentString);
      expect(sentString, echoStringOne);
      expect(sentString, echoStringTwo);
    });

    testWidgets('multiple instances will have different method channel names',
        (_) async {
      // The only way to get the channel name back is to throw an exception.
      // These APIs have no corresponding APIs on the host platforms.
      final HostSmallApi apiWithSuffixOne =
          HostSmallApi(messageChannelSuffix: 'suffixWithNoHost');
      final HostSmallApi apiWithSuffixTwo =
          HostSmallApi(messageChannelSuffix: 'suffixWithoutHost');
      const String sentString = "I'm a computer";
      try {
        await apiWithSuffixOne.echo(sentString);
      } on PlatformException catch (e) {
        expect(e.message, contains('suffixWithNoHost'));
      }
      try {
        await apiWithSuffixTwo.echo(sentString);
      } on PlatformException catch (e) {
        expect(e.message, contains('suffixWithoutHost'));
      }
    });
  });

  // These tests rely on the async Dart->host calls to work correctly, since
  // the host->Dart call is wrapped in a driving Dart->host call, so any test
  // added to this group should have coverage of the relevant arguments and
  // return value in the "Host async API tests" group.
  group('Flutter API tests', () {
    setUp(() {
      FlutterIntegrationCoreApi.setUp(_FlutterApiTestImplementation());
    });

    testWidgets('basic void->void call works', (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(api.callFlutterNoop(), completes);
    });

    testWidgets('errors are returned from non void methods correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.callFlutterThrowError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('errors are returned from void methods correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      expect(() async {
        await api.callFlutterThrowErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('all datatypes serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllTypes echoObject =
          await api.callFlutterEchoAllTypes(genericAllTypes);

      compareAllTypes(echoObject, genericAllTypes);
    });

    testWidgets(
        'Arguments of multiple types serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String aNullableString = 'this is a String';
      const bool aNullableBool = false;
      const int aNullableInt = _regularInt;

      final AllNullableTypes compositeObject =
          await api.callFlutterSendMultipleNullableTypes(
              aNullableBool, aNullableInt, aNullableString);
      expect(compositeObject.aNullableInt, aNullableInt);
      expect(compositeObject.aNullableBool, aNullableBool);
      expect(compositeObject.aNullableString, aNullableString);
    });

    testWidgets(
        'Arguments of multiple null types serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes compositeObject =
          await api.callFlutterSendMultipleNullableTypes(null, null, null);
      expect(compositeObject.aNullableInt, null);
      expect(compositeObject.aNullableBool, null);
      expect(compositeObject.aNullableString, null);
    });

    testWidgets(
        'Arguments of multiple types serialize and deserialize correctly (WithoutRecursion)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String aNullableString = 'this is a String';
      const bool aNullableBool = false;
      const int aNullableInt = _regularInt;

      final AllNullableTypesWithoutRecursion compositeObject =
          await api.callFlutterSendMultipleNullableTypesWithoutRecursion(
              aNullableBool, aNullableInt, aNullableString);
      expect(compositeObject.aNullableInt, aNullableInt);
      expect(compositeObject.aNullableBool, aNullableBool);
      expect(compositeObject.aNullableString, aNullableString);
    });

    testWidgets(
        'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypesWithoutRecursion compositeObject =
          await api.callFlutterSendMultipleNullableTypesWithoutRecursion(
              null, null, null);
      expect(compositeObject.aNullableInt, null);
      expect(compositeObject.aNullableBool, null);
      expect(compositeObject.aNullableString, null);
    });

    testWidgets('booleans serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool sentObject in <bool>[true, false]) {
        final bool echoObject = await api.callFlutterEchoBool(sentObject);
        expect(echoObject, sentObject);
      }
    });

    testWidgets('ints serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentObject = _regularInt;
      final int echoObject = await api.callFlutterEchoInt(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('doubles serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentObject = 2.0694;
      final double echoObject = await api.callFlutterEchoDouble(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentObject = 'Hello Dart!';
      final String echoObject = await api.callFlutterEchoString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('Uint8Lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0
      ];
      final Uint8List sentObject = Uint8List.fromList(data);
      final Uint8List echoObject =
          await api.callFlutterEchoUint8List(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const List<Object?> sentObject = <Object>[7, 'Hello Dart!'];
      final List<Object?> echoObject =
          await api.callFlutterEchoList(sentObject);
      expect(listEquals(echoObject, sentObject), true);
    });

    testWidgets('maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const Map<String?, Object?> sentObject = <String?, Object?>{
        'a': 1,
        'b': 2.3,
        'c': 'four',
      };
      final Map<String?, Object?> echoObject =
          await api.callFlutterEchoMap(sentObject);
      expect(mapEquals(echoObject, sentObject), true);
    });

    testWidgets('enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum echoEnum = await api.callFlutterEchoEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fortyTwo;
      final AnEnum echoEnum = await api.callFlutterEchoEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable booleans serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      for (final bool? sentObject in <bool?>[true, false]) {
        final bool? echoObject =
            await api.callFlutterEchoNullableBool(sentObject);
        expect(echoObject, sentObject);
      }
    });

    testWidgets('null booleans serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const bool? sentObject = null;
      final bool? echoObject =
          await api.callFlutterEchoNullableBool(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('nullable ints serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentObject = _regularInt;
      final int? echoObject = await api.callFlutterEchoNullableInt(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('nullable big ints serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentObject = _biggerThanBigInt;
      final int? echoObject = await api.callFlutterEchoNullableInt(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('null ints serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final int? echoObject = await api.callFlutterEchoNullableInt(null);
      expect(echoObject, null);
    });

    testWidgets('nullable doubles serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const double sentObject = 2.0694;
      final double? echoObject =
          await api.callFlutterEchoNullableDouble(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('null doubles serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final double? echoObject = await api.callFlutterEchoNullableDouble(null);
      expect(echoObject, null);
    });

    testWidgets('nullable strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const String sentObject = "I'm a computer";
      final String? echoObject =
          await api.callFlutterEchoNullableString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('null strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final String? echoObject = await api.callFlutterEchoNullableString(null);
      expect(echoObject, null);
    });

    testWidgets('nullable Uint8Lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final List<int> data = <int>[
        102,
        111,
        114,
        116,
        121,
        45,
        116,
        119,
        111,
        0
      ];
      final Uint8List sentObject = Uint8List.fromList(data);
      final Uint8List? echoObject =
          await api.callFlutterEchoNullableUint8List(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('null Uint8Lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Uint8List? echoObject =
          await api.callFlutterEchoNullableUint8List(null);
      expect(echoObject, null);
    });

    testWidgets('nullable lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const List<Object?> sentObject = <Object>[7, 'Hello Dart!'];
      final List<Object?>? echoObject =
          await api.callFlutterEchoNullableList(sentObject);
      expect(listEquals(echoObject, sentObject), true);
    });

    testWidgets('null lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?>? echoObject =
          await api.callFlutterEchoNullableList(null);
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('nullable maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const Map<String?, Object?> sentObject = <String?, Object?>{
        'a': 1,
        'b': 2.3,
        'c': 'four',
      };
      final Map<String?, Object?>? echoObject =
          await api.callFlutterEchoNullableMap(sentObject);
      expect(mapEquals(echoObject, sentObject), true);
    });

    testWidgets('null maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<String?, Object?>? echoObject =
          await api.callFlutterEchoNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.callFlutterEchoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fourHundredTwentyTwo;
      final AnEnum? echoEnum = await api.callFlutterEchoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum? sentEnum = null;
      final AnEnum? echoEnum = await api.callFlutterEchoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });
  });

  group('Proxy API Tests', () {
    if (targetGenerator != TargetGenerator.swift) {
      return;
    }

    testWidgets('noop', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(api.noop(), completes);
    });

    testWidgets('throwError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwError(),
        throwsA(isA<PlatformException>()),
      );
    });

    testWidgets('throwErrorFromVoid', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwErrorFromVoid(),
        throwsA(isA<PlatformException>()),
      );
    });

    testWidgets('throwFlutterError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwFlutterError(),
        throwsA(
          (dynamic e) {
            return e is PlatformException &&
                e.code == 'code' &&
                e.message == 'message' &&
                e.details == 'details';
          },
        ),
      );
    });

    testWidgets('echoInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const int value = 0;
      expect(await api.echoInt(value), value);
    });

    testWidgets('echoDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const double value = 0.0;
      expect(await api.echoDouble(value), value);
    });

    testWidgets('echoBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const bool value = true;
      expect(await api.echoBool(value), value);
    });

    testWidgets('echoString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const String value = 'string';
      expect(await api.echoString(value), value);
    });

    testWidgets('echoUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final Uint8List value = Uint8List(0);
      expect(await api.echoUint8List(value), value);
    });

    testWidgets('echoObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const Object value = 'apples';
      expect(await api.echoObject(value), value);
    });

    testWidgets('echoList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const List<Object?> value = <int>[1, 2];
      expect(await api.echoList(value), value);
    });

    testWidgets('echoProxyApiList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final List<ProxyApiTestClass?> value = <ProxyApiTestClass?>[
        _createGenericProxyApiTestClass(),
        _createGenericProxyApiTestClass(),
      ];
      expect(await api.echoProxyApiList(value), value);
    });

    testWidgets('echoMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const Map<String?, Object?> value = <String?, Object?>{'apple': 'pie'};
      expect(await api.echoMap(value), value);
    });

    testWidgets('echoProxyApiMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final Map<String?, ProxyApiTestClass?> value =
          <String?, ProxyApiTestClass?>{
        '42': _createGenericProxyApiTestClass(),
      };
      expect(await api.echoProxyApiMap(value), value);
    });

    testWidgets('echoEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const ProxyApiTestEnum value = ProxyApiTestEnum.three;
      expect(await api.echoEnum(value), value);
    });

    testWidgets('echoProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final ProxyApiSuperClass value = ProxyApiSuperClass();
      expect(await api.echoProxyApi(value), value);
    });

    testWidgets('echoNullableInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableInt(null), null);
    });

    testWidgets('echoNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableDouble(null), null);
    });

    testWidgets('echoNullableBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableBool(null), null);
    });

    testWidgets('echoNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableString(null), null);
    });

    testWidgets('echoNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableUint8List(null), null);
    });

    testWidgets('echoNullableObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableObject(null), null);
    });

    testWidgets('echoNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableList(null), null);
    });

    testWidgets('echoNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableMap(null), null);
    });

    testWidgets('echoNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableEnum(null), null);
    });

    testWidgets('echoNullableProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableProxyApi(null), null);
    });

    testWidgets('noopAsync', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      await expectLater(api.noopAsync(), completes);
    });

    testWidgets('echoAsyncInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const int value = 0;
      expect(await api.echoAsyncInt(value), value);
    });

    testWidgets('echoAsyncDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const double value = 0.0;
      expect(await api.echoAsyncDouble(value), value);
    });

    testWidgets('echoAsyncBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const bool value = false;
      expect(await api.echoAsyncBool(value), value);
    });

    testWidgets('echoAsyncString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const String value = 'ping';
      expect(await api.echoAsyncString(value), value);
    });

    testWidgets('echoAsyncUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final Uint8List value = Uint8List(0);
      expect(await api.echoAsyncUint8List(value), value);
    });

    testWidgets('echoAsyncObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const Object value = 0;
      expect(await api.echoAsyncObject(value), value);
    });

    testWidgets('echoAsyncList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const List<Object?> value = <Object?>['apple', 'pie'];
      expect(await api.echoAsyncList(value), value);
    });

    testWidgets('echoAsyncMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      final Map<String?, Object?> value = <String?, Object?>{
        'something': ProxyApiSuperClass(),
      };
      expect(await api.echoAsyncMap(value), value);
    });

    testWidgets('echoAsyncEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      const ProxyApiTestEnum value = ProxyApiTestEnum.two;
      expect(await api.echoAsyncEnum(value), value);
    });

    testWidgets('throwAsyncError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwAsyncError(),
        throwsA(isA<PlatformException>()),
      );
    });

    testWidgets('throwAsyncErrorFromVoid', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwAsyncErrorFromVoid(),
        throwsA(isA<PlatformException>()),
      );
    });

    testWidgets('throwAsyncFlutterError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();

      await expectLater(
        () => api.throwAsyncFlutterError(),
        throwsA(
          (dynamic e) {
            return e is PlatformException &&
                e.code == 'code' &&
                e.message == 'message' &&
                e.details == 'details';
          },
        ),
      );
    });

    testWidgets('echoAsyncNullableInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableInt(null), null);
    });

    testWidgets('echoAsyncNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableDouble(null), null);
    });

    testWidgets('echoAsyncNullableBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableBool(null), null);
    });

    testWidgets('echoAsyncNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableString(null), null);
    });

    testWidgets('echoAsyncNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableUint8List(null), null);
    });

    testWidgets('echoAsyncNullableObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableObject(null), null);
    });

    testWidgets('echoAsyncNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableList(null), null);
    });

    testWidgets('echoAsyncNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableMap(null), null);
    });

    testWidgets('echoAsyncNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableEnum(null), null);
    });

    testWidgets('staticNoop', (_) async {
      await expectLater(ProxyApiTestClass.staticNoop(), completes);
    });

    testWidgets('echoStaticString', (_) async {
      const String value = 'static string';
      expect(await ProxyApiTestClass.echoStaticString(value), value);
    });

    testWidgets('staticAsyncNoop', (_) async {
      await expectLater(ProxyApiTestClass.staticAsyncNoop(), completes);
    });

    testWidgets('callFlutterNoop', (_) async {
      bool called = false;
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterNoop: (ProxyApiTestClass instance) async {
          called = true;
        },
      );

      await api.callFlutterNoop();
      expect(called, isTrue);
    });

    testWidgets('callFlutterThrowError', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterThrowError: (_) {
          throw FlutterError('this is an error');
        },
      );

      await expectLater(
        api.callFlutterThrowError(),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException exception) => exception.message,
            'message',
            equals('this is an error'),
          ),
        ),
      );
    });

    testWidgets('callFlutterThrowErrorFromVoid', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterThrowErrorFromVoid: (_) {
          throw FlutterError('this is an error');
        },
      );

      await expectLater(
        api.callFlutterThrowErrorFromVoid(),
        throwsA(
          isA<PlatformException>().having(
            (PlatformException exception) => exception.message,
            'message',
            equals('this is an error'),
          ),
        ),
      );
    });

    testWidgets('callFlutterEchoBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoBool: (_, bool aBool) => aBool,
      );

      const bool value = true;
      expect(await api.callFlutterEchoBool(value), value);
    });

    testWidgets('callFlutterEchoInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoInt: (_, int anInt) => anInt,
      );

      const int value = 0;
      expect(await api.callFlutterEchoInt(value), value);
    });

    testWidgets('callFlutterEchoDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoDouble: (_, double aDouble) => aDouble,
      );

      const double value = 0.0;
      expect(await api.callFlutterEchoDouble(value), value);
    });

    testWidgets('callFlutterEchoString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoString: (_, String aString) => aString,
      );

      const String value = 'a string';
      expect(await api.callFlutterEchoString(value), value);
    });

    testWidgets('callFlutterEchoUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoUint8List: (_, Uint8List aUint8List) => aUint8List,
      );

      final Uint8List value = Uint8List(0);
      expect(await api.callFlutterEchoUint8List(value), value);
    });

    testWidgets('callFlutterEchoList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoList: (_, List<Object?> aList) => aList,
      );

      final List<Object?> value = <Object?>[0, 0.0, true, ProxyApiSuperClass()];
      expect(await api.callFlutterEchoList(value), value);
    });

    testWidgets('callFlutterEchoProxyApiList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoProxyApiList: (_, List<ProxyApiTestClass?> aList) => aList,
      );

      final List<ProxyApiTestClass?> value = <ProxyApiTestClass>[
        _createGenericProxyApiTestClass(),
      ];
      expect(await api.callFlutterEchoProxyApiList(value), value);
    });

    testWidgets('callFlutterEchoMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoMap: (_, Map<String?, Object?> aMap) => aMap,
      );

      final Map<String?, Object?> value = <String?, Object?>{
        'a String': 4,
      };
      expect(await api.callFlutterEchoMap(value), value);
    });

    testWidgets('callFlutterEchoProxyApiMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoProxyApiMap: (_, Map<String?, ProxyApiTestClass?> aMap) =>
            aMap,
      );

      final Map<String?, ProxyApiTestClass?> value =
          <String?, ProxyApiTestClass?>{
        'a String': _createGenericProxyApiTestClass(),
      };
      expect(await api.callFlutterEchoProxyApiMap(value), value);
    });

    testWidgets('callFlutterEchoEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoEnum: (_, ProxyApiTestEnum anEnum) => anEnum,
      );

      const ProxyApiTestEnum value = ProxyApiTestEnum.three;
      expect(await api.callFlutterEchoEnum(value), value);
    });

    testWidgets('callFlutterEchoProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoProxyApi: (_, ProxyApiSuperClass aProxyApi) => aProxyApi,
      );

      final ProxyApiSuperClass value = ProxyApiSuperClass();
      expect(await api.callFlutterEchoProxyApi(value), value);
    });

    testWidgets('callFlutterEchoNullableBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableBool: (_, bool? aBool) => aBool,
      );
      expect(await api.callFlutterEchoNullableBool(null), null);
    });

    testWidgets('callFlutterEchoNullableInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableInt: (_, int? anInt) => anInt,
      );
      expect(await api.callFlutterEchoNullableInt(null), null);
    });

    testWidgets('callFlutterEchoNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableDouble: (_, double? aDouble) => aDouble,
      );
      expect(await api.callFlutterEchoNullableDouble(null), null);
    });

    testWidgets('callFlutterEchoNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableString: (_, String? aString) => aString,
      );
      expect(await api.callFlutterEchoNullableString(null), null);
    });

    testWidgets('callFlutterEchoNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableUint8List: (_, Uint8List? aUint8List) => aUint8List,
      );
      expect(await api.callFlutterEchoNullableUint8List(null), null);
    });

    testWidgets('callFlutterEchoNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableList: (_, List<Object?>? aList) => aList,
      );
      expect(await api.callFlutterEchoNullableList(null), null);
    });

    testWidgets('callFlutterEchoNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableMap: (_, Map<String?, Object?>? aMap) => aMap,
      );
      expect(await api.callFlutterEchoNullableMap(null), null);
    });

    testWidgets('callFlutterEchoNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableEnum: (_, ProxyApiTestEnum? anEnum) => anEnum,
      );
      expect(await api.callFlutterEchoNullableEnum(null), null);
    });

    testWidgets('callFlutterEchoNullableProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableProxyApi: (_, ProxyApiSuperClass? aProxyApi) =>
            aProxyApi,
      );
      expect(await api.callFlutterEchoNullableProxyApi(null), null);
    });

    testWidgets('callFlutterNoopAsync', (_) async {
      bool called = false;
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterNoopAsync: (ProxyApiTestClass instance) async {
          called = true;
        },
      );

      await api.callFlutterNoopAsync();
      expect(called, isTrue);
    });

    testWidgets('callFlutterEchoAsyncString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoAsyncString: (_, String aString) async => aString,
      );

      const String value = 'a string';
      expect(await api.callFlutterEchoAsyncString(value), value);
    });
  });

  group('Flutter API with suffix', () {
    setUp(() {
      FlutterSmallApi.setUp(
        _SmallFlutterApi(),
        messageChannelSuffix: 'suffixOne',
      );
      FlutterSmallApi.setUp(
        _SmallFlutterApi(),
        messageChannelSuffix: 'suffixTwo',
      );
    });

    testWidgets('echo string succeeds with suffix with multiple instances',
        (_) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String sentObject = "I'm a computer";
      final String echoObject =
          await api.callFlutterSmallApiEchoString(sentObject);
      expect(echoObject, sentObject);
    });
  });
}

class _FlutterApiTestImplementation implements FlutterIntegrationCoreApi {
  @override
  AllTypes echoAllTypes(AllTypes everything) {
    return everything;
  }

  @override
  AllNullableTypes? echoAllNullableTypes(AllNullableTypes? everything) {
    return everything;
  }

  @override
  AllNullableTypesWithoutRecursion? echoAllNullableTypesWithoutRecursion(
      AllNullableTypesWithoutRecursion? everything) {
    return everything;
  }

  @override
  void noop() {}

  @override
  Object? throwError() {
    throw FlutterError('this is an error');
  }

  @override
  void throwErrorFromVoid() {
    throw FlutterError('this is an error');
  }

  @override
  AllNullableTypes sendMultipleNullableTypes(
      bool? aNullableBool, int? aNullableInt, String? aNullableString) {
    return AllNullableTypes(
        aNullableBool: aNullableBool,
        aNullableInt: aNullableInt,
        aNullableString: aNullableString);
  }

  @override
  AllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
      bool? aNullableBool, int? aNullableInt, String? aNullableString) {
    return AllNullableTypesWithoutRecursion(
        aNullableBool: aNullableBool,
        aNullableInt: aNullableInt,
        aNullableString: aNullableString);
  }

  @override
  bool echoBool(bool aBool) => aBool;

  @override
  double echoDouble(double aDouble) => aDouble;

  @override
  int echoInt(int anInt) => anInt;

  @override
  String echoString(String aString) => aString;

  @override
  Uint8List echoUint8List(Uint8List list) => list;

  @override
  List<Object?> echoList(List<Object?> list) => list;

  @override
  Map<String?, Object?> echoMap(Map<String?, Object?> aMap) => aMap;

  @override
  AnEnum echoEnum(AnEnum anEnum) => anEnum;

  @override
  bool? echoNullableBool(bool? aBool) => aBool;

  @override
  double? echoNullableDouble(double? aDouble) => aDouble;

  @override
  int? echoNullableInt(int? anInt) => anInt;

  @override
  List<Object?>? echoNullableList(List<Object?>? list) => list;

  @override
  Map<String?, Object?>? echoNullableMap(Map<String?, Object?>? aMap) => aMap;

  @override
  String? echoNullableString(String? aString) => aString;

  @override
  Uint8List? echoNullableUint8List(Uint8List? list) => list;

  @override
  AnEnum? echoNullableEnum(AnEnum? anEnum) => anEnum;

  @override
  Future<void> noopAsync() async {}

  @override
  Future<String> echoAsyncString(String aString) async {
    return aString;
  }
}

class _SmallFlutterApi implements FlutterSmallApi {
  @override
  String echoString(String aString) {
    return aString;
  }

  @override
  TestMessage echoWrappedList(TestMessage msg) {
    return msg;
  }
}

ProxyApiTestClass _createGenericProxyApiTestClass({
  void Function(ProxyApiTestClass instance)? flutterNoop,
  Object? Function(ProxyApiTestClass instance)? flutterThrowError,
  void Function(
    ProxyApiTestClass instance,
  )? flutterThrowErrorFromVoid,
  bool Function(
    ProxyApiTestClass instance,
    bool aBool,
  )? flutterEchoBool,
  int Function(
    ProxyApiTestClass instance,
    int anInt,
  )? flutterEchoInt,
  double Function(
    ProxyApiTestClass instance,
    double aDouble,
  )? flutterEchoDouble,
  String Function(
    ProxyApiTestClass instance,
    String aString,
  )? flutterEchoString,
  Uint8List Function(
    ProxyApiTestClass instance,
    Uint8List aList,
  )? flutterEchoUint8List,
  List<Object?> Function(
    ProxyApiTestClass instance,
    List<Object?> aList,
  )? flutterEchoList,
  List<ProxyApiTestClass?> Function(
    ProxyApiTestClass instance,
    List<ProxyApiTestClass?> aList,
  )? flutterEchoProxyApiList,
  Map<String?, Object?> Function(
    ProxyApiTestClass instance,
    Map<String?, Object?> aMap,
  )? flutterEchoMap,
  Map<String?, ProxyApiTestClass?> Function(
    ProxyApiTestClass instance,
    Map<String?, ProxyApiTestClass?> aMap,
  )? flutterEchoProxyApiMap,
  ProxyApiTestEnum Function(
    ProxyApiTestClass instance,
    ProxyApiTestEnum anEnum,
  )? flutterEchoEnum,
  ProxyApiSuperClass Function(
    ProxyApiTestClass instance,
    ProxyApiSuperClass aProxyApi,
  )? flutterEchoProxyApi,
  bool? Function(
    ProxyApiTestClass instance,
    bool? aBool,
  )? flutterEchoNullableBool,
  int? Function(
    ProxyApiTestClass instance,
    int? anInt,
  )? flutterEchoNullableInt,
  double? Function(
    ProxyApiTestClass instance,
    double? aDouble,
  )? flutterEchoNullableDouble,
  String? Function(
    ProxyApiTestClass instance,
    String? aString,
  )? flutterEchoNullableString,
  Uint8List? Function(
    ProxyApiTestClass instance,
    Uint8List? aList,
  )? flutterEchoNullableUint8List,
  List<Object?>? Function(
    ProxyApiTestClass instance,
    List<Object?>? aList,
  )? flutterEchoNullableList,
  Map<String?, Object?>? Function(
    ProxyApiTestClass instance,
    Map<String?, Object?>? aMap,
  )? flutterEchoNullableMap,
  ProxyApiTestEnum? Function(
    ProxyApiTestClass instance,
    ProxyApiTestEnum? anEnum,
  )? flutterEchoNullableEnum,
  ProxyApiSuperClass? Function(
    ProxyApiTestClass instance,
    ProxyApiSuperClass? aProxyApi,
  )? flutterEchoNullableProxyApi,
  Future<void> Function(ProxyApiTestClass instance)? flutterNoopAsync,
  Future<String> Function(
    ProxyApiTestClass instance,
    String aString,
  )? flutterEchoAsyncString,
}) {
  return ProxyApiTestClass(
    aBool: true,
    anInt: 0,
    aDouble: 0.0,
    aString: '',
    aUint8List: Uint8List(0),
    aList: const <Object?>[],
    aMap: const <String?, Object?>{},
    anEnum: ProxyApiTestEnum.one,
    aProxyApi: ProxyApiSuperClass(),
    boolParam: true,
    intParam: 0,
    doubleParam: 0.0,
    stringParam: '',
    aUint8ListParam: Uint8List(0),
    listParam: const <Object?>[],
    mapParam: const <String?, Object?>{},
    enumParam: ProxyApiTestEnum.one,
    proxyApiParam: ProxyApiSuperClass(),
    flutterNoop: flutterNoop,
    flutterThrowError: flutterThrowError,
    flutterThrowErrorFromVoid: flutterThrowErrorFromVoid,
    flutterEchoBool: flutterEchoBool,
    flutterEchoInt: flutterEchoInt,
    flutterEchoDouble: flutterEchoDouble,
    flutterEchoString: flutterEchoString,
    flutterEchoUint8List: flutterEchoUint8List,
    flutterEchoList: flutterEchoList,
    flutterEchoProxyApiList: flutterEchoProxyApiList,
    flutterEchoMap: flutterEchoMap,
    flutterEchoProxyApiMap: flutterEchoProxyApiMap,
    flutterEchoEnum: flutterEchoEnum,
    flutterEchoProxyApi: flutterEchoProxyApi,
    flutterEchoNullableBool: flutterEchoNullableBool,
    flutterEchoNullableInt: flutterEchoNullableInt,
    flutterEchoNullableDouble: flutterEchoNullableDouble,
    flutterEchoNullableString: flutterEchoNullableString,
    flutterEchoNullableUint8List: flutterEchoNullableUint8List,
    flutterEchoNullableList: flutterEchoNullableList,
    flutterEchoNullableMap: flutterEchoNullableMap,
    flutterEchoNullableEnum: flutterEchoNullableEnum,
    flutterEchoNullableProxyApi: flutterEchoNullableProxyApi,
    flutterNoopAsync: flutterNoopAsync,
    flutterEchoAsyncString: flutterEchoAsyncString,
  );
}
