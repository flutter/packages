// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unused_local_variable

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ffi_test_types.dart';
import 'src/generated/jni_tests.gen.dart';

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
  // testWidgets('jni', (WidgetTester _) async {
  //   final JniMessageApi? jniMessage = JniMessageApi.getInstance();
  //   expect(jniMessage, isNotNull);
  //   expect(jniMessage!.echoString('hello'), 'hello');
  //   final SomeTypes toSend = SomeTypes(
  //     aString: 'hi',
  //     anInt: 5,
  //     aDouble: 5.0,
  //     aBool: false,
  //     a4ByteArray: Int32List(1),
  //     a8ByteArray: Int64List(1),
  //     aByteArray: Uint8List(1),
  //     aFloatArray: Float64List(1),
  //     anObject: 'obj',
  //     anEnum: SomeEnum.value2,
  //     someNullableTypes: SomeNullableTypes(),
  //     list: nonNullList,
  //     map: nonNullMap,
  //     stringList: nonNullStringList,
  //     intList: nonNullIntList,
  //     doubleList: nonNullDoubleList,
  //     boolList: nonNullBoolList,
  //     objectList: nonNullList,
  //     enumList: <SomeEnum>[SomeEnum.value1, SomeEnum.value3],
  //     classList: <SomeNullableTypes>[SomeNullableTypes()],
  //     mapList: <Map<Object, Object>>[
  //       nonNullMap,
  //       nonNullStringMap,
  //       nonNullDoubleMap,
  //       nonNullIntMap,
  //       nonNullBoolMap,
  //     ],
  //     stringMap: nonNullStringMap,
  //     intMap: nonNullIntMap,
  //     objectMap: nonNullMap,
  //     enumMap: <SomeEnum, SomeEnum>{
  //       SomeEnum.value1: SomeEnum.value1,
  //       SomeEnum.value2: SomeEnum.value3
  //     },
  //     classMap: <SomeNullableTypes, SomeNullableTypes>{
  //       SomeNullableTypes(): SomeNullableTypes()
  //     },
  //     listList: <List<Object>>[
  //       nonNullList,
  //       nonNullStringList,
  //       nonNullIntList,
  //       nonNullDoubleList,
  //       nonNullBoolList,
  //     ],
  //     mapMap: <int, Map<Object, Object>>{
  //       0: nonNullMap,
  //       1: nonNullStringMap,
  //       2: nonNullDoubleMap,
  //       4: nonNullIntMap,
  //       5: nonNullBoolMap,
  //     },
  //     listMap: <int, List<Object>>{
  //       0: nonNullList,
  //       1: nonNullStringList,
  //       2: nonNullDoubleList,
  //       4: nonNullIntList,
  //       5: nonNullBoolList,
  //     },
  //   );
  //   final SomeTypes sync = jniMessage.sendSomeTypes(toSend);
  //   expect(sync, toSend);
  //   expect(jniMessage.echoBool(true), true);
  //   expect(jniMessage.echoBool(false), false);
  //   expect(jniMessage.echoDouble(2.0), 2.0);
  //   expect(jniMessage.echoInt(2), 2);
  //   expect(jniMessage.echoString('hello'), 'hello');
  //   expect(jniMessage.echoObj('hello'), 'hello');
  //   expect(jniMessage.echoObj(toSend), toSend);
  //   expect(jniMessage.sendSomeEnum(SomeEnum.value2), SomeEnum.value2);
  //   //nullable
  //   final JniMessageApiNullable? jniMessageNullable =
  //       JniMessageApiNullable.getInstance();
  //   expect(jniMessageNullable, isNotNull);
  //   expect(jniMessageNullable!.echoString('hello'), 'hello');
  //   expect(jniMessageNullable.echoString(null), null);
  //   final SomeNullableTypes? syncNullable =
  //       jniMessageNullable.sendSomeNullableTypes(SomeNullableTypes());
  //   expect(syncNullable!.aString, null);
  //   expect(syncNullable.anInt, null);
  //   expect(syncNullable.aDouble, null);
  //   expect(syncNullable.aBool, null);
  //   expect(syncNullable.anObject, null);
  //   final SomeNullableTypes? syncNull =
  //       jniMessageNullable.sendSomeNullableTypes(null);
  //   expect(syncNull, null);
  //   expect(jniMessageNullable.echoBool(true), true);
  //   expect(jniMessageNullable.echoBool(false), false);
  //   expect(jniMessageNullable.echoDouble(2.0), 2.0);
  //   expect(jniMessageNullable.echoInt(2), 2);
  //   expect(jniMessageNullable.echoString('hello'), 'hello');
  //   expect(jniMessageNullable.echoObj('hello'), 'hello');
  //   expect(jniMessageNullable.echoObj(syncNullable), syncNullable);
  //   expect(jniMessageNullable.sendSomeEnum(SomeEnum.value3), SomeEnum.value3);
  //   expect(jniMessageNullable.echoBool(null), null);
  //   expect(jniMessageNullable.echoDouble(null), null);
  //   expect(jniMessageNullable.echoInt(null), null);
  //   expect(jniMessageNullable.echoString(null), null);
  //   expect(jniMessageNullable.echoObj(null), null);
  //   //async
  //   final JniMessageApiAsync? jniMessageAsync =
  //       JniMessageApiAsync.getInstance();

  //   final SomeTypes nonSync = await jniMessageAsync!.sendSomeTypes(toSend);
  //   expect(nonSync, toSend);
  //   expect(await jniMessageAsync.echoBool(true), true);
  //   expect(await jniMessageAsync.echoBool(false), false);
  //   expect(await jniMessageAsync.echoDouble(2.0), 2.0);
  //   expect(await jniMessageAsync.echoInt(2), 2);
  //   expect(await jniMessageAsync.echoString('hello'), 'hello');
  //   expect(await jniMessageAsync.echoObj('hello'), 'hello');
  //   expect(await jniMessageAsync.echoObj(sync), sync);
  //   expect(
  //       await jniMessageAsync.sendSomeEnum(SomeEnum.value3), SomeEnum.value3);
  //   //nullable async
  //   final JniMessageApiNullableAsync? jniMessageNullableAsync =
  //       JniMessageApiNullableAsync.getInstance();
  //   expect(jniMessageNullableAsync, isNotNull);
  //   expect(await jniMessageNullableAsync!.echoString('hello'), 'hello');
  //   expect(await jniMessageNullableAsync.echoString(null), null);
  //   final SomeNullableTypes? syncNullableAsync = await jniMessageNullableAsync
  //       .sendSomeNullableTypes(SomeNullableTypes());
  //   expect(syncNullableAsync!.aString, null);
  //   expect(syncNullableAsync.anInt, null);
  //   expect(syncNullableAsync.aDouble, null);
  //   expect(syncNullableAsync.aBool, null);
  //   expect(syncNullableAsync.anObject, null);
  //   final SomeNullableTypes? syncNullAsync =
  //       await jniMessageNullableAsync.sendSomeNullableTypes(null);
  //   expect(syncNull, null);
  //   expect(await jniMessageNullableAsync.echoBool(true), true);
  //   expect(await jniMessageNullableAsync.echoBool(false), false);
  //   expect(await jniMessageNullableAsync.echoDouble(2.0), 2.0);
  //   expect(await jniMessageNullableAsync.echoInt(2), 2);
  //   expect(await jniMessageNullableAsync.echoString('hello'), 'hello');
  //   expect(await jniMessageNullableAsync.echoObj('hello'), 'hello');
  //   expect(await jniMessageNullableAsync.echoObj(syncNullable), syncNullable);
  //   expect(await jniMessageNullableAsync.sendSomeEnum(SomeEnum.value3),
  //       SomeEnum.value3);
  //   expect(await jniMessageNullableAsync.echoBool(null), null);
  //   expect(await jniMessageNullableAsync.echoDouble(null), null);
  //   expect(await jniMessageNullableAsync.echoInt(null), null);
  //   expect(await jniMessageNullableAsync.echoString(null), null);
  //   expect(await jniMessageNullableAsync.echoObj(null), null);
  //   //named
  //   final JniMessageApi? jniMessageNamed =
  //       JniMessageApi.getInstance(channelName: 'name');
  //   final JniMessageApiAsync? jniMessageAsyncNamed =
  //       JniMessageApiAsync.getInstance(channelName: 'name');
  //   expect(jniMessageNamed, isNotNull);
  //   expect(jniMessageNamed!.echoString('hello'), 'hello1');
  //   expect(await jniMessageAsync.echoInt(5), 5);
  //   expect(await jniMessageAsyncNamed!.echoInt(5), 6);
  // }, skip: targetGenerator != TargetGenerator.kotlin);

  group('Host sync API tests', () {
    testWidgets('basic void->void call works', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      try {
        api!.noop();
      } catch (e) {
        fail(e.toString());
      }
    });

    testWidgets('all datatypes serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllTypes echoObject = api!.echoAllTypes(genericJniAllTypes);
      expect(echoObject, genericJniAllTypes);
    });

    testWidgets('all nullable datatypes serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypes? echoObject =
          api!.echoAllNullableTypes(recursiveJniAllNullableTypes);

      expect(echoObject, recursiveJniAllNullableTypes);
    });

    testWidgets('all null datatypes serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypes allTypesNull = JniAllNullableTypes();

      final JniAllNullableTypes? echoNullFilledClass =
          api!.echoAllNullableTypes(allTypesNull);
      expect(allTypesNull, echoNullFilledClass);
    });

    testWidgets('Classes with list of null serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypes listTypes =
          JniAllNullableTypes(list: <String?>['String', null]);

      final JniAllNullableTypes? echoNullFilledClass =
          api!.echoAllNullableTypes(listTypes);

      expect(listTypes, echoNullFilledClass);
    });

    testWidgets('Classes with map of null serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypes listTypes = JniAllNullableTypes(
          map: <String?, String?>{'String': 'string', 'null': null});

      final JniAllNullableTypes? echoNullFilledClass =
          api!.echoAllNullableTypes(listTypes);

      expect(listTypes, echoNullFilledClass);
    });

    testWidgets(
        'all nullable datatypes without recursion serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypesWithoutRecursion? echoObject = api!
          .echoAllNullableTypesWithoutRecursion(
              genericJniAllNullableTypesWithoutRecursion);

      expect(echoObject, genericJniAllNullableTypesWithoutRecursion);
    });

    testWidgets(
        'all null datatypes without recursion serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypesWithoutRecursion allTypesNull =
          JniAllNullableTypesWithoutRecursion();

      final JniAllNullableTypesWithoutRecursion? echoNullFilledClass =
          api!.echoAllNullableTypesWithoutRecursion(allTypesNull);
      expect(allTypesNull, echoNullFilledClass);
    });

    testWidgets(
        'Classes without recursion with list of null serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypesWithoutRecursion listTypes =
          JniAllNullableTypesWithoutRecursion(
        list: <String?>['String', null],
      );

      final JniAllNullableTypesWithoutRecursion? echoNullFilledClass =
          api!.echoAllNullableTypesWithoutRecursion(listTypes);

      expect(listTypes, echoNullFilledClass);
    });

    testWidgets(
        'Classes without recursion with map of null serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypesWithoutRecursion listTypes =
          JniAllNullableTypesWithoutRecursion(
        map: <String?, String?>{'String': 'string', 'null': null},
      );

      final JniAllNullableTypesWithoutRecursion? echoNullFilledClass =
          api!.echoAllNullableTypesWithoutRecursion(listTypes);

      expect(listTypes, echoNullFilledClass);
    });

    testWidgets('errors are returned correctly', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      expect(() async {
        api!.throwError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('errors are returned from void methods correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      expect(() async {
        api!.throwErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    // testWidgets('flutter errors are returned correctly',
    //     (WidgetTester _) async {
    //   final JniHostIntegrationCoreApi? api =
    //       JniHostIntegrationCoreApi.getInstance();
    //   expect(
    //       () => api!.throwFlutterError(),
    //       throwsA((dynamic e) =>
    //           e is PlatformException &&
    //           e.code == 'code' &&
    //           e.message == 'message' &&
    //           e.details == 'details'));
    // });

    testWidgets('nested objects can be sent correctly', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final JniAllClassesWrapper classWrapper = classWrapperMaker();
      final String? receivedString =
          api!.extractNestedNullableString(classWrapper);
      expect(receivedString, classWrapper.allNullableTypes.aNullableString);
    });

    testWidgets('nested objects can be received correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const String sentString = 'Some string';
      final JniAllClassesWrapper receivedObject =
          api!.createNestedNullableString(sentString);
      expect(receivedObject.allNullableTypes.aNullableString, sentString);
    });

    testWidgets('nested classes can serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final JniAllClassesWrapper classWrapper = classWrapperMaker();

      final JniAllClassesWrapper receivedClassWrapper =
          api!.echoClassWrapper(classWrapper);
      expect(classWrapper, receivedClassWrapper);
    });

    testWidgets('nested null classes can serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final JniAllClassesWrapper classWrapper = classWrapperMaker();

      classWrapper.allTypes = null;

      final JniAllClassesWrapper receivedClassWrapper =
          api!.echoClassWrapper(classWrapper);
      expect(classWrapper, receivedClassWrapper);
    });

    testWidgets(
        'Arguments of multiple types serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      const String aNullableString = 'this is a String';
      const bool aNullableBool = false;
      const int aNullableInt = regularInt;

      final JniAllNullableTypes echoObject = api!.sendMultipleNullableTypes(
          aNullableBool, aNullableInt, aNullableString);
      expect(echoObject.aNullableInt, aNullableInt);
      expect(echoObject.aNullableBool, aNullableBool);
      expect(echoObject.aNullableString, aNullableString);
    });

    testWidgets(
        'Arguments of multiple null types serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypes echoNullFilledClass =
          api!.sendMultipleNullableTypes(null, null, null);
      expect(echoNullFilledClass.aNullableInt, null);
      expect(echoNullFilledClass.aNullableBool, null);
      expect(echoNullFilledClass.aNullableString, null);
    });

    testWidgets(
        'Arguments of multiple types serialize and deserialize correctly (WithoutRecursion)',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      const String aNullableString = 'this is a String';
      const bool aNullableBool = false;
      const int aNullableInt = regularInt;

      final JniAllNullableTypesWithoutRecursion echoObject = api!
          .sendMultipleNullableTypesWithoutRecursion(
              aNullableBool, aNullableInt, aNullableString);
      expect(echoObject.aNullableInt, aNullableInt);
      expect(echoObject.aNullableBool, aNullableBool);
      expect(echoObject.aNullableString, aNullableString);
    });

    testWidgets(
        'Arguments of multiple null types serialize and deserialize correctly (WithoutRecursion)',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypesWithoutRecursion echoNullFilledClass =
          api!.sendMultipleNullableTypesWithoutRecursion(null, null, null);
      expect(echoNullFilledClass.aNullableInt, null);
      expect(echoNullFilledClass.aNullableBool, null);
      expect(echoNullFilledClass.aNullableString, null);
    });

    testWidgets('Int serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      const int sentInt = regularInt;
      final int receivedInt = api!.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const int sentInt = biggerThanBigInt;
      final int receivedInt = api!.echoInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Doubles serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const double sentDouble = 2.0694;
      final double receivedDouble = api!.echoDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('booleans serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      for (final bool sentBool in <bool>[true, false]) {
        final bool receivedBool = api!.echoBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      const String sentString = 'default';
      final String receivedString = api!.echoString(sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Uint8List serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
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
      final Uint8List receivedUint8List = api!.echoUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('generic Objects serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      const Object sentString = "I'm a computer";
      final Object receivedString = api!.echoObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = regularInt;
      final Object receivedInt = api.echoObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<Object?> echoObject = api!.echoList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAnEnum?> echoObject = api!.echoEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAllNullableTypes?> echoObject =
          api!.echoClassList(allNullableTypesList);
      for (final (int index, JniAllNullableTypes? value)
          in echoObject.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('NonNull enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAnEnum> echoObject =
          api!.echoNonNullEnumList(nonNullEnumList);
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('NonNull class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAllNullableTypes> echoObject =
          api!.echoNonNullClassList(nonNullJniAllNullableTypesList);
      for (final (int index, JniAllNullableTypes value) in echoObject.indexed) {
        expect(value, nonNullJniAllNullableTypesList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<Object?, Object?> echoObject = api!.echoMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<String?, String?> echoObject = api!.echoStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int?, int?> echoObject = api!.echoIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<JniAnEnum?, JniAnEnum?> echoObject = api!.echoEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int?, JniAllNullableTypes?> echoObject =
          api!.echoClassMap(allNullableTypesMap);
      for (final MapEntry<int?, JniAllNullableTypes?> entry
          in echoObject.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('NonNull string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<String, String> echoObject =
          api!.echoNonNullStringMap(nonNullStringMap);
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('NonNull int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int, int> echoObject = api!.echoNonNullIntMap(nonNullIntMap);
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets('NonNull enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<JniAnEnum, JniAnEnum> echoObject =
          api!.echoNonNullEnumMap(nonNullEnumMap);
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets('NonNull class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int, JniAllNullableTypes> echoObject =
          api!.echoNonNullClassMap(nonNullJniAllNullableTypesMap);
      for (final MapEntry<int, JniAllNullableTypes> entry
          in echoObject.entries) {
        expect(entry.value, nonNullJniAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnEnum sentEnum = JniAnEnum.two;
      final JniAnEnum receivedEnum = api!.echoEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
      final JniAnotherEnum receivedEnum = api!.echoAnotherEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnEnum sentEnum = JniAnEnum.fortyTwo;
      final JniAnEnum receivedEnum = api!.echoEnum(sentEnum);
      expect(receivedEnum, sentEnum);
    });

    testWidgets('required named parameter', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      // This number corresponds with the default value of this method.
      const int sentInt = regularInt;
      final int receivedInt = api!.echoRequiredInt(anInt: sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('optional default parameter no arg', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      // This number corresponds with the default value of this method.
      const double sentDouble = 3.14;
      final double receivedDouble = api!.echoOptionalDefaultDouble();
      expect(receivedDouble, sentDouble);
    });

    testWidgets('optional default parameter with arg', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const double sentDouble = 3.15;
      final double receivedDouble = api!.echoOptionalDefaultDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('named default parameter no arg', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      // This string corresponds with the default value of this method.
      const String sentString = 'default';
      final String receivedString = api!.echoNamedDefaultString();
      expect(receivedString, sentString);
    });

    testWidgets('named default parameter with arg', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      // This string corresponds with the default value of this method.
      const String sentString = 'notDefault';
      final String receivedString =
          api!.echoNamedDefaultString(aString: sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Nullable Int serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const int sentInt = regularInt;
      final int? receivedInt = api!.echoNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Nullable Int64 serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const int sentInt = biggerThanBigInt;
      final int? receivedInt = api!.echoNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null Ints serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final int? receivedNullInt = api!.echoNullableInt(null);
      expect(receivedNullInt, null);
    });

    testWidgets('Nullable Doubles serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const double sentDouble = 2.0694;
      final double? receivedDouble = api!.echoNullableDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('Null Doubles serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final double? receivedNullDouble = api!.echoNullableDouble(null);
      expect(receivedNullDouble, null);
    });

    testWidgets('Nullable booleans serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      for (final bool? sentBool in <bool?>[true, false]) {
        final bool? receivedBool = api!.echoNullableBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('Null booleans serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const bool? sentBool = null;
      final bool? receivedBool = api!.echoNullableBool(sentBool);
      expect(receivedBool, sentBool);
    });

    testWidgets('Nullable strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      const String sentString = "I'm a computer";
      final String? receivedString = api!.echoNullableString(sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Null strings serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final String? receivedNullString = api!.echoNullableString(null);
      expect(receivedNullString, null);
    });

    testWidgets('Nullable Uint8List serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
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
          api!.echoNullableUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('Null Uint8List serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final Uint8List? receivedNullUint8List = api!.echoNullableUint8List(null);
      expect(receivedNullUint8List, null);
    });

    testWidgets('generic nullable Objects serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      const Object sentString = "I'm a computer";
      final Object? receivedString = api!.echoNullableObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = regularInt;
      final Object? receivedInt = api.echoNullableObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null generic Objects serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final Object? receivedNullObject = api!.echoNullableObject(null);
      expect(receivedNullObject, null);
    });

    testWidgets('nullable lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<Object?>? echoObject = api!.echoNullableList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAnEnum?>? echoObject = api!.echoNullableEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAllNullableTypes?>? echoObject =
          api!.echoNullableClassList(allNullableTypesList);
      for (final (int index, JniAllNullableTypes? value)
          in echoObject!.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets(
        'nullable NonNull enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAnEnum?>? echoObject =
          api!.echoNullableNonNullEnumList(nonNullEnumList);
      expect(listEquals(echoObject, nonNullEnumList), true);
    });

    testWidgets('nullable NonNull lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAllNullableTypes?>? echoObject =
          api!.echoNullableClassList(nonNullJniAllNullableTypesList);
      for (final (int index, JniAllNullableTypes? value)
          in echoObject!.indexed) {
        expect(value, nonNullJniAllNullableTypesList[index]);
      }
    });

    testWidgets('nullable maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<Object?, Object?>? echoObject = api!.echoNullableMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<String?, String?>? echoObject =
          api!.echoNullableStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int?, int?>? echoObject = api!.echoNullableIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<JniAnEnum?, JniAnEnum?>? echoObject =
          api!.echoNullableEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int?, JniAllNullableTypes?>? echoObject =
          api!.echoNullableClassMap(allNullableTypesMap);
      for (final MapEntry<int?, JniAllNullableTypes?> entry
          in echoObject!.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets(
        'nullable NonNull string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<String?, String?>? echoObject =
          api!.echoNullableNonNullStringMap(nonNullStringMap);
      expect(mapEquals(echoObject, nonNullStringMap), true);
    });

    testWidgets('nullable NonNull int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int?, int?>? echoObject =
          api!.echoNullableNonNullIntMap(nonNullIntMap);
      expect(mapEquals(echoObject, nonNullIntMap), true);
    });

    testWidgets(
        'nullable NonNull enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<JniAnEnum?, JniAnEnum?>? echoObject =
          api!.echoNullableNonNullEnumMap(nonNullEnumMap);
      expect(mapEquals(echoObject, nonNullEnumMap), true);
    });

    testWidgets(
        'nullable NonNull class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int?, JniAllNullableTypes?>? echoObject =
          api!.echoNullableNonNullClassMap(nonNullJniAllNullableTypesMap);
      for (final MapEntry<int?, JniAllNullableTypes?> entry
          in echoObject!.entries) {
        expect(entry.value, nonNullJniAllNullableTypesMap[entry.key]);
      }
    });

    testWidgets('nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnEnum sentEnum = JniAnEnum.three;
      final JniAnEnum? echoEnum = api!.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
      final JniAnotherEnum? echoEnum = api!.echoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnEnum sentEnum = JniAnEnum.fourHundredTwentyTwo;
      final JniAnEnum? echoEnum = api!.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<Object?>? echoObject = api!.echoNullableList(null);
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('null maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final Map<Object?, Object?>? echoObject = api!.echoNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final Map<String?, String?>? echoObject =
          api!.echoNullableStringMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final Map<int?, int?>? echoObject = api!.echoNullableIntMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnEnum? sentEnum = null;
      final JniAnEnum? echoEnum = api!.echoNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnotherEnum? sentEnum = null;
      final JniAnotherEnum? echoEnum = api!.echoAnotherNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null classes serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypes? echoObject = api!.echoAllNullableTypes(null);

      expect(echoObject, isNull);
    });

    testWidgets('optional nullable parameter', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const int sentInt = regularInt;
      final int? receivedInt = api!.echoOptionalNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Null optional nullable parameter', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final int? receivedNullInt = api!.echoOptionalNullableInt();
      expect(receivedNullInt, null);
    });

    testWidgets('named nullable parameter', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      const String sentString = "I'm a computer";
      final String? receivedString =
          api!.echoNamedNullableString(aNullableString: sentString);
      expect(receivedString, sentString);
    });

    testWidgets('Null named nullable parameter', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final String? receivedNullString = api!.echoNamedNullableString();
      expect(receivedNullString, null);
    });
  });

  group('Host async API tests', () {
    testWidgets('basic void->void call works', (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      expect(api!.noopAsync(), completes);
    });

    testWidgets('async errors are returned from non void methods correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      expect(() async {
        await api!.throwAsyncError();
      }, throwsA(isA<PlatformException>()));
    });

    testWidgets('async errors are returned from void methods correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      expect(() async {
        await api!.throwAsyncErrorFromVoid();
      }, throwsA(isA<PlatformException>()));
    });

    // testWidgets(
    // 'async flutter errors are returned from non void methods correctly',
    //     (WidgetTester _) async {
    //   final JniHostIntegrationCoreApi? api =
    //       JniHostIntegrationCoreApi.getInstance();

    //   expect(
    //       () => api!.throwAsyncFlutterError(),
    //       throwsA((dynamic e) =>
    //           e is PlatformException &&
    //           e.code == 'code' &&
    //           e.message == 'message' &&
    //           e.details == 'details'));
    // });

    testWidgets('all datatypes async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllTypes echoObject =
          await api!.echoAsyncJniAllTypes(genericJniAllTypes);

      expect(echoObject, genericJniAllTypes);
    });

    testWidgets(
        'all nullable async datatypes serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypes? echoObject = await api!
          .echoAsyncNullableJniAllNullableTypes(recursiveJniAllNullableTypes);

      expect(echoObject, recursiveJniAllNullableTypes);
    });

    testWidgets('all null datatypes async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypes allTypesNull = JniAllNullableTypes();

      final JniAllNullableTypes? echoNullFilledClass =
          await api!.echoAsyncNullableJniAllNullableTypes(allTypesNull);
      expect(echoNullFilledClass, allTypesNull);
    });

    testWidgets(
        'all nullable async datatypes without recursion serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypesWithoutRecursion? echoObject = await api!
          .echoAsyncNullableJniAllNullableTypesWithoutRecursion(
              genericJniAllNullableTypesWithoutRecursion);

      expect(echoObject, genericJniAllNullableTypesWithoutRecursion);
    });

    testWidgets(
        'all null datatypes without recursion async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final JniAllNullableTypesWithoutRecursion allTypesNull =
          JniAllNullableTypesWithoutRecursion();

      final JniAllNullableTypesWithoutRecursion? echoNullFilledClass =
          await api!.echoAsyncNullableJniAllNullableTypesWithoutRecursion(
              allTypesNull);
      expect(echoNullFilledClass, allTypesNull);
    });

    testWidgets('Int async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const int sentInt = regularInt;
      final int receivedInt = await api!.echoAsyncInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Int64 async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const int sentInt = biggerThanBigInt;
      final int receivedInt = await api!.echoAsyncInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('Doubles async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const double sentDouble = 2.0694;
      final double receivedDouble = await api!.echoAsyncDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('booleans async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      for (final bool sentBool in <bool>[true, false]) {
        final bool receivedBool = await api!.echoAsyncBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('strings async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const String sentObject = 'Hello, asynchronously!';

      final String echoObject = await api!.echoAsyncString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('Uint8List async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
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
          await api!.echoAsyncUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets('generic Objects async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      const Object sentString = "I'm a computer";
      final Object receivedString = await api!.echoAsyncObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = regularInt;
      final Object receivedInt = await api.echoAsyncObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<Object?> echoObject = await api!.echoAsyncList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAnEnum?> echoObject =
          await api!.echoAsyncEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAllNullableTypes?> echoObject =
          await api!.echoAsyncClassList(allNullableTypesList);
      for (final (int index, JniAllNullableTypes? value)
          in echoObject.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<Object?, Object?> echoObject = await api!.echoAsyncMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<String?, String?> echoObject =
          await api!.echoAsyncStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int?, int?> echoObject = await api!.echoAsyncIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<JniAnEnum?, JniAnEnum?> echoObject =
          await api!.echoAsyncEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int?, JniAllNullableTypes?> echoObject =
          await api!.echoAsyncClassMap(allNullableTypesMap);
      for (final MapEntry<int?, JniAllNullableTypes?> entry
          in echoObject.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnEnum sentEnum = JniAnEnum.three;
      final JniAnEnum echoEnum = await api!.echoAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
      final JniAnotherEnum echoEnum = await api!.echoAnotherAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('multi word enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnEnum sentEnum = JniAnEnum.fourHundredTwentyTwo;
      final JniAnEnum echoEnum = await api!.echoAsyncEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable Int async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const int sentInt = regularInt;
      final int? receivedInt = await api!.echoAsyncNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable Int64 async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const int sentInt = biggerThanBigInt;
      final int? receivedInt = await api!.echoAsyncNullableInt(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable Doubles async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const double sentDouble = 2.0694;
      final double? receivedDouble =
          await api!.echoAsyncNullableDouble(sentDouble);
      expect(receivedDouble, sentDouble);
    });

    testWidgets('nullable booleans async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      for (final bool sentBool in <bool>[true, false]) {
        final bool? receivedBool = await api!.echoAsyncNullableBool(sentBool);
        expect(receivedBool, sentBool);
      }
    });

    testWidgets('nullable strings async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const String sentObject = 'Hello, asynchronously!';

      final String? echoObject = await api!.echoAsyncNullableString(sentObject);
      expect(echoObject, sentObject);
    });

    testWidgets('nullable Uint8List async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
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
          await api!.echoAsyncNullableUint8List(sentUint8List);
      expect(receivedUint8List, sentUint8List);
    });

    testWidgets(
        'nullable generic Objects async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      const Object sentString = "I'm a computer";
      final Object? receivedString =
          await api!.echoAsyncNullableObject(sentString);
      expect(receivedString, sentString);

      // Echo a second type as well to ensure the handling is generic.
      const Object sentInt = regularInt;
      final Object? receivedInt = await api.echoAsyncNullableObject(sentInt);
      expect(receivedInt, sentInt);
    });

    testWidgets('nullable lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<Object?>? echoObject = await api!.echoAsyncNullableList(list);
      expect(listEquals(echoObject, list), true);
    });

    testWidgets('nullable enum lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAnEnum?>? echoObject =
          await api!.echoAsyncNullableEnumList(enumList);
      expect(listEquals(echoObject, enumList), true);
    });

    testWidgets('nullable class lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<JniAllNullableTypes?>? echoObject =
          await api!.echoAsyncNullableClassList(allNullableTypesList);
      for (final (int index, JniAllNullableTypes? value)
          in echoObject!.indexed) {
        expect(value, allNullableTypesList[index]);
      }
    });

    testWidgets('nullable maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<Object?, Object?>? echoObject =
          await api!.echoAsyncNullableMap(map);
      expect(mapEquals(echoObject, map), true);
    });

    testWidgets('nullable string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<String?, String?>? echoObject =
          await api!.echoAsyncNullableStringMap(stringMap);
      expect(mapEquals(echoObject, stringMap), true);
    });

    testWidgets('nullable int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int?, int?>? echoObject =
          await api!.echoAsyncNullableIntMap(intMap);
      expect(mapEquals(echoObject, intMap), true);
    });

    testWidgets('nullable enum maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<JniAnEnum?, JniAnEnum?>? echoObject =
          await api!.echoAsyncNullableEnumMap(enumMap);
      expect(mapEquals(echoObject, enumMap), true);
    });

    testWidgets('nullable class maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Map<int?, JniAllNullableTypes?>? echoObject =
          await api!.echoAsyncNullableClassMap(allNullableTypesMap);
      for (final MapEntry<int?, JniAllNullableTypes?> entry
          in echoObject!.entries) {
        expect(entry.value, allNullableTypesMap[entry.key]);
      }
    });

    testWidgets('nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnEnum sentEnum = JniAnEnum.three;
      final JniAnEnum? echoEnum = await api!.echoAsyncNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly (again)',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnotherEnum sentEnum = JniAnotherEnum.justInCase;
      final JniAnotherEnum? echoEnum =
          await api!.echoAnotherAsyncNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('nullable enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnEnum sentEnum = JniAnEnum.fortyTwo;
      final JniAnEnum? echoEnum = await api!.echoAsyncNullableEnum(sentEnum);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null Ints async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final int? receivedInt = await api!.echoAsyncNullableInt(null);
      expect(receivedInt, null);
    });

    testWidgets('null Doubles async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final double? receivedDouble = await api!.echoAsyncNullableDouble(null);
      expect(receivedDouble, null);
    });

    testWidgets('null booleans async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final bool? receivedBool = await api!.echoAsyncNullableBool(null);
      expect(receivedBool, null);
    });

    testWidgets('null strings async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final String? echoObject = await api!.echoAsyncNullableString(null);
      expect(echoObject, null);
    });

    testWidgets('null Uint8List async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final Uint8List? receivedUint8List =
          await api!.echoAsyncNullableUint8List(null);
      expect(receivedUint8List, null);
    });

    testWidgets(
        'null generic Objects async serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();
      final Object? receivedString = await api!.echoAsyncNullableObject(null);
      expect(receivedString, null);
    });

    testWidgets('null lists serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final List<Object?>? echoObject = await api!.echoAsyncNullableList(null);
      expect(listEquals(echoObject, null), true);
    });

    testWidgets('null maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final Map<Object?, Object?>? echoObject =
          await api!.echoAsyncNullableMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null string maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final Map<String?, String?>? echoObject =
          await api!.echoAsyncNullableStringMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null int maps serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      final Map<int?, int?>? echoObject =
          await api!.echoAsyncNullableIntMap(null);
      expect(mapEquals(echoObject, null), true);
    });

    testWidgets('null enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnEnum? sentEnum = null;
      final JniAnEnum? echoEnum = await api!.echoAsyncNullableEnum(null);
      expect(echoEnum, sentEnum);
    });

    testWidgets('null enums serialize and deserialize correctly',
        (WidgetTester _) async {
      final JniHostIntegrationCoreApi? api =
          JniHostIntegrationCoreApi.getInstance();

      const JniAnotherEnum? sentEnum = null;
      final JniAnotherEnum? echoEnum =
          await api!.echoAnotherAsyncNullableEnum(null);
      expect(echoEnum, sentEnum);
    });
  });

  group('Host API with suffix', () {
    testWidgets('echo string succeeds with suffix with multiple instances',
        (_) async {
      final JniHostSmallApi? apiWithSuffixOne =
          JniHostSmallApi.getInstance(channelName: 'suffixOne');
      final JniHostSmallApi? apiWithSuffixTwo =
          JniHostSmallApi.getInstance(channelName: 'suffixTwo');
      const String sentString = "I'm a computer";
      final String echoStringOne = await apiWithSuffixOne!.echo(sentString);
      final String echoStringTwo = await apiWithSuffixTwo!.echo(sentString);
      expect(sentString, echoStringOne);
      expect(sentString, echoStringTwo);
    });

    testWidgets('multiple instances will have different instance names',
        (_) async {
      // The only way to get the channel name back is to throw an exception.
      // These APIs have no corresponding APIs on the host platforms.
      const String sentString = "I'm a computer";
      try {
        final JniHostSmallApi? apiWithSuffixOne =
            JniHostSmallApi.getInstance(channelName: 'suffixWithNoHost');
        await apiWithSuffixOne!.echo(sentString);
      } on ArgumentError catch (e) {
        expect(e.message, contains('suffixWithNoHost'));
      } catch (e) {
        print(e);
      }
      try {
        final JniHostSmallApi? apiWithSuffixTwo =
            JniHostSmallApi.getInstance(channelName: 'suffixWithoutHost');
        await apiWithSuffixTwo!.echo(sentString);
      } on ArgumentError catch (e) {
        expect(e.message, contains('suffixWithoutHost'));
      } catch (e) {
        print(e);
      }
    });
  });
}
