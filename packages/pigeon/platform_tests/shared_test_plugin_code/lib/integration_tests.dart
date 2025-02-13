// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'generated.dart';
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

      final AllNullableTypes listTypes =
          AllNullableTypes(list: <String?>['String', null]);

      final AllNullableTypes? echoNullFilledClass =
          await api.echoAllNullableTypes(listTypes);

      compareAllNullableTypes(listTypes, echoNullFilledClass);
    });

    testWidgets('Classes with map of null serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypes listTypes = AllNullableTypes(
          map: <String?, String?>{'String': 'string', 'null': null});

      final AllNullableTypes? echoNullFilledClass =
          await api.echoAllNullableTypes(listTypes);

      compareAllNullableTypes(listTypes, echoNullFilledClass);
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

      final AllNullableTypesWithoutRecursion listTypes =
          AllNullableTypesWithoutRecursion(
        list: <String?>['String', null],
      );

      final AllNullableTypesWithoutRecursion? echoNullFilledClass =
          await api.echoAllNullableTypesWithoutRecursion(listTypes);

      compareAllNullableTypesWithoutRecursion(listTypes, echoNullFilledClass);
    });

    testWidgets(
        'Classes without recursion with map of null serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final AllNullableTypesWithoutRecursion listTypes =
          AllNullableTypesWithoutRecursion(
        map: <String?, String?>{'String': 'string', 'null': null},
      );

      final AllNullableTypesWithoutRecursion? echoNullFilledClass =
          await api.echoAllNullableTypesWithoutRecursion(listTypes);

      compareAllNullableTypesWithoutRecursion(listTypes, echoNullFilledClass);
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
      final AllClassesWrapper classWrapper = classWrapperMaker();
      final String? receivedString =
          await api.extractNestedNullableString(classWrapper);
      expect(receivedString, classWrapper.allNullableTypes.aNullableString);
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
      final AllClassesWrapper classWrapper = classWrapperMaker();

      final AllClassesWrapper receivedClassWrapper =
          await api.echoClassWrapper(classWrapper);
      compareAllClassesWrapper(classWrapper, receivedClassWrapper);
    });

    testWidgets('nested null classes can serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final AllClassesWrapper classWrapper = classWrapperMaker();

      classWrapper.allTypes = null;

      final AllClassesWrapper receivedClassWrapper =
          await api.echoClassWrapper(classWrapper);
      compareAllClassesWrapper(classWrapper, receivedClassWrapper);
    });

    testWidgets(
        'Arguments of multiple types serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      const String aNullableString = 'this is a String';
      const bool aNullableBool = false;
      const int aNullableInt = regularInt;

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
      const int aNullableInt = regularInt;

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
      const int sentInt = regularInt;
      final int receivedInt = await api.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
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
      const Object sentInt = regularInt;
      final Object receivedInt = await api.echoObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?> echoObject = await api.echoList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?> echoObject = await api.echoEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?> echoObject =
          await api.echoClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        compareAllNullableTypes(value, allNullableTypesList[index]);
      }
    });

    testWidgets('NonNull enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum> echoObject =
          await api.echoNonNullEnumList(nonNullEnumList);
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('NonNull class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes> echoObject =
          await api.echoNonNullClassList(nonNullAllNullableTypesList);
      for (final (int index, AllNullableTypes value) in echoObject.indexed) {
        compareAllNullableTypes(value, nonNullAllNullableTypesList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<Object?, Object?> echoObject = await api.echoMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?> echoObject =
          await api.echoStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?> echoObject = await api.echoIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?> echoObject = await api.echoEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?> echoObject =
          await api.echoClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject.entries) {
        compareAllNullableTypes(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('NonNull string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String, String> echoObject =
          await api.echoNonNullStringMap(nonNullStringMap);
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('NonNull int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int, int> echoObject =
          await api.echoNonNullIntMap(nonNullIntMap);
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets('NonNull enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum, AnEnum> echoObject =
          await api.echoNonNullEnumMap(nonNullEnumMap);
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets('NonNull class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int, AllNullableTypes> echoObject =
          await api.echoNonNullClassMap(nonNullAllNullableTypesMap);
      for (final MapEntry<int, AllNullableTypes> entry in echoObject.entries) {
        compareAllNullableTypes(
            entry.value, nonNullAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.two;
      final AnEnum receivedEnum = await api.echoEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum receivedEnum = await api.echoAnotherEnum(sentEnum);
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
      const int sentInt = regularInt;
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

      const int sentInt = regularInt;
      final int? receivedInt = await api.echoNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Nullable Int64 serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
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
      const Object sentInt = regularInt;
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

      final List<Object?>? echoObject = await api.echoNullableList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject =
          await api.echoNullableEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject =
          await api.echoNullableClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        compareAllNullableTypes(value, allNullableTypesList[index]);
      }
    });

    testWidgets(
        'nullable NonNull enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject =
          await api.echoNullableNonNullEnumList(nonNullEnumList);
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('nullable NonNull lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject =
          await api.echoNullableClassList(nonNullAllNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        compareAllNullableTypes(value, nonNullAllNullableTypesList[index]);
      }
    });

    testWidgets('nullable maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<Object?, Object?>? echoObject = await api.echoNullableMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject =
          await api.echoNullableStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject = await api.echoNullableIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject =
          await api.echoNullableEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject =
          await api.echoNullableClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject!.entries) {
        compareAllNullableTypes(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets(
        'nullable NonNull string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject =
          await api.echoNullableNonNullStringMap(nonNullStringMap);
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('nullable NonNull int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject =
          await api.echoNullableNonNullIntMap(nonNullIntMap);
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets(
        'nullable NonNull enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject =
          await api.echoNullableNonNullEnumMap(nonNullEnumMap);
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets(
        'nullable NonNull class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject =
          await api.echoNullableNonNullClassMap(nonNullAllNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject!.entries) {
        compareAllNullableTypes(
            entry.value, nonNullAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum? echoEnum = await api.echoAnotherNullableEnum(sentEnum);
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

      final Map<Object?, Object?>? echoObject = await api.echoNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<String?, String?>? echoObject =
          await api.echoNullableStringMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<int?, int?>? echoObject = await api.echoNullableIntMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum? sentEnum = null;
      final AnEnum? echoEnum = await api.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum? sentEnum = null;
      final AnotherEnum? echoEnum = await api.echoAnotherNullableEnum(sentEnum);
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

      const int sentInt = regularInt;
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

      const int sentInt = regularInt;
      final int receivedInt = await api.echoAsyncInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
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
      const Object sentInt = regularInt;
      final Object receivedInt = await api.echoAsyncObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?> echoObject = await api.echoAsyncList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?> echoObject = await api.echoAsyncEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?> echoObject =
          await api.echoAsyncClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        compareAllNullableTypes(value, allNullableTypesList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<Object?, Object?> echoObject = await api.echoAsyncMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?> echoObject =
          await api.echoAsyncStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?> echoObject = await api.echoAsyncIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?> echoObject =
          await api.echoAsyncEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?> echoObject =
          await api.echoAsyncClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject.entries) {
        compareAllNullableTypes(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum echoEnum = await api.echoAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum echoEnum = await api.echoAnotherAsyncEnum(sentEnum);
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

      const int sentInt = regularInt;
      final int? receivedInt = await api.echoAsyncNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable Int64 async serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentInt = biggerThanBigInt;
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
      const Object sentInt = regularInt;
      final Object? receivedInt = await api.echoAsyncNullableObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<Object?>? echoObject = await api.echoAsyncNullableList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject =
          await api.echoAsyncNullableEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject =
          await api.echoAsyncNullableClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        compareAllNullableTypes(value, allNullableTypesList[index]);
      }
    });

    testWidgets('nullable maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<Object?, Object?>? echoObject =
          await api.echoAsyncNullableMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject =
          await api.echoAsyncNullableStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject =
          await api.echoAsyncNullableIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject =
          await api.echoAsyncNullableEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject =
          await api.echoAsyncNullableClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject!.entries) {
        compareAllNullableTypes(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.echoAsyncNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum? echoEnum =
          await api.echoAnotherAsyncNullableEnum(sentEnum);
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

      final Map<Object?, Object?>? echoObject =
          await api.echoAsyncNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<String?, String?>? echoObject =
          await api.echoAsyncNullableStringMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<int?, int?>? echoObject =
          await api.echoAsyncNullableIntMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum? sentEnum = null;
      final AnEnum? echoEnum = await api.echoAsyncNullableEnum(null);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum? sentEnum = null;
      final AnotherEnum? echoEnum =
          await api.echoAnotherAsyncNullableEnum(null);
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
      const int aNullableInt = regularInt;

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
      const int aNullableInt = regularInt;

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

      const int sentObject = regularInt;
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

      final List<Object?> echoObject = await api.callFlutterEchoList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?> echoObject =
          await api.callFlutterEchoEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?> echoObject =
          await api.callFlutterEchoClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        compareAllNullableTypes(value, allNullableTypesList[index]);
      }
    });

    testWidgets('NonNull enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum> echoObject =
          await api.callFlutterEchoNonNullEnumList(nonNullEnumList);
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('NonNull class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes> echoObject = await api
          .callFlutterEchoNonNullClassList(nonNullAllNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject.indexed) {
        compareAllNullableTypes(value, nonNullAllNullableTypesList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<Object?, Object?> echoObject =
          await api.callFlutterEchoMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?> echoObject =
          await api.callFlutterEchoStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?> echoObject =
          await api.callFlutterEchoIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?> echoObject =
          await api.callFlutterEchoEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?> echoObject =
          await api.callFlutterEchoClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject.entries) {
        compareAllNullableTypes(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('NonNull string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String, String> echoObject =
          await api.callFlutterEchoNonNullStringMap(nonNullStringMap);
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('NonNull int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int, int> echoObject =
          await api.callFlutterEchoNonNullIntMap(nonNullIntMap);
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets('NonNull enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum, AnEnum> echoObject =
          await api.callFlutterEchoNonNullEnumMap(nonNullEnumMap);
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets('NonNull class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int, AllNullableTypes> echoObject =
          await api.callFlutterEchoNonNullClassMap(nonNullAllNullableTypesMap);
      for (final MapEntry<int, AllNullableTypes> entry in echoObject.entries) {
        compareAllNullableTypes(
            entry.value, nonNullAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum echoEnum = await api.callFlutterEchoEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum echoEnum =
          await api.callFlutterEchoAnotherEnum(sentEnum);
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

      const int sentObject = regularInt;
      final int? echoObject = await api.callFlutterEchoNullableInt(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('nullable big ints serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const int sentObject = biggerThanBigInt;
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

      final List<Object?>? echoObject =
          await api.callFlutterEchoNullableList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject =
          await api.callFlutterEchoNullableEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject =
          await api.callFlutterEchoNullableClassList(allNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        compareAllNullableTypes(value, allNullableTypesList[index]);
      }
    });

    testWidgets(
        'nullable NonNull enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AnEnum?>? echoObject =
          await api.callFlutterEchoNullableNonNullEnumList(nonNullEnumList);
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets(
        'nullable NonNull class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final List<AllNullableTypes?>? echoObject = await api
          .callFlutterEchoNullableNonNullClassList(nonNullAllNullableTypesList);
      for (final (int index, AllNullableTypes? value) in echoObject!.indexed) {
        compareAllNullableTypes(value, nonNullAllNullableTypesList[index]);
      }
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
      final Map<Object?, Object?>? echoObject =
          await api.callFlutterEchoNullableMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('null maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<Object?, Object?>? echoObject =
          await api.callFlutterEchoNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject =
          await api.callFlutterEchoNullableStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject =
          await api.callFlutterEchoNullableIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject =
          await api.callFlutterEchoNullableEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject =
          await api.callFlutterEchoNullableClassMap(allNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject!.entries) {
        compareAllNullableTypes(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets(
        'nullable NonNull string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<String?, String?>? echoObject =
          await api.callFlutterEchoNullableNonNullStringMap(nonNullStringMap);
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('nullable NonNull int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, int?>? echoObject =
          await api.callFlutterEchoNullableNonNullIntMap(nonNullIntMap);
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets(
        'nullable NonNull enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<AnEnum?, AnEnum?>? echoObject =
          await api.callFlutterEchoNullableNonNullEnumMap(nonNullEnumMap);
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets(
        'nullable NonNull class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();
      final Map<int?, AllNullableTypes?>? echoObject = await api
          .callFlutterEchoNullableNonNullClassMap(nonNullAllNullableTypesMap);
      for (final MapEntry<int?, AllNullableTypes?> entry
          in echoObject!.entries) {
        compareAllNullableTypes(
            entry.value, nonNullAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('null maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      final Map<int?, int?>? echoObject =
          await api.callFlutterEchoNullableIntMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnEnum sentEnum = AnEnum.three;
      final AnEnum? echoEnum = await api.callFlutterEchoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum sentEnum = AnotherEnum.justInCase;
      final AnotherEnum? echoEnum =
          await api.callFlutterEchoAnotherNullableEnum(sentEnum);
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

    testWidgets('null enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final HostIntegrationCoreApi api = HostIntegrationCoreApi();

      const AnotherEnum? sentEnum = null;
      final AnotherEnum? echoEnum =
          await api.callFlutterEchoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });
  });

  group('Proxy API Tests', () {
    if (!proxyApiSupportedLanguages.contains(targetGenerator)) {
      return;
    }

    testWidgets('named constructor', (_) async {
      final ProxyApiTestClass instance = ProxyApiTestClass.namedConstructor(
        aBool: true,
        anInt: 0,
        aDouble: 0.0,
        aString: '',
        aUint8List: Uint8List(0),
        aList: const <Object?>[],
        aMap: const <String?, Object?>{},
        anEnum: ProxyApiTestEnum.one,
        aProxyApi: ProxyApiSuperClass(),
        flutterEchoBool: (ProxyApiTestClass instance, bool aBool) => true,
        flutterEchoInt: (_, __) => 3,
        flutterEchoDouble: (_, __) => 1.0,
        flutterEchoString: (_, __) => '',
        flutterEchoUint8List: (_, __) => Uint8List(0),
        flutterEchoList: (_, __) => <Object?>[],
        flutterEchoProxyApiList: (_, __) => <ProxyApiTestClass?>[],
        flutterEchoMap: (_, __) => <String?, Object?>{},
        flutterEchoEnum: (_, __) => ProxyApiTestEnum.one,
        flutterEchoProxyApi: (_, __) => ProxyApiSuperClass(),
        flutterEchoAsyncString: (_, __) async => '',
        flutterEchoProxyApiMap: (_, __) => <String?, ProxyApiTestClass?>{},
      );
      // Ensure no error calling method on instance.
      await instance.noop();
    });

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

      final List<ProxyApiTestClass> value = <ProxyApiTestClass>[
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

      final Map<String, ProxyApiTestClass> value = <String, ProxyApiTestClass>{
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
      expect(await api.echoNullableInt(1), 1);
    });

    testWidgets('echoNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableDouble(null), null);
      expect(await api.echoNullableDouble(1.0), 1.0);
    });

    testWidgets('echoNullableBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableBool(null), null);
      expect(await api.echoNullableBool(false), false);
    });

    testWidgets('echoNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableString(null), null);
      expect(await api.echoNullableString('aString'), 'aString');
    });

    testWidgets('echoNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableUint8List(null), null);
      expect(await api.echoNullableUint8List(Uint8List(0)), Uint8List(0));
    });

    testWidgets('echoNullableObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableObject(null), null);
      expect(await api.echoNullableObject('aString'), 'aString');
    });

    testWidgets('echoNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableList(null), null);
      expect(await api.echoNullableList(<int>[1]), <int>[1]);
    });

    testWidgets('echoNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableMap(null), null);
      expect(
        await api.echoNullableMap(<String, int>{'value': 1}),
        <String, int>{'value': 1},
      );
    });

    testWidgets('echoNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableEnum(null), null);
      expect(
        await api.echoNullableEnum(ProxyApiTestEnum.one),
        ProxyApiTestEnum.one,
      );
    });

    testWidgets('echoNullableProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoNullableProxyApi(null), null);

      final ProxyApiSuperClass proxyApi = ProxyApiSuperClass();
      expect(
        await api.echoNullableProxyApi(proxyApi),
        proxyApi,
      );
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
      expect(await api.echoAsyncNullableInt(1), 1);
    });

    testWidgets('echoAsyncNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableDouble(null), null);
      expect(await api.echoAsyncNullableDouble(2.0), 2.0);
    });

    testWidgets('echoAsyncNullableBool', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableBool(null), null);
      expect(await api.echoAsyncNullableBool(true), true);
    });

    testWidgets('echoAsyncNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableString(null), null);
      expect(await api.echoAsyncNullableString('aString'), 'aString');
    });

    testWidgets('echoAsyncNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableUint8List(null), null);
      expect(
        await api.echoAsyncNullableUint8List(Uint8List(0)),
        Uint8List(0),
      );
    });

    testWidgets('echoAsyncNullableObject', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableObject(null), null);
      expect(await api.echoAsyncNullableObject(1), 1);
    });

    testWidgets('echoAsyncNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableList(null), null);
      expect(await api.echoAsyncNullableList(<int>[1]), <int>[1]);
    });

    testWidgets('echoAsyncNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableMap(null), null);
      expect(
        await api.echoAsyncNullableMap(<String, int>{'banana': 1}),
        <String, int>{'banana': 1},
      );
    });

    testWidgets('echoAsyncNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass();
      expect(await api.echoAsyncNullableEnum(null), null);
      expect(
        await api.echoAsyncNullableEnum(ProxyApiTestEnum.one),
        ProxyApiTestEnum.one,
      );
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
      expect(await api.callFlutterEchoNullableBool(true), true);
    });

    testWidgets('callFlutterEchoNullableInt', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableInt: (_, int? anInt) => anInt,
      );
      expect(await api.callFlutterEchoNullableInt(null), null);
      expect(await api.callFlutterEchoNullableInt(1), 1);
    });

    testWidgets('callFlutterEchoNullableDouble', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableDouble: (_, double? aDouble) => aDouble,
      );
      expect(await api.callFlutterEchoNullableDouble(null), null);
      expect(await api.callFlutterEchoNullableDouble(1.0), 1.0);
    });

    testWidgets('callFlutterEchoNullableString', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableString: (_, String? aString) => aString,
      );
      expect(await api.callFlutterEchoNullableString(null), null);
      expect(await api.callFlutterEchoNullableString('aString'), 'aString');
    });

    testWidgets('callFlutterEchoNullableUint8List', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableUint8List: (_, Uint8List? aUint8List) => aUint8List,
      );
      expect(await api.callFlutterEchoNullableUint8List(null), null);
      expect(
        await api.callFlutterEchoNullableUint8List(Uint8List(0)),
        Uint8List(0),
      );
    });

    testWidgets('callFlutterEchoNullableList', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableList: (_, List<Object?>? aList) => aList,
      );
      expect(await api.callFlutterEchoNullableList(null), null);
      expect(await api.callFlutterEchoNullableList(<int>[0]), <int>[0]);
    });

    testWidgets('callFlutterEchoNullableMap', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableMap: (_, Map<String?, Object?>? aMap) => aMap,
      );
      expect(await api.callFlutterEchoNullableMap(null), null);
      expect(
        await api.callFlutterEchoNullableMap(<String, int>{'str': 0}),
        <String, int>{'str': 0},
      );
    });

    testWidgets('callFlutterEchoNullableEnum', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableEnum: (_, ProxyApiTestEnum? anEnum) => anEnum,
      );
      expect(await api.callFlutterEchoNullableEnum(null), null);
      expect(
        await api.callFlutterEchoNullableEnum(ProxyApiTestEnum.two),
        ProxyApiTestEnum.two,
      );
    });

    testWidgets('callFlutterEchoNullableProxyApi', (_) async {
      final ProxyApiTestClass api = _createGenericProxyApiTestClass(
        flutterEchoNullableProxyApi: (_, ProxyApiSuperClass? aProxyApi) =>
            aProxyApi,
      );

      expect(await api.callFlutterEchoNullableProxyApi(null), null);

      final ProxyApiSuperClass proxyApi = ProxyApiSuperClass();
      expect(await api.callFlutterEchoNullableProxyApi(proxyApi), proxyApi);
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

  testWidgets('Unused data class still generate', (_) async {
    final UnusedClass unused = UnusedClass();
    expect(unused, unused);
  });

  /// Event channels

  const List<TargetGenerator> eventChannelSupported = <TargetGenerator>[
    TargetGenerator.kotlin,
    TargetGenerator.swift
  ];

  testWidgets('event channel sends continuous ints', (_) async {
    final Stream<int> events = streamInts();
    final List<int> listEvents = await events.toList();
    for (final int value in listEvents) {
      expect(listEvents[value], value);
    }
  }, skip: !eventChannelSupported.contains(targetGenerator));

  testWidgets('event channel handles extended sealed classes', (_) async {
    final Completer<void> completer = Completer<void>();
    int count = 0;
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
    final Completer<void> completer1 = Completer<void>();
    final Completer<void> completer2 = Completer<void>();
    final Stream<int> events1 = streamConsistentNumbers(instanceName: '1');
    final Stream<int> events2 = streamConsistentNumbers(instanceName: '2');

    events1.listen((int event) {
      expect(event, 1);
    }).onDone(() => completer1.complete());

    events2.listen((int event) {
      expect(event, 2);
    }).onDone(() => completer2.complete());

    await completer1.future;
    await completer2.future;
  }, skip: !eventChannelSupported.contains(targetGenerator));
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
  List<AnEnum?> echoEnumList(List<AnEnum?> enumList) => enumList;

  @override
  List<AllNullableTypes?> echoClassList(List<AllNullableTypes?> classList) {
    return classList;
  }

  @override
  List<AnEnum> echoNonNullEnumList(List<AnEnum> enumList) => enumList;

  @override
  List<AllNullableTypes> echoNonNullClassList(
      List<AllNullableTypes> classList) {
    return classList;
  }

  @override
  Map<Object?, Object?> echoMap(Map<Object?, Object?> map) => map;

  @override
  Map<String?, String?> echoStringMap(Map<String?, String?> stringMap) =>
      stringMap;

  @override
  Map<int?, int?> echoIntMap(Map<int?, int?> intMap) => intMap;

  @override
  Map<AnEnum?, AnEnum?> echoEnumMap(Map<AnEnum?, AnEnum?> enumMap) => enumMap;

  @override
  Map<int?, AllNullableTypes?> echoClassMap(
      Map<int?, AllNullableTypes?> classMap) {
    return classMap;
  }

  @override
  Map<String, String> echoNonNullStringMap(Map<String, String> stringMap) =>
      stringMap;

  @override
  Map<int, int> echoNonNullIntMap(Map<int, int> intMap) => intMap;

  @override
  Map<AnEnum, AnEnum> echoNonNullEnumMap(Map<AnEnum, AnEnum> enumMap) =>
      enumMap;

  @override
  Map<int, AllNullableTypes> echoNonNullClassMap(
      Map<int, AllNullableTypes> classMap) {
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
  List<AllNullableTypes?>? echoNullableClassList(
      List<AllNullableTypes?>? classList) {
    return classList;
  }

  @override
  List<AnEnum>? echoNullableNonNullEnumList(List<AnEnum>? enumList) {
    return enumList;
  }

  @override
  List<AllNullableTypes>? echoNullableNonNullClassList(
      List<AllNullableTypes>? classList) {
    return classList;
  }

  @override
  Map<Object?, Object?>? echoNullableMap(Map<Object?, Object?>? map) => map;

  @override
  Map<String?, String?>? echoNullableStringMap(
      Map<String?, String?>? stringMap) {
    return stringMap;
  }

  @override
  Map<int?, int?>? echoNullableIntMap(Map<int?, int?>? intMap) => intMap;

  @override
  Map<AnEnum?, AnEnum?>? echoNullableEnumMap(Map<AnEnum?, AnEnum?>? enumMap) {
    return enumMap;
  }

  @override
  Map<int?, AllNullableTypes?>? echoNullableClassMap(
      Map<int?, AllNullableTypes?>? classMap) {
    return classMap;
  }

  @override
  Map<String, String>? echoNullableNonNullStringMap(
      Map<String, String>? stringMap) {
    return stringMap;
  }

  @override
  Map<int, int>? echoNullableNonNullIntMap(Map<int, int>? intMap) {
    return intMap;
  }

  @override
  Map<AnEnum, AnEnum>? echoNullableNonNullEnumMap(
      Map<AnEnum, AnEnum>? enumMap) {
    return enumMap;
  }

  @override
  Map<int, AllNullableTypes>? echoNullableNonNullClassMap(
      Map<int, AllNullableTypes>? classMap) {
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
    flutterEchoBool:
        flutterEchoBool ?? (ProxyApiTestClass instance, bool aBool) => true,
    flutterEchoInt: flutterEchoInt ?? (_, __) => 3,
    flutterEchoDouble: flutterEchoDouble ?? (_, __) => 1.0,
    flutterEchoString: flutterEchoString ?? (_, __) => '',
    flutterEchoUint8List: flutterEchoUint8List ?? (_, __) => Uint8List(0),
    flutterEchoList: flutterEchoList ?? (_, __) => <Object?>[],
    flutterEchoProxyApiList:
        flutterEchoProxyApiList ?? (_, __) => <ProxyApiTestClass?>[],
    flutterEchoMap: flutterEchoMap ?? (_, __) => <String?, Object?>{},
    flutterEchoEnum: flutterEchoEnum ?? (_, __) => ProxyApiTestEnum.one,
    flutterEchoProxyApi: flutterEchoProxyApi ?? (_, __) => ProxyApiSuperClass(),
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
    flutterEchoAsyncString: flutterEchoAsyncString ?? (_, __) async => '',
    flutterEchoProxyApiMap:
        flutterEchoProxyApiMap ?? (_, __) => <String?, ProxyApiTestClass?>{},
  );
}
