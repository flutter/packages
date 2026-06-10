// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'generated.dart';
import 'ni_integration_tests.dart' as ffi_tests show TargetGenerator, runPigeonNIIntegrationTests;
import 'proxy_api_integration_tests.dart';
import 'test_types.dart';

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

/// Host languages that support generating Proxy APIs.
const Set<TargetGenerator> proxyApiSupportedLanguages = <TargetGenerator>{
  TargetGenerator.kotlin,
  TargetGenerator.swift,
};

/// Sets up and runs the integration tests.
void runPigeonIntegrationTests(TargetGenerator targetGenerator) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  runProxyApiIntegrationTests(targetGenerator);

  if (targetGenerator == TargetGenerator.kotlin || targetGenerator == TargetGenerator.swift) {
    ffi_tests.runPigeonNIIntegrationTests(
      targetGenerator == TargetGenerator.kotlin
          ? ffi_tests.TargetGenerator.kotlin
          : ffi_tests.TargetGenerator.swift,
    );
  }

  group('Host sync API tests', () {
    testWidgets('basic void->void call works', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      expect(api.noop(), completes);
    });

    testWidgets('all datatypes serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final AllTypes echoObject = await api.echoAllTypes(genericAllTypes);
      expect(echoObject, genericAllTypes);
    });

    testWidgets('all nullable datatypes serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final AllNullableTypes? echoObject = await api.echoAllNullableTypes(
        recursiveAllNullableTypes,
      );

      expect(echoObject, recursiveAllNullableTypes);
    });

    testWidgets('all null datatypes serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final allTypesNull = AllNullableTypes();

      final AllNullableTypes? echoNullFilledClass = await api.echoAllNullableTypes(allTypesNull);
      expect(allTypesNull, echoNullFilledClass);
    });

    testWidgets('Classes with list of null serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final listTypes = AllNullableTypes(list: <String?>['String', null]);

      final AllNullableTypes? echoNullFilledClass = await api.echoAllNullableTypes(listTypes);

      expect(listTypes, echoNullFilledClass);
    });

    testWidgets('Classes with map of null serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final listTypes = AllNullableTypes(map: <String?, String?>{'String': 'string', 'null': null});

      final AllNullableTypes? echoNullFilledClass = await api.echoAllNullableTypes(listTypes);

      expect(listTypes, echoNullFilledClass);
    });

    testWidgets('all nullable datatypes without recursion serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final AllNullableTypesWithoutRecursion? echoObject = await api
          .echoAllNullableTypesWithoutRecursion(genericAllNullableTypesWithoutRecursion);

      expect(echoObject, genericAllNullableTypesWithoutRecursion);
    });

    testWidgets('all null datatypes without recursion serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final allTypesNull = AllNullableTypesWithoutRecursion();

      final AllNullableTypesWithoutRecursion? echoNullFilledClass = await api
          .echoAllNullableTypesWithoutRecursion(allTypesNull);
      expect(allTypesNull, echoNullFilledClass);
    });

    testWidgets('Classes without recursion with list of null serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final listTypes = AllNullableTypesWithoutRecursion(list: <String?>['String', null]);

      final AllNullableTypesWithoutRecursion? echoNullFilledClass = await api
          .echoAllNullableTypesWithoutRecursion(listTypes);

      expect(listTypes, echoNullFilledClass);
    });

    testWidgets('Classes without recursion with map of null serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final listTypes = AllNullableTypesWithoutRecursion(
        map: <String?, String?>{'String': 'string', 'null': null},
      );

      final AllNullableTypesWithoutRecursion? echoNullFilledClass = await api
          .echoAllNullableTypesWithoutRecursion(listTypes);

      expect(listTypes, echoNullFilledClass);
    });

    testWidgets('errors are returned correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('errors are returned from void methods correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('flutter errors are returned correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      expect(
        () => api.throwFlutterError(),
        throwsA(
          (dynamic e) =>
              e is PlatformException &&
              e.code == 'code' &&
              e.message == 'message' &&
              e.details == 'details',
        ),
      );
    });

    testWidgets('nested objects can be sent correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final AllClassesWrapper classWrapper = classWrapperMaker();
      final String? receivedString = await api.extractNestedNullableString(classWrapper);
      expect(receivedString, classWrapper.allNullableTypes.aNullableString);
    });

    testWidgets('nested objects can be received correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const sentString = 'Some string';
      final AllClassesWrapper receivedObject = await api.createNestedNullableString(sentString);
      expect(receivedObject.allNullableTypes.aNullableString, sentString);
    });

    testWidgets('nested classes can serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final AllClassesWrapper classWrapper = classWrapperMaker();

      final AllClassesWrapper receivedClassWrapper = await api.echoClassWrapper(classWrapper);
      expect(classWrapper, receivedClassWrapper);
    });

    testWidgets('nested null classes can serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      final AllClassesWrapper classWrapper = classWrapperMaker();

      classWrapper.allTypes = null;

      final AllClassesWrapper receivedClassWrapper = await api.echoClassWrapper(classWrapper);
      expect(classWrapper, receivedClassWrapper);
    });

    testWidgets('Arguments of multiple types serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      const aNullableString = 'this is a String';
      const aNullableBool = false;
      const int aNullableInt = regularInt;

      final AllNullableTypes echoObject = await api.sendMultipleNullableTypes(
        aNullableBool,
        aNullableInt,
        aNullableString,
      );
      expect(echoObject.aNullableInt, aNullableInt);
      expect(echoObject.aNullableBool, aNullableBool);
      expect(echoObject.aNullableString, aNullableString);
    });

    testWidgets('Arguments of multiple null types serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final AllNullableTypes echoNullFilledClass = await api.sendMultipleNullableTypes(
        null,
        null,
        null,
      );
      expect(echoNullFilledClass.aNullableInt, null);
      expect(echoNullFilledClass.aNullableBool, null);
      expect(echoNullFilledClass.aNullableString, null);
    });

    testWidgets(
      'Arguments of multiple types serialize and deserialize correctly (WithoutRecursion)',
      (WidgetTester _) async {
        final api = HostIntegrationCoreApi();
        const aNullableString = 'this is a String';
        const aNullableBool = false;
        const int aNullableInt = regularInt;

        final AllNullableTypesWithoutRecursion echoObject = await api
            .sendMultipleNullableTypesWithoutRecursion(
              aNullableBool,
              aNullableInt,
              aNullableString,
            );
        expect(echoObject.aNullableInt, aNullableInt);
        expect(echoObject.aNullableBool, aNullableBool);
        expect(echoObject.aNullableString, aNullableString);
      },
    );

    testWidgets(
      'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
      (WidgetTester _) async {
        final api = HostIntegrationCoreApi();

        final AllNullableTypesWithoutRecursion echoNullFilledClass = await api
            .sendMultipleNullableTypesWithoutRecursion(null, null, null);
        expect(echoNullFilledClass.aNullableInt, null);
        expect(echoNullFilledClass.aNullableBool, null);
        expect(echoNullFilledClass.aNullableString, null);
      },
    );

    testWidgets('Int serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      const int sentInt = regularInt;
      final int receivedInt = await api.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
      final int receivedInt = await api.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Doubles serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const sentDouble = 2.0694;
      final double receivedDouble = await api.echoDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('booleans serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      for (final sentBool in <bool>[true, false]) {
        final bool receivedBool = await api.echoBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('strings serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      const sentString = 'default';
      final String receivedString = await api.echoString(sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Uint8List serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final data = <int>[102, 111, 114, 116, 121, 45, 116, 119, 111, 0];
      final sentUint8List = Uint8List.fromList(data);
      final Uint8List receivedUint8List = await api.echoUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('strings as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      const Object sentString = "I'm a computer";
      final Object receivedString = await api.echoObject(sentString);
      expect(receivedString, sentString);
    });

    testWidgets('integers as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      const Object sentInt = regularInt;
      final Object receivedInt = await api.echoObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('booleans as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      const Object sentBool = true;
      final Object receivedBool = await api.echoObject(sentBool);
      expect(receivedBool, sentBool);
    });

    testWidgets('double as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      const Object sentDouble = 2.0694;
      final Object receivedDouble = await api.echoObject(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('Uint8List as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final Object sentUint8List = Uint8List.fromList(<int>[1, 2, 3]);
      final Object receivedUint8List = await api.echoObject(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('Int32List as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final Object sentInt32List = Int32List.fromList(<int>[1, 2, 3]);
      final Object receivedInt32List = await api.echoObject(sentInt32List);
      expect(receivedInt32List, sentInt32List);
    });

    testWidgets('Int64List as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final Object sentInt64List = Int64List.fromList(<int>[1, 2, 3]);
      final Object receivedInt64List = await api.echoObject(sentInt64List);
      expect(receivedInt64List, sentInt64List);
    });

    testWidgets('class as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final Object receivedClass = await api.echoObject(genericAllNullableTypesWithoutRecursion);
      expect(receivedClass, genericAllNullableTypesWithoutRecursion);
    });

    testWidgets('Float64List as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final Object sentFloat64List = Float64List.fromList(<double>[1.0, 2.0, 3.0]);
      final Object receivedFloat64List = await api.echoObject(sentFloat64List);
      expect(receivedFloat64List, sentFloat64List);
    });

    testWidgets('List as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final Object receivedList = await api.echoObject(list);
      expect(receivedList, list);
    });

    testWidgets('Map as generic Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final Object receivedMap = await api.echoObject(map);
      expect(receivedMap, map);
    });

    testWidgets('lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<Object?> echoObject = await api.echoList(list);
      expect(listEquals(echoObject, list), true);
    });

    // // Currently need set up
    // testWidgets('string lists serialize and deserialize correctly', (
    //   WidgetTester _,
    // ) async {
    //   final HostIntegrationCoreApi api = HostIntegrationCoreApi();

    //   final List<String?> echoObject = await api.echoStringList(stringList);
    //   expect(listEquals(echoObject, stringList), true);
    // });

    // testWidgets('int lists serialize and deserialize correctly', (
    //   WidgetTester _,
    // ) async {
    //   final HostIntegrationCoreApi api = HostIntegrationCoreApi();

    //   final List<int?> echoObject = await api.echoIntList(intList);
    //   expect(listEquals(echoObject, intList), true);
    // });

    // testWidgets('double lists serialize and deserialize correctly', (
    //   WidgetTester _,
    // ) async {
    //   final HostIntegrationCoreApi api = HostIntegrationCoreApi();

    //   final List<double?> echoObject = await api.echoDoubleList(doubleList);
    //   expect(listEquals(echoObject, doubleList), true);
    // });

    // testWidgets('bool lists serialize and deserialize correctly', (
    //   WidgetTester _,
    // ) async {
    //   final HostIntegrationCoreApi api = HostIntegrationCoreApi();

    //   final List<bool?> echoObject = await api.echoBoolList(boolList);
    //   expect(listEquals(echoObject, boolList), true);
    // });

    testWidgets('enum lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AnEnum?> echoObject = await api.echoEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AllNullableTypes?> echoObject = await api.echoClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('NonNull enum lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AnEnum> echoObject = await api.echoNonNullEnumList(nonNullEnumList);
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('NonNull class lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AllNullableTypes> echoObject = await api.echoNonNullClassList(
        nonNullAllNullableTypesList,
      );
      for (final (int index, AllNullableTypes value) in echoObject.indexed) {
        expect(value, nonNullAllNullableTypesList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<Object?, Object?> echoObject = await api.echoMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<String?, String?> echoObject = await api.echoStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, int?> echoObject = await api.echoIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?> echoObject = await api.echoEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?> echoObject = await api.echoClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry in echoObject.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('NonNull string maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<String, String> echoObject = await api.echoNonNullStringMap(nonNullStringMap);
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('NonNull int maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int, int> echoObject = await api.echoNonNullIntMap(nonNullIntMap);
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets('NonNull enum maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<AnEnum, AnEnum> echoObject = await api.echoNonNullEnumMap(nonNullEnumMap);
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets('NonNull class maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int, AllNullableTypes> echoObject = await api.echoNonNullClassMap(
        nonNullAllNullableTypesMap,
      );
      for (final MapEntry<int, AllNullableTypes> entry in echoObject.entries) {
        expect(entry.value, nonNullAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.two;
      final AnEnum receivedEnum = await api.echoEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum receivedEnum = await api.echoAnotherEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fortyTwo;
      final AnEnum receivedEnum = await api.echoEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('required named parameter', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      // This number corresponds with the default value of this method.
      const int sentInt = regularInt;
      final int receivedInt = await api.echoRequiredInt(anInt: sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('optional default parameter no arg', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      // This number corresponds with the default value of this method.
      const sentDouble = 3.14;
      final double receivedDouble = await api.echoOptionalDefaultDouble();
      expect(receivedDouble, sentDouble);
    });

    testWidgets('optional default parameter with arg', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const sentDouble = 3.15;
      final double receivedDouble = await api.echoOptionalDefaultDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('named default parameter no arg', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      // This string corresponds with the default value of this method.
      const sentString = 'default';
      final String receivedString = await api.echoNamedDefaultString();
      expect(receivedString, sentString);
    });

    testWidgets('named default parameter with arg', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      // This string corresponds with the default value of this method.
      const sentString = 'notDefault';
      final String receivedString = await api.echoNamedDefaultString(aString: sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Nullable Int serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const int sentInt = regularInt;
      final int? receivedInt = await api.echoNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Nullable Int64 serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
      final int? receivedInt = await api.echoNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null Ints serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final int? receivedNullInt = await api.echoNullableInt(null);
      expect(receivedNullInt, null);
    });

    testWidgets('Nullable Doubles serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const sentDouble = 2.0694;
      final double? receivedDouble = await api.echoNullableDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('Null Doubles serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final double? receivedNullDouble = await api.echoNullableDouble(null);
      expect(receivedNullDouble, null);
    });

    testWidgets('Nullable booleans serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      for (final sentBool in <bool?>[true, false]) {
        final bool? receivedBool = await api.echoNullableBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('Null booleans serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const bool? sentBool = null;
      final bool? receivedBool = await api.echoNullableBool(sentBool);
      expect(receivedBool, sentBool);
    });

    testWidgets('Nullable strings serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      const sentString = "I'm a computer";
      final String? receivedString = await api.echoNullableString(sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Null strings serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final String? receivedNullString = await api.echoNullableString(null);
      expect(receivedNullString, null);
    });

    testWidgets('Nullable Uint8List serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final data = <int>[102, 111, 114, 116, 121, 45, 116, 119, 111, 0];
      final sentUint8List = Uint8List.fromList(data);
      final Uint8List? receivedUint8List = await api.echoNullableUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('Null Uint8List serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Uint8List? receivedNullUint8List = await api.echoNullableUint8List(null);
      expect(receivedNullUint8List, null);
    });

    testWidgets('generic nullable Objects serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      const Object sentString = "I'm a computer";
      final Object? receivedString = await api.echoNullableObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = regularInt;
      final Object? receivedInt = await api.echoNullableObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null generic Objects serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Object? receivedNullObject = await api.echoNullableObject(null);
      expect(receivedNullObject, null);
    });

    testWidgets('nullable lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.echoNullableList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject = await api.echoNullableEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject = await api.echoNullableClassList(
        allNullableTypesList,
      );
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('nullable NonNull enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject = await api.echoNullableNonNullEnumList(nonNullEnumList);
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('nullable NonNull lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject = await api.echoNullableClassList(
        nonNullAllNullableTypesList,
      );
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        expect(value, nonNullAllNullableTypesList[index]);
      }
    });

    testWidgets('nullable maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<Object?, Object?>? echoObject = await api.echoNullableMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject = await api.echoNullableStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject = await api.echoNullableIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject = await api.echoNullableEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject = await api.echoNullableClassMap(
        allNullableTypesMap,
      );
      for (final MapEntry<int?, AllNullableTypes?> entry in echoObject!.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('nullable NonNull string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject = await api.echoNullableNonNullStringMap(
        nonNullStringMap,
      );
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('nullable NonNull int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject = await api.echoNullableNonNullIntMap(nonNullIntMap);
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets('nullable NonNull enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject = await api.echoNullableNonNullEnumMap(
        nonNullEnumMap,
      );
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets('nullable NonNull class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject = await api.echoNullableNonNullClassMap(
        nonNullAllNullableTypesMap,
      );
      for (final MapEntry<int?, AllNullableTypes?> entry in echoObject!.entries) {
        expect(entry.value, nonNullAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('nullable enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum? echoEnum = await api.echoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word nullable enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fourHundredTwentyTwo;
      final AnEnum? echoEnum = await api.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.echoNullableList(null);
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('null maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Map<Object?, Object?>? echoObject = await api.echoNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null string maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Map<String?, String?>? echoObject = await api.echoNullableStringMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null int maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Map<int?, int?>? echoObject = await api.echoNullableIntMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum? sentEnum = null;
      final AnEnum? echoEnum = await api.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly (again)', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnotherEnum? sentEnum = null;
      final AnotherEnum? echoEnum = await api.echoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null classes serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final AllNullableTypes? echoObject = await api.echoAllNullableTypes(null);

      expect(echoObject, isNull);
    });

    testWidgets('optional nullable parameter', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const int sentInt = regularInt;
      final int? receivedInt = await api.echoOptionalNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null optional nullable parameter', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final int? receivedNullInt = await api.echoOptionalNullableInt();
      expect(receivedNullInt, null);
    });

    testWidgets('named nullable parameter', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      const sentString = "I'm a computer";
      final String? receivedString = await api.echoNamedNullableString(aNullableString: sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Null named nullable parameter', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final String? receivedNullString = await api.echoNamedNullableString();
      expect(receivedNullString, null);
    });

    testWidgets('Signed zero equality', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final a = AllNullableTypes(aNullableDouble: 0.0);
      final b = AllNullableTypes(aNullableDouble: -0.0);

      expect(await api.areAllNullableTypesEqual(a, b), isTrue);
    });

    testWidgets('Signed zero hashing', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final a = AllNullableTypes(aNullableDouble: 0.0);
      final b = AllNullableTypes(aNullableDouble: -0.0);

      final int hashA = await api.getAllNullableTypesHash(a);
      final int hashB = await api.getAllNullableTypesHash(b);
      expect(hashA, hashB, reason: 'Hash codes for 0.0 and -0.0 should be equal');
    });

    testWidgets('NaN equality', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final a = AllNullableTypes(aNullableDouble: double.nan);
      final b = AllNullableTypes(aNullableDouble: double.nan);

      expect(await api.areAllNullableTypesEqual(a, b), isTrue);
    });

    testWidgets('NaN hashing', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final a = AllNullableTypes(aNullableDouble: double.nan);
      final b = AllNullableTypes(aNullableDouble: double.nan);

      final int hashA = await api.getAllNullableTypesHash(a);
      final int hashB = await api.getAllNullableTypesHash(b);
      expect(hashA, hashB, reason: 'Hash codes for two NaNs should be equal');
    });

    testWidgets('Collection equality with signed zero and NaN', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final a = AllNullableTypes(
        doubleList: <double>[0.0, double.nan],
        stringMap: <String?, String?>{'k': 'v', 'n': null},
      );
      final b = AllNullableTypes(
        doubleList: <double>[-0.0, double.nan],
        stringMap: <String?, String?>{'n': null, 'k': 'v'},
      );

      expect(await api.areAllNullableTypesEqual(a, b), isTrue);
    });

    testWidgets('Collection hashing with signed zero and NaN', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final a = AllNullableTypes(
        doubleList: <double>[0.0, double.nan],
        stringMap: <String?, String?>{'k': 'v', 'n': null},
      );
      final b = AllNullableTypes(
        doubleList: <double>[-0.0, double.nan],
        stringMap: <String?, String?>{'n': null, 'k': 'v'},
      );

      expect(await api.getAllNullableTypesHash(a), await api.getAllNullableTypesHash(b));
    });

    testWidgets('Collection hashing with null/NSNull', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final a = AllNullableTypes(list: <Object?>[null], stringMap: <String?, String?>{'k': null});
      final b = AllNullableTypes(list: <Object?>[null], stringMap: <String?, String?>{'k': null});

      // Verify cross-platform equivalence via identical hash values.
      expect(await api.getAllNullableTypesHash(a), await api.getAllNullableTypesHash(b));
      expect(await api.areAllNullableTypesEqual(a, b), isTrue);
    });

    testWidgets('Map equality with signed zero keys and values', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final a = AllNullableTypes(map: <Object?, Object?>{0.0: 'a', 'b': 0.0});
      final b = AllNullableTypes(map: <Object?, Object?>{-0.0: 'a', 'b': -0.0});

      expect(await api.areAllNullableTypesEqual(a, b), isTrue);
    });

    testWidgets('Map hashing with signed zero keys and values', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final a = AllNullableTypes(map: <Object?, Object?>{0.0: 'a', 'b': 0.0});
      final b = AllNullableTypes(map: <Object?, Object?>{-0.0: 'a', 'b': -0.0});

      expect(await api.getAllNullableTypesHash(a), await api.getAllNullableTypesHash(b));
    });

    testWidgets('Map equality with null values and different keys', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final a = AllNullableTypes(intMap: <int?, int?>{1: null});
      final b = AllNullableTypes(intMap: <int?, int?>{2: null});

      expect(await api.areAllNullableTypesEqual(a, b), isFalse);
    });

    testWidgets('Deeply nested equality', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final a = AllNullableTypes(allNullableTypes: AllNullableTypes(aNullableDouble: 0.0));
      final b = AllNullableTypes(allNullableTypes: AllNullableTypes(aNullableDouble: -0.0));

      expect(await api.areAllNullableTypesEqual(a, b), isTrue);
    });

    testWidgets('Hashing inequality across types with same values', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final a = AllNullableTypes(aNullableInt: 42);
      final b = AllNullableTypesWithoutRecursion(aNullableInt: 42);

      expect(a.hashCode, isNot(b.hashCode));

      expect(
        await api.getAllNullableTypesHash(a),
        isNot(await api.getAllNullableTypesWithoutRecursionHash(b)),
      );
    });
  });

  group('Host async API tests', () {
    testWidgets('basic void->void call works', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      expect(api.noopAsync(), completes);
    });

    testWidgets('async errors are returned from non void methods correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwAsyncError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('async errors are returned from void methods correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      expect(() async {
        await api.throwAsyncErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('async flutter errors are returned from non void methods correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      expect(
        () => api.throwAsyncFlutterError(),
        throwsA(
          (dynamic e) =>
              e is PlatformException &&
              e.code == 'code' &&
              e.message == 'message' &&
              e.details == 'details',
        ),
      );
    });

    testWidgets('all datatypes async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final AllTypes echoObject = await api.echoAsyncAllTypes(genericAllTypes);

      expect(echoObject, genericAllTypes);
    });

    testWidgets('all nullable async datatypes serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final AllNullableTypes? echoObject = await api.echoAsyncNullableAllNullableTypes(
        recursiveAllNullableTypes,
      );

      expect(echoObject, recursiveAllNullableTypes);
    });

    testWidgets('all null datatypes async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final allTypesNull = AllNullableTypes();

      final AllNullableTypes? echoNullFilledClass = await api.echoAsyncNullableAllNullableTypes(
        allTypesNull,
      );
      expect(echoNullFilledClass, allTypesNull);
    });

    testWidgets(
      'all nullable async datatypes without recursion serialize and deserialize correctly',
      (WidgetTester _) async {
        final api = HostIntegrationCoreApi();

        final AllNullableTypesWithoutRecursion? echoObject = await api
            .echoAsyncNullableAllNullableTypesWithoutRecursion(
              genericAllNullableTypesWithoutRecursion,
            );

        expect(echoObject, genericAllNullableTypesWithoutRecursion);
      },
    );

    testWidgets('all null datatypes without recursion async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final allTypesNull = AllNullableTypesWithoutRecursion();

      final AllNullableTypesWithoutRecursion? echoNullFilledClass = await api
          .echoAsyncNullableAllNullableTypesWithoutRecursion(allTypesNull);
      expect(echoNullFilledClass, allTypesNull);
    });

    testWidgets('Int async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const int sentInt = regularInt;
      final int receivedInt = await api.echoAsyncInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
      final int receivedInt = await api.echoAsyncInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Doubles async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const sentDouble = 2.0694;
      final double receivedDouble = await api.echoAsyncDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('booleans async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      for (final sentBool in <bool>[true, false]) {
        final bool receivedBool = await api.echoAsyncBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('strings async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const sentObject = 'Hello, asynchronously!';

      final String echoObject = await api.echoAsyncString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('Uint8List async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final data = <int>[102, 111, 114, 116, 121, 45, 116, 119, 111, 0];
      final sentUint8List = Uint8List.fromList(data);
      final Uint8List receivedUint8List = await api.echoAsyncUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('generic Objects async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      const Object sentString = "I'm a computer";
      final Object receivedString = await api.echoAsyncObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = regularInt;
      final Object receivedInt = await api.echoAsyncObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<Object?> echoObject = await api.echoAsyncList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('enum lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AnEnum?> echoObject = await api.echoAsyncEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AllNullableTypes?> echoObject = await api.echoAsyncClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<Object?, Object?> echoObject = await api.echoAsyncMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<String?, String?> echoObject = await api.echoAsyncStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, int?> echoObject = await api.echoAsyncIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?> echoObject = await api.echoAsyncEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?> echoObject = await api.echoAsyncClassMap(
        allNullableTypesMap,
      );
      for (final MapEntry<int?, AllNullableTypes?> entry in echoObject.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum echoEnum = await api.echoAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum echoEnum = await api.echoAnotherAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fourHundredTwentyTwo;
      final AnEnum echoEnum = await api.echoAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable Int async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const int sentInt = regularInt;
      final int? receivedInt = await api.echoAsyncNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable Int64 async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
      final int? receivedInt = await api.echoAsyncNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable Doubles async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      const sentDouble = 2.0694;
      final double? receivedDouble = await api.echoAsyncNullableDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('nullable booleans async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      for (final sentBool in <bool>[true, false]) {
        final bool? receivedBool = await api.echoAsyncNullableBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('nullable strings async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      const sentObject = 'Hello, asynchronously!';

      final String? echoObject = await api.echoAsyncNullableString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('nullable Uint8List async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      final data = <int>[102, 111, 114, 116, 121, 45, 116, 119, 111, 0];
      final sentUint8List = Uint8List.fromList(data);
      final Uint8List? receivedUint8List = await api.echoAsyncNullableUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('nullable generic Objects async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      const Object sentString = "I'm a computer";
      final Object? receivedString = await api.echoAsyncNullableObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = regularInt;
      final Object? receivedInt = await api.echoAsyncNullableObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.echoAsyncNullableList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject = await api.echoAsyncNullableEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable class lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject = await api.echoAsyncNullableClassList(
        allNullableTypesList,
      );
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('nullable maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<Object?, Object?>? echoObject = await api.echoAsyncNullableMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject = await api.echoAsyncNullableStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject = await api.echoAsyncNullableIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject = await api.echoAsyncNullableEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject = await api.echoAsyncNullableClassMap(
        allNullableTypesMap,
      );
      for (final MapEntry<int?, AllNullableTypes?> entry in echoObject!.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('nullable enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.echoAsyncNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum? echoEnum = await api.echoAnotherAsyncNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fortyTwo;
      final AnEnum? echoEnum = await api.echoAsyncNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null Ints async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final int? receivedInt = await api.echoAsyncNullableInt(null);
      expect(receivedInt, null);
    });

    testWidgets('null Doubles async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final double? receivedDouble = await api.echoAsyncNullableDouble(null);
      expect(receivedDouble, null);
    });

    testWidgets('null booleans async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final bool? receivedBool = await api.echoAsyncNullableBool(null);
      expect(receivedBool, null);
    });

    testWidgets('null strings async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final String? echoObject = await api.echoAsyncNullableString(null);
      expect(echoObject, null);
    });

    testWidgets('null Uint8List async serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Uint8List? receivedUint8List = await api.echoAsyncNullableUint8List(null);
      expect(receivedUint8List, null);
    });

    testWidgets('null generic Objects async serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      final Object? receivedString = await api.echoAsyncNullableObject(null);
      expect(receivedString, null);
    });

    testWidgets('null lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.echoAsyncNullableList(null);
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('null maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Map<Object?, Object?>? echoObject = await api.echoAsyncNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null string maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Map<String?, String?>? echoObject = await api.echoAsyncNullableStringMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null int maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Map<int?, int?>? echoObject = await api.echoAsyncNullableIntMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum? sentEnum = null;
      final AnEnum? echoEnum = await api.echoAsyncNullableEnum(null);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnotherEnum? sentEnum = null;
      final AnotherEnum? echoEnum = await api.echoAnotherAsyncNullableEnum(null);
      expect(echoEnum, sentEnum);
    });
  });

  group('Host API with suffix', () {
    testWidgets('echo string succeeds with suffix with multiple instances', (_) async {
      final apiWithSuffixOne = HostSmallApi(messageChannelSuffix: 'suffixOne');
      final apiWithSuffixTwo = HostSmallApi(messageChannelSuffix: 'suffixTwo');
      const sentString = "I'm a computer";
      final String echoStringOne = await apiWithSuffixOne.echo(sentString);
      final String echoStringTwo = await apiWithSuffixTwo.echo(sentString);
      expect(sentString, echoStringOne);
      expect(sentString, echoStringTwo);
    });

    testWidgets('multiple instances will have different method channel names', (_) async {
      // The only way to get the channel name back is to throw an exception.
      // These APIs have no corresponding APIs on the host platforms.
      final apiWithSuffixOne = HostSmallApi(messageChannelSuffix: 'suffixWithNoHost');
      final apiWithSuffixTwo = HostSmallApi(messageChannelSuffix: 'suffixWithoutHost');
      const sentString = "I'm a computer";
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
      FlutterIntegrationCoreApi.setUp(FlutterApiTestImplementation());
    });

    testWidgets('basic void->void call works', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      expect(api.callFlutterNoop(), completes);
    });

    testWidgets('errors are returned from non void methods correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      expect(() async {
        await api.callFlutterThrowError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('errors are returned from void methods correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      expect(() async {
        await api.callFlutterThrowErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('all datatypes serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final AllTypes echoObject = await api.callFlutterEchoAllTypes(genericAllTypes);

      expect(echoObject, genericAllTypes);
    });

    testWidgets('Arguments of multiple types serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      const aNullableString = 'this is a String';
      const aNullableBool = false;
      const int aNullableInt = regularInt;

      final AllNullableTypes compositeObject = await api.callFlutterSendMultipleNullableTypes(
        aNullableBool,
        aNullableInt,
        aNullableString,
      );
      expect(compositeObject.aNullableInt, aNullableInt);
      expect(compositeObject.aNullableBool, aNullableBool);
      expect(compositeObject.aNullableString, aNullableString);
    });

    testWidgets('Arguments of multiple null types serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final AllNullableTypes compositeObject = await api.callFlutterSendMultipleNullableTypes(
        null,
        null,
        null,
      );
      expect(compositeObject.aNullableInt, null);
      expect(compositeObject.aNullableBool, null);
      expect(compositeObject.aNullableString, null);
    });

    testWidgets(
      'Arguments of multiple types serialize and deserialize correctly (WithoutRecursion)',
      (WidgetTester _) async {
        final api = HostIntegrationCoreApi();
        const aNullableString = 'this is a String';
        const aNullableBool = false;
        const int aNullableInt = regularInt;

        final AllNullableTypesWithoutRecursion compositeObject = await api
            .callFlutterSendMultipleNullableTypesWithoutRecursion(
              aNullableBool,
              aNullableInt,
              aNullableString,
            );
        expect(compositeObject.aNullableInt, aNullableInt);
        expect(compositeObject.aNullableBool, aNullableBool);
        expect(compositeObject.aNullableString, aNullableString);
      },
    );

    testWidgets(
      'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
      (WidgetTester _) async {
        final api = HostIntegrationCoreApi();

        final AllNullableTypesWithoutRecursion compositeObject = await api
            .callFlutterSendMultipleNullableTypesWithoutRecursion(null, null, null);
        expect(compositeObject.aNullableInt, null);
        expect(compositeObject.aNullableBool, null);
        expect(compositeObject.aNullableString, null);
      },
    );

    testWidgets('booleans serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      for (final sentObject in <bool>[true, false]) {
        final bool echoObject = await api.callFlutterEchoBool(sentObject);
        expect(echoObject, sentObject);
      }
    });

    testWidgets('ints serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const int sentObject = regularInt;
      final int echoObject = await api.callFlutterEchoInt(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('doubles serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const sentObject = 2.0694;
      final double echoObject = await api.callFlutterEchoDouble(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('strings serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const sentObject = 'Hello Dart!';
      final String echoObject = await api.callFlutterEchoString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('Uint8Lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final data = <int>[102, 111, 114, 116, 121, 45, 116, 119, 111, 0];
      final sentObject = Uint8List.fromList(data);
      final Uint8List echoObject = await api.callFlutterEchoUint8List(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<Object?> echoObject = await api.callFlutterEchoList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('enum lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AnEnum?> echoObject = await api.callFlutterEchoEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AllNullableTypes?> echoObject = await api.callFlutterEchoClassList(
        allNullableTypesList,
      );
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('NonNull enum lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AnEnum> echoObject = await api.callFlutterEchoNonNullEnumList(nonNullEnumList);
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('NonNull class lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AllNullableTypes> echoObject = await api.callFlutterEchoNonNullClassList(
        nonNullAllNullableTypesList,
      );
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        expect(value, nonNullAllNullableTypesList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<Object?, Object?> echoObject = await api.callFlutterEchoMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<String?, String?> echoObject = await api.callFlutterEchoStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, int?> echoObject = await api.callFlutterEchoIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?> echoObject = await api.callFlutterEchoEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?> echoObject = await api.callFlutterEchoClassMap(
        allNullableTypesMap,
      );
      for (final MapEntry<int?, AllNullableTypes?> entry in echoObject.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('NonNull string maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<String, String> echoObject = await api.callFlutterEchoNonNullStringMap(
        nonNullStringMap,
      );
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('NonNull int maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int, int> echoObject = await api.callFlutterEchoNonNullIntMap(nonNullIntMap);
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets('NonNull enum maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<AnEnum, AnEnum> echoObject = await api.callFlutterEchoNonNullEnumMap(
        nonNullEnumMap,
      );
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets('NonNull class maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int, AllNullableTypes> echoObject = await api.callFlutterEchoNonNullClassMap(
        nonNullAllNullableTypesMap,
      );
      for (final MapEntry<int, AllNullableTypes> entry in echoObject.entries) {
        expect(entry.value, nonNullAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum echoEnum = await api.callFlutterEchoEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum echoEnum = await api.callFlutterEchoAnotherEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fortyTwo;
      final AnEnum echoEnum = await api.callFlutterEchoEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable booleans serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      for (final sentObject in <bool?>[true, false]) {
        final bool? echoObject = await api.callFlutterEchoNullableBool(sentObject);
        expect(echoObject, sentObject);
      }
    });

    testWidgets('null booleans serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const bool? sentObject = null;
      final bool? echoObject = await api.callFlutterEchoNullableBool(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('nullable ints serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const int sentObject = regularInt;
      final int? echoObject = await api.callFlutterEchoNullableInt(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('nullable big ints serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const int sentObject = biggerThanBigInt;
      final int? echoObject = await api.callFlutterEchoNullableInt(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('null ints serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final int? echoObject = await api.callFlutterEchoNullableInt(null);
      expect(echoObject, null);
    });

    testWidgets('nullable doubles serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const sentObject = 2.0694;
      final double? echoObject = await api.callFlutterEchoNullableDouble(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('null doubles serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final double? echoObject = await api.callFlutterEchoNullableDouble(null);
      expect(echoObject, null);
    });

    testWidgets('nullable strings serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const sentObject = "I'm a computer";
      final String? echoObject = await api.callFlutterEchoNullableString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('null strings serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final String? echoObject = await api.callFlutterEchoNullableString(null);
      expect(echoObject, null);
    });

    testWidgets('nullable Uint8Lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final data = <int>[102, 111, 114, 116, 121, 45, 116, 119, 111, 0];
      final sentObject = Uint8List.fromList(data);
      final Uint8List? echoObject = await api.callFlutterEchoNullableUint8List(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('null Uint8Lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Uint8List? echoObject = await api.callFlutterEchoNullableUint8List(null);
      expect(echoObject, null);
    });

    testWidgets('nullable lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.callFlutterEchoNullableList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject = await api.callFlutterEchoNullableEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable class lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject = await api.callFlutterEchoNullableClassList(
        allNullableTypesList,
      );
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('nullable NonNull enum lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject = await api.callFlutterEchoNullableNonNullEnumList(
        nonNullEnumList,
      );
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('nullable NonNull class lists serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject = await api.callFlutterEchoNullableNonNullClassList(
        nonNullAllNullableTypesList,
      );
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        expect(value, nonNullAllNullableTypesList[index]);
      }
    });

    testWidgets('null lists serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.callFlutterEchoNullableList(null);
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('nullable maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<Object?, Object?>? echoObject = await api.callFlutterEchoNullableMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('null maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Map<Object?, Object?>? echoObject = await api.callFlutterEchoNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject = await api.callFlutterEchoNullableStringMap(
        stringMap,
      );
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject = await api.callFlutterEchoNullableIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject = await api.callFlutterEchoNullableEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject = await api.callFlutterEchoNullableClassMap(
        allNullableTypesMap,
      );
      for (final MapEntry<int?, AllNullableTypes?> entry in echoObject!.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('nullable NonNull string maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject = await api.callFlutterEchoNullableNonNullStringMap(
        nonNullStringMap,
      );
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('nullable NonNull int maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject = await api.callFlutterEchoNullableNonNullIntMap(
        nonNullIntMap,
      );
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets('nullable NonNull enum maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject = await api.callFlutterEchoNullableNonNullEnumMap(
        nonNullEnumMap,
      );
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets('nullable NonNull class maps serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject = await api
          .callFlutterEchoNullableNonNullClassMap(nonNullAllNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry in echoObject!.entries) {
        expect(entry.value, nonNullAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('null maps serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      final Map<int?, int?>? echoObject = await api.callFlutterEchoNullableIntMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('nullable enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.callFlutterEchoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum? echoEnum = await api.callFlutterEchoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word nullable enums serialize and deserialize correctly', (
      WidgetTester _,
    ) async {
      final api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.fourHundredTwentyTwo;
      final AnEnum? echoEnum = await api.callFlutterEchoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnEnum? sentEnum = null;
      final AnEnum? echoEnum = await api.callFlutterEchoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly (again)', (WidgetTester _) async {
      final api = HostIntegrationCoreApi();

      const AnotherEnum? sentEnum = null;
      final AnotherEnum? echoEnum = await api.callFlutterEchoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });
  });

  group('Flutter API with suffix', () {
    setUp(() {
      FlutterSmallApi.setUp(_SmallFlutterApi(), messageChannelSuffix: 'suffixOne');
      FlutterSmallApi.setUp(_SmallFlutterApi(), messageChannelSuffix: 'suffixTwo');
    });

    testWidgets('echo string succeeds with suffix with multiple instances', (_) async {
      final api = HostIntegrationCoreApi();
      const sentObject = "I'm a computer";
      final String echoObject = await api.callFlutterSmallApiEchoString(sentObject);
      expect(echoObject, sentObject);
    });
  });

  testWidgets('Unused data class still generate', (_) async {
    final unused = UnusedClass();
    expect(unused, unused);
  });

  /// Task queues

  testWidgets('non-task-queue handlers run on a the main thread', (_) async {
    final api = HostIntegrationCoreApi();
    expect(await api.defaultIsMainThread(), true);
  });

  testWidgets('task queue handlers run on a background thread', (_) async {
    final api = HostIntegrationCoreApi();
    // Currently only Android and iOS have task queue support. See
    // https://github.com/flutter/flutter/issues/93945
    // Rather than skip the test, this changes the expectation, so that there
    // is test coverage of the code path, even though the actual backgrounding
    // doesn't happen. This is especially important for macOS, which may need to
    // share generated code with iOS, falling back to the main thread since
    // background is not supported.
    final bool taskQueuesSupported =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    expect(await api.taskQueueIsBackgroundThread(), taskQueuesSupported);
  });

  /// Event channels

  const eventChannelSupported = <TargetGenerator>[TargetGenerator.kotlin, TargetGenerator.swift];

  testWidgets('event channel sends continuous ints', (_) async {
    final Stream<int> events = streamInts();
    final List<int> listEvents = await events.toList();
    for (final value in listEvents) {
      expect(listEvents[value], value);
    }
  }, skip: !eventChannelSupported.contains(targetGenerator));

  testWidgets('event channel handles extended sealed classes', (_) async {
    final completer = Completer<void>();
    var count = 0;
    final Stream<PlatformEvent> events = streamEvents();
    events.listen((PlatformEvent event) {
      switch (event) {
        case IntEvent():
          expect(event.value, 1);
          expect(count, 0);
          count++;
        case StringEvent():
          expect(event.value, 'string');
          expect(count, 1);
          count++;
        case BoolEvent():
          expect(event.value, false);
          expect(count, 2);
          count++;
        case DoubleEvent():
          expect(event.value, 3.14);
          expect(count, 3);
          count++;
        case ObjectsEvent():
          expect(event.value, true);
          expect(count, 4);
          count++;
        case EnumEvent():
          expect(event.value, EventEnum.fortyTwo);
          expect(count, 5);
          count++;
        case ClassEvent():
          expect(event.value.aNullableInt, 0);
          expect(count, 6);
          count++;
          completer.complete();
      }
    });
    await completer.future;
  }, skip: !eventChannelSupported.contains(targetGenerator));

  testWidgets('event channels handle multiple instances', (_) async {
    final completer1 = Completer<void>();
    final completer2 = Completer<void>();
    final Stream<int> events1 = streamConsistentNumbers(instanceName: '1');
    final Stream<int> events2 = streamConsistentNumbers(instanceName: '2');

    events1
        .listen((int event) {
          expect(event, 1);
        })
        .onDone(() => completer1.complete());

    events2
        .listen((int event) {
          expect(event, 2);
        })
        .onDone(() => completer2.complete());

    await completer1.future;
    await completer2.future;
  }, skip: !eventChannelSupported.contains(targetGenerator));
}

/// Implementation of FlutterIntegrationCoreApi for integration tests.
class FlutterApiTestImplementation implements FlutterIntegrationCoreApi {
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
    AllNullableTypesWithoutRecursion? everything,
  ) {
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
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  ) {
    return AllNullableTypes(
      aNullableBool: aNullableBool,
      aNullableInt: aNullableInt,
      aNullableString: aNullableString,
    );
  }

  @override
  AllNullableTypesWithoutRecursion sendMultipleNullableTypesWithoutRecursion(
    bool? aNullableBool,
    int? aNullableInt,
    String? aNullableString,
  ) {
    return AllNullableTypesWithoutRecursion(
      aNullableBool: aNullableBool,
      aNullableInt: aNullableInt,
      aNullableString: aNullableString,
    );
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
  List<AnEnum?> echoEnumList(List<AnEnum?> enumList) => enumList;

  @override
  List<AllNullableTypes?> echoClassList(List<AllNullableTypes?> classList) {
    return classList;
  }

  @override
  List<AnEnum> echoNonNullEnumList(List<AnEnum> enumList) => enumList;

  @override
  List<AllNullableTypes> echoNonNullClassList(List<AllNullableTypes> classList) {
    return classList;
  }

  @override
  Map<Object?, Object?> echoMap(Map<Object?, Object?> map) => map;

  @override
  Map<String?, String?> echoStringMap(Map<String?, String?> stringMap) => stringMap;

  @override
  Map<int?, int?> echoIntMap(Map<int?, int?> intMap) => intMap;

  @override
  Map<AnEnum?, AnEnum?> echoEnumMap(Map<AnEnum?, AnEnum?> enumMap) => enumMap;

  @override
  Map<int?, AllNullableTypes?> echoClassMap(Map<int?, AllNullableTypes?> classMap) {
    return classMap;
  }

  @override
  Map<String, String> echoNonNullStringMap(Map<String, String> stringMap) => stringMap;

  @override
  Map<int, int> echoNonNullIntMap(Map<int, int> intMap) => intMap;

  @override
  Map<AnEnum, AnEnum> echoNonNullEnumMap(Map<AnEnum, AnEnum> enumMap) => enumMap;

  @override
  Map<int, AllNullableTypes> echoNonNullClassMap(Map<int, AllNullableTypes> classMap) {
    return classMap;
  }

  @override
  AnEnum echoEnum(AnEnum anEnum) => anEnum;

  @override
  AnotherEnum echoAnotherEnum(AnotherEnum anotherEnum) => anotherEnum;

  @override
  bool? echoNullableBool(bool? aBool) => aBool;

  @override
  double? echoNullableDouble(double? aDouble) => aDouble;

  @override
  int? echoNullableInt(int? anInt) => anInt;

  @override
  List<Object?>? echoNullableList(List<Object?>? list) => list;

  @override
  List<AnEnum?>? echoNullableEnumList(List<AnEnum?>? enumList) => enumList;

  @override
  List<AllNullableTypes?>? echoNullableClassList(List<AllNullableTypes?>? classList) {
    return classList;
  }

  @override
  List<AnEnum>? echoNullableNonNullEnumList(List<AnEnum>? enumList) {
    return enumList;
  }

  @override
  List<AllNullableTypes>? echoNullableNonNullClassList(List<AllNullableTypes>? classList) {
    return classList;
  }

  @override
  Map<Object?, Object?>? echoNullableMap(Map<Object?, Object?>? map) => map;

  @override
  Map<String?, String?>? echoNullableStringMap(Map<String?, String?>? stringMap) {
    return stringMap;
  }

  @override
  Map<int?, int?>? echoNullableIntMap(Map<int?, int?>? intMap) => intMap;

  @override
  Map<AnEnum?, AnEnum?>? echoNullableEnumMap(Map<AnEnum?, AnEnum?>? enumMap) {
    return enumMap;
  }

  @override
  Map<int?, AllNullableTypes?>? echoNullableClassMap(Map<int?, AllNullableTypes?>? classMap) {
    return classMap;
  }

  @override
  Map<String, String>? echoNullableNonNullStringMap(Map<String, String>? stringMap) {
    return stringMap;
  }

  @override
  Map<int, int>? echoNullableNonNullIntMap(Map<int, int>? intMap) {
    return intMap;
  }

  @override
  Map<AnEnum, AnEnum>? echoNullableNonNullEnumMap(Map<AnEnum, AnEnum>? enumMap) {
    return enumMap;
  }

  @override
  Map<int, AllNullableTypes>? echoNullableNonNullClassMap(Map<int, AllNullableTypes>? classMap) {
    return classMap;
  }

  @override
  String? echoNullableString(String? aString) => aString;

  @override
  Uint8List? echoNullableUint8List(Uint8List? list) => list;

  @override
  AnEnum? echoNullableEnum(AnEnum? anEnum) => anEnum;

  @override
  AnotherEnum? echoAnotherNullableEnum(AnotherEnum? anotherEnum) => anotherEnum;

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
